#include "Engine.h"
#include "Action.h"
#include "Plan.h"
#include "Objective.h"
#include "Instance.h"
#include "TimelineMarker.h"
#include "SearchInfo.h"
#include "GlobalVars.h"

#include "utils/Utils.h"

#include <QQuickItem>
#include <QQmlEngine>
#include <QApplication>
#include <QQmlApplicationEngine>
#include <QQmlContext>
#include <QFile>
#include <QTextStream>
#include <QStringList>
#include <QDir>

#include <chrono>
#include <algorithm>

namespace LPP
{

    Engine* Engine::m_current = nullptr;

    void registerQtClasses()
    {
        qmlRegisterType<GlobalSettings> ("lpp", 1, 0, "GlobalSettings");
        qmlRegisterType<TimelineMarker> ("lpp", 1, 0, "TimelineMarker");
        qmlRegisterType<Action> ("lpp", 1, 0, "Action");
        qmlRegisterType<Plan> ("lpp", 1, 0, "Plan");
        qmlRegisterType<Objective> ("lpp", 1, 0, "Objective");
        qmlRegisterType<Instance> ("lpp", 1, 0, "Instance");
        qmlRegisterType<Occurrence> ("lpp", 1, 0, "Occurrence");
        qmlRegisterType<QObjectVector> ("lpp", 1, 0, "QObjectVector");
        qmlRegisterType<Folder> ("lpp", 1, 0, "Folder");
        qmlRegisterType<SearchInfo> ("lpp", 1, 0, "SearchInfo");
        qmlRegisterType<SearchList> ("lpp", 1, 0, "SearchList");
        qmlRegisterType<IQmlSearchable> ("lpp", 1, 0, "_IQmlSearchable");
    }

    Engine::Engine() : QObject(nullptr)
    {
        if (m_current != nullptr) throw "ERROR: Engine must be singleton";
        else m_current = this;
    }
    
    Engine::~Engine()
    {
        //delete this->m_test;
        for (QVector<TimelineMarker*>* month:this->m_timeline){
            for (TimelineMarker* marker:*month){
                delete marker;
            }
            delete month;
        }
    }
    
    Engine* Engine::current()
    {
        return m_current;
    }
    
    void Engine::initialize(QApplication& app, QQmlApplicationEngine& engine)
    {
        this->appPath = app.applicationDirPath() + "/..";
        this->qmlPath = app.applicationDirPath() + "/../qml";
        this->savePath = this->appPath + e_savePath;
        
        //this->m_test = new Actionaction();
        
        this->m_numFolders = this->m_numActions = this->m_numPlans = 0;
        
        this->m_folders.fill(nullptr, e_maxID);
        //this->m_folderIDs.fill(0, e_maxID);
        
        this->m_actions.fill(nullptr, e_maxID);
        //this->m_actionIDs.fill(0, e_maxID);
        
        this->m_plans.fill(nullptr, e_maxID);
        //this->m_planIDs.fill(0, e_maxID);
        
        this->m_timeOrigin.setMSecsSinceEpoch(0);
        this->m_timeOrigin.setTimeSpec(Qt::UTC);
        
        /*
        TimelineMarker* origin = new TimelineMarker();
        origin->setTime(this->m_timeOrigin);
        */
        
        this->m_rootFolder.setName(tr("Root Folder"));
        
        //this->saveFolder(&this->m_rootFolder);
        
        QQmlEngine::setObjectOwnership(&this->m_searchList, QQmlEngine::CppOwnership);
        
        this->m_mergeDisabled = false;
        
        this->m_currentMonthIndex = this->m_currentMarkerIndex = 0;
        
        this->m_occurrencesChanged = this->m_sessionsChanged = this->m_autoplanDesynced = this->m_timeChanged = true;
        
        this->m_impossibleConditions.deleteChildrenOnDestroy = false;
        
        this->load();
        
        
        engine.addImportPath(this->qmlPath);
        
        engine.rootContext()->setContextProperty("Engine", this);
        //engine.rootContext()->setContextProperty("qmlPath", qmlPath);
        
        engine.load(this->qmlPath + "/main.qml");
        //QObject* mainWindow = engine.rootObjects()[0];
        
        //QObject* mainUI = mainWindow->findChild<QObject*>("ui");
        //mainUI->setProperty("opacity", 0.5);
    }
    
    QDateTime Engine::timeOrigin()
    {
        return this->m_timeOrigin;
    }
    
    Folder* Engine::rootFolder()
    {
        return &this->m_rootFolder;
    }
    
    GlobalSettings* Engine::globalSettings()
    {
        return &this->m_globalSettings;
    }
    
    /*
    Int Engine::getNextID(const QVector<Int>& idList)
    {
        int s = idList.size();
        if (!s) return 0;
        
        for (Int i = 1; i < s; i++){
            if (idList[i] - idList[i-1] > 1){
                return idList[i-1]+1;
            }
        }
        
        if (idList[s-1] < e_maxID) return idList[s-1]+1;
        return -1;
    }
    */
    
    
    QObject* Engine::createFolder(Folder* parentFolder, Int id)
    {
        this->setOccurrencesChanged();
        
        if (id == -1){
            int s = this->m_folders.size();
            for (int i = 0; i < s; i++){
                if (this->m_folders[i] == nullptr) {
                    id = i;
                    break;
                }
            }
        }
        if (id < 0 || id >= this->m_folders.size() || this->m_folders[id] != nullptr) return nullptr;
        
        Folder* newFolder = new Folder();
        
        QQmlEngine::setObjectOwnership(newFolder, QQmlEngine::CppOwnership);
        
        newFolder->setID(id);
        newFolder->setParentFolder(parentFolder);
        
        parentFolder->folders()->push(newFolder);
        
        this->m_folders[id] = newFolder;
        
        this->m_numFolders++;
        emit this->numFoldersChanged();
        
        return newFolder;
    }
    
    QObject* Engine::getFolderByID(Int id)
    {
        if (id >= 0 && id < this->m_folders.size()) return this->m_folders[id];
        return nullptr;
    }
    
    bool Engine::moveFolder(Folder* folder, Folder* destFolder){
        
        QString oldPath = this->getFilePath(*folder);
        
        destFolder->folders()->push(folder);
        
        QObjectVector* oldFolderVector = folder->parentFolder()->folders();
        oldFolderVector->deleteChildrenOnDestroy = false;
        oldFolderVector->remove(folder);
        oldFolderVector->deleteChildrenOnDestroy = true;
        
        folder->setParentFolder(destFolder);
        
        QString newPath = this->getFilePath(*folder);
        
        QDir dir(oldPath);
        
        return dir.rename(oldPath + folder->getFileName(), newPath + folder->getFileName());
    }
    
    bool Engine::deleteFolder(Folder* folder)
    {   
        if (folder != nullptr){
            
            this->setOccurrencesChanged();
            
            emit this->objectDeleted(folder);
            
            while(folder->folders()->size()) this->deleteFolder(static_cast<Folder*>(folder->folders()->at(0)));
            while(folder->actions()->size()) this->deleteAction(static_cast<Action*>(folder->actions()->at(0)));
            while(folder->plans()->size()) this->deletePlan(static_cast<Plan*>(folder->plans()->at(0)));
            
            this->deleteDirectory(this->getFilePath(*folder) + folder->getFileName());
            
            this->m_folders[folder->id()] = nullptr;
            
            folder->parentFolder()->folders()->remove(folder);
            
            this->m_numFolders--;
            emit this->numFoldersChanged();
            
            return true;
        }
        
        return false;
    }
    
    void Engine::saveFolder(Folder* folder)
    {
        if (folder == nullptr) return;
        
        this->saveToFile(this->getFilePath(*folder) + folder->getFileName(), e_folderDataFileName + e_saveFileNameExtension, *folder);
    }
    
    Int Engine::numFolders()
    {
        return this->m_numFolders;
    }
    
    
    QObject* Engine::createAction(Folder* parentFolder, Int id)
    {
        this->setOccurrencesChanged();
        
        if (id == -1){
            int s = this->m_actions.size();
            for (int i = 0; i < s; i++){
                if (this->m_actions[i] == nullptr) {
                    id = i;
                    break;
                }
            }
        }
        if (id < 0 || id >= this->m_actions.size() || this->m_actions[id] != nullptr) return nullptr;
        
        Action* newAction = new Action();
        
        QQmlEngine::setObjectOwnership(newAction, QQmlEngine::CppOwnership);
        
        newAction->setID(id);
        newAction->setParentFolder(parentFolder);
        
        parentFolder->actions()->push(newAction);
        
        this->m_actions[id] = newAction;
        
        this->m_numActions++;
        emit this->numActionsChanged();
        
        return newAction;
    }
    
    QObject* Engine::getActionByID(Int id)
    {
        if (id >= 0 && id < this->m_actions.size()) return this->m_actions[id];
        return nullptr;
    }
    
    bool Engine::moveAction(Action* action, Folder* destFolder){
        
        QString oldPath = this->getFilePath(*action);
        
        destFolder->actions()->push(action);
        
        QObjectVector* oldFolderVector = action->parentFolder()->actions();
        oldFolderVector->deleteChildrenOnDestroy = false;
        oldFolderVector->remove(action);
        oldFolderVector->deleteChildrenOnDestroy = true;
        
        action->setParentFolder(destFolder);
        
        QString newPath = this->getFilePath(*action);
        
        QDir dir(oldPath);
        
        return dir.rename(oldPath + action->getFileName() + e_saveFileNameExtension, newPath + action->getFileName() + e_saveFileNameExtension);
    }
    
    bool Engine::deleteAction(Action* action)
    {   
        if (action != nullptr){
            
            this->setOccurrencesChanged();
            
            emit this->actionDeleted(action);
            emit this->objectDeleted(action);
            
            if (this->m_timeline.size() && this->m_timeline[0]->size() > 1){
                TimelineMarker* marker = this->m_timeline[0]->at(1);
                this->m_currentMonthIndex = 0;
                this->m_currentMarkerIndex = 1;
                while (marker != nullptr){
                    //qDebug() << marker;
                    if (marker->action() == action) {
                        QDateTime time = marker->time();
                        this->setMarkerAction(marker, nullptr, false);
                        marker = static_cast<TimelineMarker*>(this->getMarkerAfter(time));
                    }
                    else {
                        marker = static_cast<TimelineMarker*>(this->getNextMarker());
                    }
                }
            }
            
            for (int i = 0; i < this->m_plans.size(); i++){
                Plan* plan = this->m_plans[i];
                if (plan != nullptr) {
                    bool found = false;
                    QVector<QObject*> objectives = plan->objectives()->getData();
                    for (int j = objectives.size() - 1; j >= 0; j--){
                        Objective* objective = static_cast<Objective*>(objectives.at(j));
                        if (objective->action() == action){
                            plan->deleteObjective(objective);
                            found = true;
                        }
                    }
                    if (found) this->savePlan(plan);
                }
            }
            
            this->deleteFile(this->getFilePath(*action) + action->getFileName() + e_saveFileNameExtension);
            
            this->m_actions[action->id()] = nullptr;
            
            action->parentFolder()->actions()->remove(action);
            
            this->m_numActions--;
            emit this->numActionsChanged();
            
            this->save();
            
            return true;
        }
        
        return false;
    }
    
    void Engine::saveAction(Action* action)
    {
        if (action == nullptr) return;
        
        std::sort(action->plans()->getData().begin(), action->plans()->getData().end(), Action::comparePlans);
        
        this->saveToFile(this->getFilePath(*action), action->getFileName() + e_saveFileNameExtension, *action);
    }
    
    Int Engine::numActions()
    {
        return this->m_numActions;
    }
    
    
    QObject* Engine::createPlan(Folder* parentFolder, Int id)
    {
        this->setOccurrencesChanged();
        
        if (id == -1){
            int s = this->m_plans.size();
            for (int i = 0; i < s; i++){
                if (this->m_plans[i] == nullptr) {
                    id = i;
                    break;
                }
            }
        }
        if (id < 0 || id >= this->m_plans.size() || this->m_plans[id] != nullptr) return nullptr;
        
        Plan* newPlan = new Plan();
        
        QQmlEngine::setObjectOwnership(newPlan, QQmlEngine::CppOwnership);
        
        newPlan->setID(id);
        newPlan->setParentFolder(parentFolder);
        
        parentFolder->plans()->push(newPlan);
        
        this->m_plans[id] = newPlan;
        
        this->m_numPlans++;
        emit this->numPlansChanged();
        
        return newPlan;
    }
    
    QObject* Engine::getPlanByID(Int id)
    {
        if (id >= 0 && id < this->m_plans.size()) return this->m_plans[id];
        return nullptr;
    }
    
    bool Engine::movePlan(Plan* plan, Folder* destFolder){
        
        QString oldPath = this->getFilePath(*plan);
        
        destFolder->plans()->push(plan);
        
        QObjectVector* oldFolderVector = plan->parentFolder()->plans();
        oldFolderVector->deleteChildrenOnDestroy = false;
        oldFolderVector->remove(plan);
        oldFolderVector->deleteChildrenOnDestroy = true;
        
        plan->setParentFolder(destFolder);
        
        QString newPath = this->getFilePath(*plan);
        
        QDir dir(oldPath);
        
        return dir.rename(oldPath + plan->getFileName() + e_saveFileNameExtension, newPath + plan->getFileName() + e_saveFileNameExtension);
    }
    
    bool Engine::deletePlan(Plan* plan)
    {   
        if (plan != nullptr){
            
            this->setOccurrencesChanged();
            
            emit this->objectDeleted(plan);
            
            this->deleteFile(this->getFilePath(*plan) + plan->getFileName() + e_saveFileNameExtension);
            
            this->m_plans[plan->id()] = nullptr;
            
            plan->parentFolder()->plans()->remove(plan);
            
            this->m_numPlans--;
            emit this->numPlansChanged();
            
            return true;
        }
        
        return false;
    }
    
    void Engine::savePlan(Plan* plan)
    {
        if (plan == nullptr) return;
        
        //std::sort(plan->objectives()->getData().begin(), plan->objectives()->getData().end(), Plan::compareObjective);
        std::sort(plan->instances()->getData().begin(), plan->instances()->getData().end(), Plan::compareInstance);
        
        this->saveToFile(this->getFilePath(*plan), plan->getFileName() + e_saveFileNameExtension, *plan);
    }
    
    Int Engine::numPlans()
    {
        return this->m_numPlans;
    }
    
    
    QObject* Engine::requestSearchList(bool folders, bool actions, bool plans)
    {
        this->m_searchList.clear();
        
        Int listSize = 0;
        if (folders) listSize += this->m_numFolders;
        if (actions) listSize += this->m_numActions;
        if (plans) listSize += this->m_numPlans;
        
        this->m_searchList.getData().reserve(listSize);
        
        if (folders) {
            for (int i = 0; i < this->m_folders.size(); i++){
                if (this->m_folders[i] != nullptr) this->m_searchList.addEntry(this->m_folders[i]);
            }
        }
        if (actions) {
            for (int i = 0; i < this->m_actions.size(); i++){
                if (this->m_actions[i] != nullptr) this->m_searchList.addEntry(this->m_actions[i]);
            }
        }
        if (plans) {
            for (int i = 0; i < this->m_plans.size(); i++){
                if (this->m_plans[i] != nullptr) this->m_searchList.addEntry(this->m_plans[i]);
            }
        }
        
        return &this->m_searchList;
    }
    
    
    void Engine::print(const QString &msg) 
    {
        qDebug() << msg;
    }
    
    QString Engine::getFilePath(ISavable& savable)
    {
        QString path;
        
        Folder* par = savable.parentFolder();
        while(par != nullptr){
            path = par->getFileName() + path;
            par = par->parentFolder();
        }
        
        return this->savePath + path;
    }
    
    void Engine::saveToFile(const QString& filePath, const QString& fileName, ISavable& savable)
    {
        qDebug() << "saving:" << filePath + fileName;
        QDir dir;
        dir.mkpath(filePath);
        QFile file(filePath + fileName);
        if (file.open(QIODevice::WriteOnly | QIODevice::Truncate | QIODevice::Text)){
            QTextStream outText(&file);
            
            outText << this->encodeParams(savable.getParams());
            
            file.close();
            
            qDebug() << "done.";
        }
        else {
            throw "!!!WARNING: saving failed!!!";
        }
    }
    
    void Engine::loadFromFile(const QString& fileFullPath, ISavable& savable)
    {
        qDebug() << "loading:" << fileFullPath;
        
        QFile file(fileFullPath);
        if (!file.exists()) return;
        if (file.open(QIODevice::ReadOnly | QIODevice::Text)){
            QTextStream inText(&file);
            savable.setParams(this->decodeParams(inText.readAll()));
        }
        file.close();
    }
    
    void Engine::deleteDirectory(const QString& dirPath)
    {
        qDebug() << "deleting:" << dirPath;
        QDir dir(dirPath);
        if (!dir.removeRecursively()) throw "!!!WARNING: deleting failed!!!";
    }
    
    void Engine::deleteFile(const QString& filePath)
    {
        qDebug() << "deleting:" << filePath;
        QFile file(filePath);
        if (!file.remove()) throw "!!!WARNING: deleting failed!!!";
    }
    
    void Engine::loadDirectory(const QString& dirPath, Folder* folder)
    {
        QDir dir(dirPath);
        QStringList subFolderList = dir.entryList(QStringList(e_folderFileNamePrefix + "*"), QDir::NoDotAndDotDot | QDir::Dirs);
        QStringList subActionList = dir.entryList(QStringList(e_actionFileNamePrefix + "*" + e_saveFileNameExtension), QDir::NoDotAndDotDot | QDir::Files);
        QStringList subPlanList = dir.entryList(QStringList(e_planFileNamePrefix + "*" + e_saveFileNameExtension), QDir::NoDotAndDotDot | QDir::Files);
        
        for (QString subFolder:subFolderList){
            Folder* newFolder = static_cast<Folder*>(this->createFolder(folder, subFolder.mid(e_folderFileNamePrefix.length()).toInt()));
            if (newFolder == nullptr) continue;
            
            subFolder = "/" + subFolder;
            
            this->loadFromFile(dirPath + subFolder + e_folderDataFileName + e_saveFileNameExtension, *newFolder);
            
            loadDirectory(dirPath + subFolder, newFolder);
        }
        
        for (QString subAction:subActionList){
            Action* newAction = static_cast<Action*>(this->createAction(folder, subAction.left(subAction.length() - e_saveFileNameExtension.length()).mid(e_actionFileNamePrefix.length()).toInt()));
            if (newAction == nullptr) continue;
            
            subAction = "/" + subAction;
            
            this->loadFromFile(dirPath + subAction, *newAction);
        }
        
        for (QString subPlan:subPlanList){
            Plan* newPlan = static_cast<Plan*>(this->createPlan(folder, subPlan.left(subPlan.length() - e_saveFileNameExtension.length()).mid(e_planFileNamePrefix.length()).toInt()));
            if (newPlan == nullptr) continue;
            
            subPlan = "/" + subPlan;
            
            this->loadFromFile(dirPath + subPlan, *newPlan);
        }
    }
    
    QString Engine::encodeParams(const QVector<QPair<QString, QString>>& params)
    {
        QString outStr;
        QTextStream outText(&outStr);
        
        for (auto param:params){
            outText << "[" << param.first << "]\n";
            outText << ">" << param.second.split('\n').join("\n>");
            outText << "\n\n";
        }
        
        return outStr;
    }
    
    QVector<QPair<QString, QString>> Engine::decodeParams(const QString& str)
    {
        //return empty vector if failed.
        QVector<QPair<QString, QString>> params;
        int ptr = 0, left, right;
        while (true){
            QPair<QString, QString> param;
            
            if ((left = ptr = str.indexOf(QChar('['), ptr)) == -1) break;
            left = ++ptr;
            if ((right = ptr = str.indexOf(QChar(']'), ptr)) == -1) break;
            ptr++;
            
            param.first = str.mid(left, right - left);
            
            QString value = "";
            if ((ptr = str.indexOf(QChar('\n'), ptr)) == -1) break;
            ptr++;
            while (true){
                if (str[ptr] != '>') break;
                left = ++ptr;
                if ((right = ptr = str.indexOf(QChar('\n'), ptr)) == -1) break;
                right = ++ptr;
                
                value += str.mid(left, right - left);
            }
            
            param.second = value.trimmed();
            
            params.push_back(param);
        }
        
        return params;
    }
    
    
    QDateTime Engine::timelineMin()
    {
        return this->m_timelineMin;
    }
    
    QDateTime Engine::setTimelineMin(const QDateTime& time)
    {
        this->m_timelineMin = time;
        emit this->timelineMinChanged();
        return this->m_timelineMin;
    }
    
    QDateTime Engine::timelineMax()
    {
        return this->m_timelineMax;
    }
    
    QDateTime Engine::setTimelineMax(const QDateTime& time)
    {
        this->m_timelineMax = time;
        emit this->timelineMaxChanged();
        return this->m_timelineMax;
    }
    
    QDateTime Engine::planningMax()
    {
        return this->m_planningMax;
    }
    
    QDateTime Engine::setPlanningMax(const QDateTime& time)
    {
        this->m_planningMax = time;
        emit this->planningMaxChanged();
        return this->m_planningMax;
    }
    
    QDateTime Engine::autoplanMax()
    {
        return this->m_autoplanMax;
    }
    
    QDateTime Engine::setAutoplanMax(const QDateTime& time)
    {
        this->m_autoplanMax = time;
        emit this->autoplanMaxChanged();
        return this->m_autoplanMax;
    }
    
    QDateTime Engine::currentTime()
    {
        QDateTime time = QDateTime::currentDateTime();
        time.setTimeSpec(Qt::UTC);
        return time;
    }
    
    QDateTime Engine::dateToTime(Int year, Int month, Int day)
    {
        QDateTime time(QDate(year, month, day));
        time.setTimeSpec(Qt::UTC);
        return time;
    }
    
    QDateTime Engine::stringToTime(const QString& str)
    {
        QDateTime time = QDateTime::fromString(str, e_timeStringFormat);
        time.setTimeSpec(Qt::UTC);
        return time;
    }
    
    QString Engine::timeToString(const QDateTime& time)
    {
        return time.toUTC().toString(e_timeStringFormat);
    }
    
    QString Engine::timeSpanToString(const QDateTime& begin, const QDateTime& end)
    {
        QDateTime beginUTC = begin.toUTC();
        QDate beginDate = beginUTC.date();
        QTime beginTime = beginUTC.time();
        QDateTime endUTC = end.toUTC();
        QDate endDate = endUTC.date();
        QTime endTime = endUTC.time();
        
        QString beginStr = beginUTC.toString(e_timeStringReadFormat);
        QString endStr;
        
        if (beginDate.year() != endDate.year()) endStr = endUTC.toString(e_timeStringReadFormat);
        else if (beginDate.month() != endDate.month()) endStr = endUTC.toString(e_timeStringMonthFormat);
        else if (beginDate.day() != endDate.day()) endStr = endUTC.toString(e_timeStringMonthFormat);
        else if (beginTime.hour() != endTime.hour()) endStr = endUTC.toString(e_timeStringHourFormat);
        else if (beginTime.minute() != endTime.minute()) endStr = endUTC.toString(e_timeStringHourFormat);
        else return beginStr;
        
        return beginStr + " - " + endStr;
    }
    
    QString Engine::timeToStringRead(const QDateTime& time)
    {
        return time.toUTC().toString(e_timeStringReadFormat);
    }
    
    QString Engine::timeToStringReadFull(const QDateTime& time)
    {
        return time.toUTC().toString(e_timeStringReadFullFormat);
    }
    
    QString Engine::minutesToString(Int minutes)
    {
        Int days = minutes / 1440;
        minutes -= days * 1440;
        Int hours = minutes / 60;
        minutes -= hours * 60;
        if (days) return QString::number(days) + " - " + QString::number(hours) + ":" + QString::number(minutes);
        else return QString::number(hours) + ":" + QString::number(minutes);
    }
    
    QDateTime Engine::limitTimePrecision(const QDateTime& _time)
    {
        QDateTime time = _time.toUTC();
        if (time < this->m_timelineMin) time = this->m_timelineMin;
        if (time > this->m_timelineMax) time = this->m_timelineMax;
        QTime dayTime = time.time();
        dayTime.setHMS(dayTime.hour(), dayTime.minute(), 0);
        time.setTime(dayTime);
        return time;
    }
    
    
    QString Engine::encodeMonth(QVector<TimelineMarker*>* month)
    {
        QString outStr;
        QTextStream outText(&outStr);
        
        for (int i = 1; i < month->size(); i++){
            TimelineMarker* marker = month->at(i);
            outText << "[" << this->timeToString(marker->time()) << "]" << (marker->isAuto() ? "A" : "") << "\n";
            outText << ">" << (marker->action() != nullptr ? marker->action()->id() : -1);
            outText << "\n";
        }
        
        return outStr;
    }

    QVector<TimelineMarker*>* Engine::createMonth(Int year, Int month)
    {
        QVector<TimelineMarker*>* newMonth = new QVector<TimelineMarker*>();
        TimelineMarker* monthMarker = new TimelineMarker();
        QQmlEngine::setObjectOwnership(monthMarker, QQmlEngine::CppOwnership);
        monthMarker->setTime(this->dateToTime(year, month, 1));
        //qDebug() << monthMarker->time();
        newMonth->append(monthMarker);
        
        return newMonth;
    }
    
    QVector<TimelineMarker*>* Engine::decodeMonth(const QString& str, Int year, Int month){
        //return nullptr if nothing is in month.
        QVector<TimelineMarker*>* newMonth = this->createMonth(year, month);
        
        //qDebug() << year << month;
        
        int ptr = 0, left, right;
        while (true){
            QDateTime time;
            Action* action;
            bool isAuto = false;
            
            if ((left = ptr = str.indexOf(QChar('['), ptr)) == -1) break;
            left = ++ptr;
            if ((right = ptr = str.indexOf(QChar(']'), ptr)) == -1) break;
            ptr++;
            
            time = this->stringToTime(str.mid(left, right - left));
            if (!time.isValid() || time.date().year() != year || time.date().month() != month) break;
            
            if (str[ptr] == 'A') isAuto = true;
            
            if ((ptr = str.indexOf(QChar('\n'), ptr)) == -1) break;
            ptr++;
            if (str[ptr] != '>') break;
            left = ++ptr;
            if ((right = ptr = str.indexOf(QChar('\n'), ptr)) == -1) break;
            ptr++;
            
            //qDebug() << "huh";
            
            action = static_cast<Action*>(this->getActionByID(str.mid(left, right - left).toInt()));
            
            TimelineMarker* newMarker = new TimelineMarker();
            QQmlEngine::setObjectOwnership(newMarker, QQmlEngine::CppOwnership);
            newMarker->setTime(time);
            newMarker->setAction(action, isAuto);
            newMonth->append(newMarker);
        }
        
        if (newMonth->size() == 1){
            delete newMonth->at(0);
            delete newMonth;
            return nullptr;
        }
        else {
            std::sort(newMonth->begin() + 1, newMonth->end(), compareMarkers);
        }
        
        //qDebug() << newMonth->size();
        
        return newMonth;
    }
    
    Int Engine::monthToKey(QVector<TimelineMarker*>* month)
    {
        const QDate& monthDate = month->at(0)->time().date();
        return monthDate.year() * 12 + monthDate.month() - 1;
    }
    
    void Engine::load()
    {
        qDebug() << "loading...";
                
        this->loadFromFile(this->savePath + e_globalSettingsFileName + e_saveFileNameExtension, this->m_globalSettings);
                
        this->loadDirectory(this->savePath + e_rootFolderFileName, &this->m_rootFolder);
        
        for (Plan* plan:this->m_plans){
            if (plan != nullptr){
                for (QObject* object:plan->objectives()->getData()){
                    Objective* objective = static_cast<Objective*>(object);
                    objective->setAction(static_cast<Action*>(Engine::current()->getActionByID(objective->tempActionID)));
                }
            }
        }
        
        this->setTimelineMin(std::max(this->timeOrigin(), this->currentTime().addYears(-t_maxPastYears)));
        this->setTimelineMax(this->currentTime().addYears(t_maxFutureYears));
        
        QDir timelineDir(this->savePath + e_timelineFileName);
        
        QStringList yearList = timelineDir.entryList(QDir::NoDotAndDotDot | QDir::Dirs, QDir::Name);
        for (QString year:yearList){
            
            Int yearNumber = year.toInt();
            
            if (yearNumber < this->timelineMin().date().year()) continue;
            
            QString yearPath = this->savePath + e_timelineFileName + "/" + year;
            QDir yearDir(yearPath);
            
            QStringList monthList = yearDir.entryList(QStringList("*" + e_saveFileNameExtension), QDir::NoDotAndDotDot | QDir::Files, QDir::Name);
            for (QString month:monthList){
                
                Int monthNumber = month.left(month.length() - e_saveFileNameExtension.length()).toInt();
                if (monthNumber < 1 && monthNumber > 12) continue;
                
                QString monthPath = yearPath + "/" + month;
                
                qDebug() << monthPath;
                
                QFile file(monthPath);
                if (file.open(QIODevice::ReadOnly | QIODevice::Text)){
                    QTextStream inText(&file);
                    QVector<TimelineMarker*>* newMonth = this->decodeMonth(inText.readAll(), yearNumber, monthNumber);
                    if (newMonth != nullptr) this->m_timeline.append(newMonth);
                }
                
                file.close();
            }
        }
        
        std::sort(this->m_timeline.begin(), this->m_timeline.end(), compareMonths);
        
        //qDebug() << binarySearchMonth(this->dateToTime(2016, 7, 1));
        
        this->refresh();
        
        this->occurrences();
        
        //qDebug() << this->m_conditionsImpossible;
        
        qDebug() << "done.";
    }
    
    void Engine::save()
    {
        qDebug() << "saving...";
        
        this->saveToFile(this->savePath, e_globalSettingsFileName + e_saveFileNameExtension, this->m_globalSettings);
        
        if (this->m_monthModified.size()){
        
            for (Int key:this->m_monthModified.keys()){
                
                Int yearNumber = key / 12;
                Int monthNumber = key - yearNumber * 12 + 1;
                
                QString filePath = this->savePath + e_timelineFileName + "/" + QString::number(yearNumber);
                QString fileName = QString::number(monthNumber) + e_saveFileNameExtension;
                if (monthNumber < 10) fileName = "0" + fileName;
                fileName = "/" + fileName;
                
                qDebug() << (filePath + fileName);
                
                QDir dir;
                dir.mkpath(filePath);
                QFile file(filePath + fileName);
                
                QVector<TimelineMarker*>* month = this->m_monthModified[key];
                
                if (file.open(QIODevice::WriteOnly | QIODevice::Truncate | QIODevice::Text)){
                    QTextStream outText(&file);
                    
                    if (month != nullptr) outText << this->encodeMonth(this->m_monthModified[key]);
                    
                    file.close();
                }
                else {
                    throw "!!!WARNING: saving failed!!!";
                }
                
                /*
                if (month == nullptr){ {
                    if (file.exists()) {
                        qDebug() << "file deleted.";
                        if (!file.remove()) throw "!!!WARNING: deleting failed!!!";
                    }
                }
                */
            }
            
            this->m_monthModified.clear();
        }
        
        qDebug() << "done.";
    }
    
    bool Engine::compareMonth(const QDateTime& time, QVector<TimelineMarker*>* month)
    {
        return time < month->at(0)->time();
    }
    
    bool Engine::compareMonths(QVector<TimelineMarker*>* a, QVector<TimelineMarker*>* b)
    {
        return a->at(0)->time() < b->at(0)->time();
    }
    
    Int Engine::binarySearchMonth(const QDateTime& time)
    {
        //find the index of first month before or containing time. return -1 if before first month.
        return std::upper_bound(this->m_timeline.begin(), this->m_timeline.end(), time, compareMonth) - this->m_timeline.begin() - 1;
    }
    
    bool Engine::compareMarker(const QDateTime& time, TimelineMarker* marker)
    {
        return time < marker->time();
    }
    
    bool Engine::compareMarkers(TimelineMarker* a, TimelineMarker* b)
    {
        return a->time() < b->time();
    }
    
    Int Engine::binarySearchMarker(QVector<TimelineMarker*>* month, const QDateTime& time)
    {
        //find the index of first marker in month before or equal to time. return 0 when before first marker.
        return std::upper_bound(month->begin()+1, month->end(), time, compareMarker) - month->begin() - 1;
    }
    
    QObject* Engine::createMarker(const QDateTime& _time, Action* action, bool isAuto)
    {
        this->setSessionsChanged();
        
        QDateTime time = this->limitTimePrecision(_time);
        
        Int monthIndex = this->binarySearchMonth(time);
        bool monthExists = true;
        
        QVector<TimelineMarker*>* month = nullptr;
        
        if (monthIndex == -1) monthExists = false;
        else {
            month = this->m_timeline[monthIndex];
            
            const QDate& monthDate = month->at(0)->time().date();
            if (monthDate.year() != time.date().year() || monthDate.month() != time.date().month()) monthExists = false;
        }
        
        if (!monthExists){
            month = this->createMonth(time.date().year(), time.date().month());
            monthIndex++;
            this->m_timeline.insert(monthIndex, month);
        }
        
        Int markerIndex = this->binarySearchMarker(month, time);
        
        bool markerExists = true;
        
        TimelineMarker* marker = nullptr;
        
        if (markerIndex == 0) markerExists = false;
        else {
            marker = month->at(markerIndex);
            
            if (marker->time() != time) markerExists = false;
        }
        
        if (!markerExists){
            marker = new TimelineMarker();
            QQmlEngine::setObjectOwnership(marker, QQmlEngine::CppOwnership);
            marker->setTime(time);
            markerIndex++;
            month->insert(markerIndex, marker);
        }
        
        marker->setAction(action, isAuto);
        
        this->m_monthModified[this->monthToKey(month)] = month;
        
        this->mergeMarkers(time);
        
        return marker;
    }
    
    QObject* Engine::getMarker(const QDateTime& time)
    {
        if (!this->m_timeline.size()) return nullptr;
        
        Int monthIndex = this->binarySearchMonth(time);
        if (monthIndex == -1) {
            this->m_currentMonthIndex = 0;
            this->m_currentMarkerIndex = 0;
            return nullptr;
        }
        QVector<TimelineMarker*>* month = this->m_timeline[monthIndex];
        Int markerIndex = this->binarySearchMarker(month, time);
        if (markerIndex == 0) {
            if (monthIndex == 0) {
                this->m_currentMonthIndex = 0;
                this->m_currentMarkerIndex = 0;
                return nullptr;
            }
            this->m_currentMonthIndex = monthIndex - 1;
            this->m_currentMarkerIndex = this->m_timeline[monthIndex-1]->size() - 1;
            //qDebug() << "did this shit EVER happen";
            return this->m_timeline[monthIndex-1]->last();
        }
        this->m_currentMonthIndex = monthIndex;
        this->m_currentMarkerIndex = markerIndex;
        //qDebug() << this->m_currentMonthIndex << this->m_currentMarkerIndex << this->m_timeline[this->m_currentMonthIndex]->size() << this->m_timeline.size() << "did this shit EVER happen MOTHERFUCKA~";
        return month->at(markerIndex);
    }
    
    QObject* Engine::getMarkerAfter(const QDateTime& time)
    {
        this->getMarker(time);
        return this->getNextMarker();
    }
    
    QObject* Engine::getPrevMarker()
    {
        if (!this->m_timeline.size()) return nullptr;
        
        this->m_currentMarkerIndex--;
        if (this->m_currentMarkerIndex < 1) {
            this->m_currentMonthIndex--;
            if (this->m_currentMonthIndex < 0) {
                this->m_currentMonthIndex = 0;
                this->m_currentMarkerIndex = 0;
                return nullptr;
            }
            this->m_currentMarkerIndex = this->m_timeline[this->m_currentMonthIndex]->size() - 1;
        }
        return this->m_timeline[this->m_currentMonthIndex]->at(this->m_currentMarkerIndex);
    }
    
    QObject* Engine::getNextMarker()
    {
        if (!this->m_timeline.size()) return nullptr;
        
        this->m_currentMarkerIndex++;
        if (this->m_currentMarkerIndex >= this->m_timeline[this->m_currentMonthIndex]->size()) {
            this->m_currentMonthIndex++;
            if (this->m_currentMonthIndex >= this->m_timeline.size()) {
                this->m_currentMonthIndex = this->m_timeline.size() - 1;
                this->m_currentMarkerIndex = this->m_timeline.last()->size();
                return nullptr;
            }
            this->m_currentMarkerIndex = 1;
        }
        return this->m_timeline[this->m_currentMonthIndex]->at(this->m_currentMarkerIndex);
    }
    
    void Engine::deleteMarker(TimelineMarker* marker)
    {
        this->setSessionsChanged();
        
        QDateTime time = marker->time();
        
        Int monthIndex = this->binarySearchMonth(marker->time());
        QVector<TimelineMarker*>* month = this->m_timeline[monthIndex];
        Int markerIndex = this->binarySearchMarker(month, marker->time());
        month->remove(markerIndex);
        delete marker;
        
        if (month->size() == 1){
            
            this->m_timeline.remove(monthIndex);
            delete month->at(0);
            delete month;
            
            this->m_monthModified[this->monthToKey(month)] = nullptr;
        }
        else {
            this->m_monthModified[this->monthToKey(month)] = month;
        }
        
        this->mergeMarkers(time);
    }
    
    void Engine::moveMarker(TimelineMarker* marker, const QDateTime& _time)
    {
        this->setSessionsChanged();
        
        QDateTime time = this->limitTimePrecision(_time);
        
        if (marker->time() != time){
            QDateTime oldTime = marker->time();
            
            this->m_mergeDisabled = true;
            
            createMarker(time, marker->action(), marker->isAuto());
            deleteMarker(marker);
            
            this->m_mergeDisabled = false;
            
            this->mergeMarkers(oldTime);
            this->mergeMarkers(time);
        }
    }
    
    void Engine::setMarkerAction(TimelineMarker* marker, Action* action, bool isAuto)
    {
        this->setSessionsChanged();
        
        marker->setAction(action, isAuto);
        
        Int monthIndex = this->binarySearchMonth(marker->time());
        QVector<TimelineMarker*>* month = this->m_timeline[monthIndex];
        this->m_monthModified[this->monthToKey(month)] = month;
        
        this->mergeMarkers(marker->time());
    }
    
    void Engine::mergeMarkers(const QDateTime& time)
    {
        if (this->m_mergeDisabled) return;
        
        //print("merging");
        
        TimelineMarker* marker = static_cast<TimelineMarker*>(this->getMarker(time));
        if (marker == nullptr) {
            TimelineMarker* markerNext = static_cast<TimelineMarker*>(this->getNextMarker());
            if (markerNext != nullptr && markerNext->action() == nullptr) this->deleteMarker(markerNext);
            return;
        }
        
        TimelineMarker* markerPrev = static_cast<TimelineMarker*>(this->getPrevMarker());
        this->getNextMarker();
        TimelineMarker* markerNext = static_cast<TimelineMarker*>(this->getNextMarker());
        
        /*
        if (markerPrev != nullptr && markerPrev->action() == nullptr && markerPrev->time().secsTo(marker->time()) < t_cleanUpThresholdSec) this->deleteMarker(markerPrev);
        else if ((markerPrev == nullptr && marker->action() == nullptr) || marker->action() == markerPrev->action() || (markerNext != nullptr && marker->action() == nullptr && marker->time().secsTo(markerNext->time()) < t_cleanUpThresholdSec)) this->deleteMarker(marker);
        else if (markerNext != nullptr && marker->action() == markerNext->action()) this->deleteMarker(markerNext);
        */
        
        if ((markerPrev == nullptr && marker->action() == nullptr) || marker->mergable(markerPrev)) this->deleteMarker(marker);
        else if (markerNext != nullptr && marker->mergable(markerNext)) this->deleteMarker(markerNext);
    }
    
    void Engine::refresh()
    {
        this->setTimelineMax(this->currentTime().addYears(t_maxFutureYears));
        
        this->setPlanningMax(this->currentTime().addDays(t_maxPlanningDays));
        this->setAutoplanMax(this->currentTime().addDays(t_maxAutoplanDays));
        
        this->setTimeChanged();
    }
    
    bool Engine::drawTimelineRange(Action* action, const QDateTime& _start, const QDateTime& _end, bool isAuto)
    {
        
        QDateTime start = this->limitTimePrecision(_start);
        QDateTime end = this->limitTimePrecision(_end);
        
        //if (start.secsTo(end) < t_cleanUpThresholdSec) return false;
        
        if (end <= start) return false;
        
        this->setSessionsChanged();
        
        TimelineMarker* endMarker = static_cast<TimelineMarker*>(this->getMarker(end));
        Action* endAction = nullptr;
        bool endIsAuto = false;
        if (endMarker != nullptr) {
            endAction = endMarker->action();
            endIsAuto = endMarker->isAuto();
        }
        
        this->m_mergeDisabled = true;
        
        this->createMarker(start, action, isAuto);
        
        TimelineMarker* marker = static_cast<TimelineMarker*>(this->getMarkerAfter(start));
        while (marker != nullptr && marker->time() < end){
            QDateTime time = marker->time();
            this->deleteMarker(marker);
            marker = static_cast<TimelineMarker*>(this->getMarkerAfter(time));
        }
        
        this->createMarker(end, endAction, endIsAuto);
        
        this->m_mergeDisabled = false;
        
        this->mergeMarkers(start);
        
        return true;
    }
    
    struct TimeInterval
    {
        QDateTime start, end;
        TimeInterval(const QDateTime& start, const QDateTime& end){
            this->start = start;
            this->end = end;
        };
        bool operator<(const TimeInterval& b) const
        {
            return this->end < b.end;
        };
        bool operator==(const TimeInterval& b) const
        {
            return this->end == b.end;
        };
    };
    
    void Engine::autoPlan(bool freeSessionsOnly)
    {
        if (!this->m_autoplanDesynced) {
            qDebug() << "Auto Plan Already Synced.";
            return;
        }
            
        std::chrono::steady_clock::time_point _begin = std::chrono::steady_clock::now();
        
        if (!freeSessionsOnly) this->eraseAutoPlan();
        
            
        QObjectVector& occurrenceList = *this->occurrences();
        
        
        
        //check condition of every objective of every occurrence
        QDateTime cuttingTime = this->limitTimePrecision(Engine::currentTime());
        
        
        //check conflict and write to global.
        //this->m_impossibleConditions.clear();
        
        QVector<SimpleOccurrence*> ranges;
        
        for (QObject* object:occurrenceList.getData()){
            Occurrence* occurrence = static_cast<Occurrence*>(object);
            
            if (occurrence->startTime() >= this->m_autoplanMax) continue;
            
            //qDebug() << occurrence->plan()->name() << occurrence->minRequirement();
            
            if (occurrence->minRequirement()){
                if (occurrence->plan()->completionMode() == 0){
                    int l = occurrence->status.length();
                    for (int i = 0; i < l; i++){
                        Objective* objective = static_cast<Objective*>(occurrence->plan()->objectives()->at(i));
                        SimpleOccurrence* range = new SimpleOccurrence(std::max(occurrence->startTime(), cuttingTime), occurrence->endTime(), std::max(0, objective->length() - occurrence->status[i]), occurrence, objective->action());
    
                        ranges.append(range);
                        
                        //qDebug() << range->action << range->requirement << range->start;
                    }
                }
                else if (occurrence->plan()->completionMode() == 1){
                    int l = occurrence->status.length();
                    for (int i = 0; i < l; i++){
                        Objective* objective = static_cast<Objective*>(occurrence->plan()->objectives()->at(i));
                        if (std::max(0, objective->length() - occurrence->status[i]) == occurrence->minRequirement()){
                            SimpleOccurrence* range = new SimpleOccurrence(std::max(occurrence->startTime(), cuttingTime), occurrence->endTime(), occurrence->minRequirement(), occurrence, objective->action());
        
                            ranges.append(range);
                            
                            //qDebug() << range->action << range->requirement << range->start;
                            
                            break;
                        }
                    }
                }
            }
        }
        
        if (ranges.size()) {
        
        
            std::sort(ranges.begin(), ranges.end(), compareSimpleOccurrences);
            
            std::set<TimeInterval> freeRanges;
            
            //scan for free sessions in the future
            TimelineMarker* markerPrev = static_cast<TimelineMarker*>(this->getMarker(cuttingTime));
            const QDateTime& futureBound = ranges.last()->end;
            while (true){
                TimelineMarker* marker = static_cast<TimelineMarker*>(this->getNextMarker());
                if (markerPrev == nullptr || markerPrev->action() == nullptr){
                    QDateTime rangeStart = markerPrev == nullptr ? cuttingTime : std::max(cuttingTime, markerPrev->time());
                    QDateTime rangeEnd = marker == nullptr ? futureBound : std::min(marker->time(), futureBound);
                    freeRanges.insert(TimeInterval(rangeStart, rangeEnd));
                }
                if (marker == nullptr || marker->time() >= futureBound) break;
                markerPrev = marker;
            }
            
            //qDebug() << "here";
            
            freeRanges.insert(TimeInterval(futureBound.addSecs(60), futureBound.addSecs(120)));
            
            for (SimpleOccurrence* range:ranges){
                while (range->requirement){
                    std::set<TimeInterval>::iterator firstFreeIt = freeRanges.upper_bound(TimeInterval(this->timeOrigin(), range->start));
                    TimeInterval firstFree = *firstFreeIt;
                    if (firstFree.start >= range->end) {
                        //this->m_impossibleConditions.push(range->occurrence);
                        break;
                    }
                    else if (firstFree.start < range->start){
                        freeRanges.erase(firstFreeIt);
                        freeRanges.insert(TimeInterval(firstFree.start, range->start));
                        freeRanges.insert(TimeInterval(range->start, firstFree.end));
                        continue;
                    }
                    else {
                        if (firstFree.start > range->start){
                            range->start = firstFree.start;
                        }
                        Int rangeLength = range->start.secsTo(range->end) / 60;
                        if (rangeLength < range->requirement){
                            range->requirement = rangeLength;
                            //this->m_impossibleConditions.push(range->occurrence);
                        }
                        Int length = firstFree.start.secsTo(firstFree.end) / 60;
                        if (length <= range->requirement){
                            this->drawTimelineRange(range->action, firstFree.start, std::min(this->m_autoplanMax, firstFree.end), true);
                            range->start = firstFree.end;
                            range->requirement -= length;
                            freeRanges.erase(firstFreeIt);
                            continue;
                        }
                        else {
                            this->drawTimelineRange(range->action, firstFree.start, std::min(this->m_autoplanMax, firstFree.start.addSecs((Int64)range->requirement * 60)), true);
                            freeRanges.erase(firstFreeIt);
                            freeRanges.insert(TimeInterval(firstFree.start.addSecs((Int64)range->requirement * 60), firstFree.end));
                            break;
                        }
                    }
                }
                //if (this->m_impossibleCondition != nullptr) break;
            }
            
            for (SimpleOccurrence* range:ranges){
                delete range;
            }
            
            /*
            for (QObject* object:occurrenceList.getData()){
                Occurrence* occurrence = static_cast<Occurrence*>(object);
                qDebug() << occurrence->startTime() << occurrence->endTime() << occurrence->plan()->name();
                for (int i = 0; i < occurrence->status.size(); i++){
                    qDebug() << (static_cast<Objective*>(occurrence->plan()->objectives()->at(i))->action()->name()) << this->minutesToString(occurrence->status[i]);
                }
            }
            */ 
        
        }
        
        if (!freeSessionsOnly) this->m_autoplanDesynced = false;
        
        std::chrono::steady_clock::time_point _end = std::chrono::steady_clock::now();
        
        qDebug() << "Time Elapsed for Auto Plan = " << std::chrono::duration_cast<std::chrono::microseconds>(_end - _begin).count();
    }
    
    void Engine::eraseAutoPlan()
    {
        if (this->m_timeline.size() && this->m_timeline[0]->size() > 1){
            QDateTime cuttingTime = Engine::currentTime();
            
            TimelineMarker* marker = static_cast<TimelineMarker*>(this->getMarker(cuttingTime));
            if (marker != nullptr && marker->isAuto()){
                this->createMarker(cuttingTime, nullptr, false);
            }
            
            marker = static_cast<TimelineMarker*>(this->getMarkerAfter(cuttingTime));
            while (marker != nullptr && marker->time() < this->m_planningMax){
                //qDebug() << marker;
                if (marker->isAuto()) {
                    QDateTime time = marker->time();
                    this->setMarkerAction(marker, nullptr, false);
                    marker = static_cast<TimelineMarker*>(this->getMarkerAfter(time));
                }
                else {
                    marker = static_cast<TimelineMarker*>(this->getNextMarker());
                }
            }
        }
    }
    
    
    void Engine::setOccurrencesChanged()
    {
        this->m_occurrencesChanged = this->m_autoplanDesynced = true;
    }
    
    void Engine::setTimeChanged()
    {
        this->m_timeChanged = this->m_autoplanDesynced = true;
    }
    
    void Engine::setSessionsChanged()
    {
        this->m_sessionsChanged = this->m_autoplanDesynced = true;
    }
    
    Int Engine::toMonthNumber(const QDate& date)
    {
        return date.year() * 12 + date.month() - 1;
    }

    QDate Engine::fromMonthNumber(Int monthNumber)
    {
        Int year = monthNumber / 12;
        Int month = monthNumber - year * 12 + 1;
        return QDate(year, month, 1);
    }
    
    bool Engine::compareOccurrences(QObject* a, QObject* b)
    {
        //return static_cast<Occurrence*>(a)->endTime() < static_cast<Occurrence*>(b)->endTime() || (static_cast<Occurrence*>(a)->endTime() == static_cast<Occurrence*>(b)->endTime() && static_cast<Occurrence*>(a)->startTime() < static_cast<Occurrence*>(b)->startTime());
        return static_cast<Occurrence*>(a)->startTime() < static_cast<Occurrence*>(b)->startTime();
    }
    
    QObjectVector* Engine::occurrences()
    {
        if (this->m_occurrencesChanged){
            //updateOccurrences
            this->extractAllOccurrences(Engine::currentTime(), this->planningMax(), this->m_occurrences, false);
            
            this->checkConditions(this->m_occurrences);
            
            this->m_sessionsChanged = false;
            
            this->m_occurrencesChanged = false;
        }
        else if (this->m_timeChanged){
            this->extractAllOccurrences(Engine::currentTime(), this->planningMax(), this->m_occurrences, true);
            
            this->checkConditions(this->m_occurrences);
            
            this->m_sessionsChanged = false;
            
            this->m_timeChanged = false;
        }
        else if (this->m_sessionsChanged){
            //checkConditions
            this->checkConditions(this->m_occurrences);
            
            this->m_sessionsChanged = false;
        }
        
        if (this->m_impossibleConditions.size()) {
            qDebug() << "Impossible Conditions: ";
            for (QObject* object:this->m_impossibleConditions.getData()) {
                Occurrence* occurrence = static_cast<Occurrence*>(object);
                qDebug() << occurrence->plan()->name() << occurrence->startTime();
            }
        }
        
        return &this->m_occurrences;
    }
    
    void Engine::extractAllOccurrences(QDateTime begin, QDateTime end, QObjectVector& output, bool pushPopOnly)
    {
        if (!output.size()) pushPopOnly = false;
        //regenerate list
        
        if (!pushPopOnly) output.clear();
        
        begin = limitTimePrecision(begin);
        end = limitTimePrecision(end);
        
        Int64 beginMSec = begin.toMSecsSinceEpoch();
        /*
        QDate beginDate = begin.date();
        //Int beginMonth = this->toMonthNumber(beginDate);
        QTime beginTime = begin.time();
        
        Int64 endMSec = end.toMSecsSinceEpoch();
        QDate endDate = end.date();
        //Int endMonth = this->toMonthNumber(endDate);
        QTime endTime = end.time();
        */
        
        QDateTime oldEnd;
        if (pushPopOnly) {
            oldEnd = static_cast<Occurrence*>(output.getData().last())->startTime();
            
            for (int i = 0; i < output.size(); ++i){
                Occurrence* occurrence = static_cast<Occurrence*>(output.at(i));
                if (occurrence->endTime() <= begin) {
                    output.remove(i);
                    --i;
                }
                else if (occurrence->startTime() >= begin) break;
            }
        }
        
        for (Plan* plan:this->m_plans){
            this->extractOccurrence(plan, begin, beginMSec, end, output, pushPopOnly, oldEnd);
        }
        
        for (Action* action:this->m_actions){
            if (action != nullptr){
                for (QObject* object:action->plans()->getData()){
                    Plan* plan = static_cast<Plan*>(object);
                    this->extractOccurrence(plan, begin, beginMSec, end, output, pushPopOnly, oldEnd);
                }
            }
        }
        
        std::sort(output.getData().begin(), output.getData().end(), compareOccurrences);
    }
    
    void Engine::extractOccurrence(Plan* plan, const QDateTime& begin, const Int64& beginMSec, const QDateTime& end, QObjectVector& output, bool pushPopOnly, const QDateTime& oldEnd)
    {
        if (plan != nullptr){
            
            Int numObjectives = plan->objectives()->size();
            
            if (!numObjectives) return;
            
            for (QObject* object:plan->instances()->getData()){
                Instance* instance = static_cast<Instance*>(object);
                
                Int64 length = instance->startTime().msecsTo(instance->endTime());
                Int jumpMethod = 0;
                //Int64 repeatGap = 0;
                
                QDate instanceStartDate = instance->startTime().date();
                Int instanceStartMonth = this->toMonthNumber(instanceStartDate);
                QTime instanceStartTime = instance->startTime().time();
                
                QDateTime firstStartTime;
                if (instance->repeatMode() == "days"){
                    Int64 gap = c_dayMSec * instance->repeatParam();
                    Int64 diff = beginMSec - length - instance->startTime().toMSecsSinceEpoch();
                    Int64 jumps = diff / gap + 1;
                    diff = jumps * gap;
                    firstStartTime = instance->startTime().addMSecs(diff);
                    
                    jumpMethod = 1;
                }
                else if (instance->repeatMode() == "months"){
                    Int gap = instance->repeatParam();
                    
                    QDateTime minBegin = begin.addMSecs(-length);
                    Int diff = this->toMonthNumber(minBegin.date()) - instanceStartMonth;
                    Int jumps = diff / gap;
                    if (jumps * gap < diff) jumps++;
                    diff = jumps * gap;
                    
                    QDate newMonthDate = this->fromMonthNumber(instanceStartMonth + diff);
                    newMonthDate.setDate(newMonthDate.year(), newMonthDate.month(), std::min(instanceStartDate.day(), newMonthDate.daysInMonth()));
                    
                    QDateTime result(newMonthDate, instanceStartTime, Qt::UTC);
                    if (result <= minBegin) {
                        newMonthDate = newMonthDate.addMonths(gap);
                        newMonthDate.setDate(newMonthDate.year(), newMonthDate.month(), std::min(instanceStartDate.day(), newMonthDate.daysInMonth()));
                        result.setDate(newMonthDate);
                    }
                    firstStartTime = result;
                    
                    jumpMethod = 2;
                }
                else if (instance->repeatMode() == "years"){
                    Int gap = instance->repeatParam();
                    
                    QDateTime minBegin = begin.addMSecs(-length);
                    Int diff = minBegin.date().year() - instanceStartDate.year();
                    Int jumps = diff / gap;
                    if (jumps * gap < diff) jumps++;
                    diff = jumps * gap;
                    
                    QDate newMonthDate(instanceStartDate.year() + diff, instanceStartDate.month(), 1);
                    newMonthDate.setDate(newMonthDate.year(), newMonthDate.month(), std::min(instanceStartDate.day(), newMonthDate.daysInMonth()));
                    
                    QDateTime result(newMonthDate, instanceStartTime, Qt::UTC);
                    if (result <= minBegin) {
                        newMonthDate = newMonthDate.addYears(gap);
                        newMonthDate.setDate(newMonthDate.year(), newMonthDate.month(), std::min(instanceStartDate.day(), newMonthDate.daysInMonth()));
                        result.setDate(newMonthDate);
                    }
                    firstStartTime = result;
                    
                    jumpMethod = 3;
                }
                if (instance->endTime() > begin || instance->repeatMode() == "none"){
                    firstStartTime = instance->startTime();
                }
                
                if (instance->repeatMode() != "none"){
                    bool isForever = instance->isForever();
                    while (firstStartTime < end && (isForever || firstStartTime <= instance->repeatUntil())){
                        //make an occurrence
                        //qDebug() << firstStartTime << firstStartTime.addMSecs(length) << (static_cast<Plan*>(instance->plan())->name());
                        Occurrence* occurrence = new Occurrence();
                        QQmlEngine::setObjectOwnership(occurrence, QQmlEngine::CppOwnership);
                        
                        occurrence->setStartTime(firstStartTime);
                        occurrence->setEndTime(firstStartTime.addMSecs(length));
                        occurrence->setPlan(plan);
                        occurrence->setInstance(instance);
                        occurrence->status.fill(0, numObjectives);
                        occurrence->statusNow.fill(0, numObjectives);
                        
                        if (!pushPopOnly || occurrence->startTime() > oldEnd) output.push(occurrence);
                        
                        //next
                        
                        if (jumpMethod == 1){
                            firstStartTime = firstStartTime.addDays(instance->repeatParam());
                        }
                        else if (jumpMethod == 2){
                            QDate firstStartDate = firstStartTime.date().addMonths(instance->repeatParam());
                            firstStartDate.setDate(firstStartDate.year(), firstStartDate.month(), std::min(instanceStartDate.day(), firstStartDate.daysInMonth()));
                            firstStartTime.setDate(firstStartDate);
                        }
                        else if (jumpMethod == 3){
                            QDate firstStartDate = firstStartTime.date().addYears(instance->repeatParam());
                            firstStartDate.setDate(firstStartDate.year(), firstStartDate.month(), std::min(instanceStartDate.day(), firstStartDate.daysInMonth()));
                            firstStartTime.setDate(firstStartDate);
                        }
                    }
                }
                else if (firstStartTime.addMSecs(length) > begin && firstStartTime < end) {
                    //make an occurrence
                    //qDebug() << firstStartTime << firstStartTime.addMSecs(length) << (static_cast<Plan*>(instance->plan())->name());
                    Occurrence* occurrence = new Occurrence();
                    QQmlEngine::setObjectOwnership(occurrence, QQmlEngine::CppOwnership);
                    
                    occurrence->setStartTime(firstStartTime);
                    occurrence->setEndTime(firstStartTime.addMSecs(length));
                    occurrence->setPlan(plan);
                    occurrence->setInstance(instance);
                    occurrence->status.fill(0, numObjectives);
                    occurrence->statusNow.fill(0, numObjectives);
                    
                    if (!pushPopOnly || occurrence->startTime() > oldEnd) output.push(occurrence);
                }
            }
        }
    }
    
    /*
    void Engine::checkConflicts()
    {
        
    }
    */
    
    bool Engine::compareMissionPoints(MissionPoint* a, MissionPoint* b)
    {
        return a->time < b->time;
    }
    
    bool Engine::compareSimpleOccurrences(SimpleOccurrence* a, SimpleOccurrence* b)
    {
        return a->end < b->end || (a->end == b->end && (a->start < b->start || (a->start == b->start && a->requirement < b->requirement)));
    }
    
    void Engine::checkConditions(QObjectVector& occurrenceList)
    {
        std::chrono::steady_clock::time_point _begin = std::chrono::steady_clock::now();
        
        
        //check condition of every objective of every occurrence
        QDateTime cuttingTime = this->limitTimePrecision(Engine::currentTime());
        
        QVector<MissionPoint*> points;
        
        for (QObject* object:occurrenceList.getData()){
            Occurrence* occurrence = static_cast<Occurrence*>(object);
            
            occurrence->reset();
            
            Plan* plan = occurrence->plan();
            
            int l = plan->objectives()->size();
            for (int i = 0; i < l; i++){
                
                MissionPoint* start = new MissionPoint();
                
                start->objective = static_cast<Objective*>(plan->objectives()->at(i));
                start->progress = 0;
                start->objectiveIndex = i;
                start->occurrence = occurrence;
                start->start = nullptr;
                start->time = occurrence->startTime();
                
                points.append(start);
                
                
                MissionPoint* end = new MissionPoint();
                
                end->objective = start->objective;
                end->progress = 0;
                end->objectiveIndex = i;
                end->occurrence = occurrence;
                end->start = start;
                end->time = occurrence->endTime();
                
                points.append(end);
                
                //*
                if (occurrence->startTime() < cuttingTime && occurrence->endTime() > cuttingTime){
                    
                    MissionPoint* cut = new MissionPoint();
                    
                    cut->objective = start->objective;
                    cut->progress = 0;
                    cut->objectiveIndex = i;
                    cut->occurrence = occurrence;
                    cut->start = start;
                    end->start = cut;
                    cut->time = cuttingTime;
                    
                    points.append(cut);
                    
                }
                //*/
                
            }
        }
        
        if (!points.size()) return;
        
        
        std::sort(points.begin(), points.end(), compareMissionPoints);
        
        Int accumulator[e_maxID];
        memset(accumulator, 0, sizeof(accumulator));
        
        QDateTime prevTime = points[0]->time;
        TimelineMarker* markerBefore = static_cast<TimelineMarker*>(this->getMarker(prevTime));
        TimelineMarker* markerAfter = static_cast<TimelineMarker*>(this->getNextMarker());
        
        if (markerBefore != markerAfter) {
            for (MissionPoint* point:points){
                const QDateTime& curTime = point->time;
                while(prevTime < curTime){
                    //increment the accumulator storing each action done time since first point to current point by going through each marker in between.
                    //remember to interpolate between markers
                    //if skipping over a month, use cache just like the below method.
                    Int amount = 0, id = -1;
                    
                    if (markerBefore != nullptr && markerBefore->action() != nullptr) id = markerBefore->action()->id();
                    
                    if (markerAfter == nullptr || markerAfter->time() > curTime){
                        amount = prevTime.secsTo(curTime) / 60;
                        
                        prevTime = curTime;
                    }
                    else {
                        amount = prevTime.secsTo(markerAfter->time()) / 60;
                        
                        prevTime = markerAfter->time();
                        markerBefore = markerAfter;
                        markerAfter = static_cast<TimelineMarker*>(this->getNextMarker());
                    }
                    if (id >= 0) accumulator[id] += amount;
                }
                
                //get the time done since first point for THAT action and store it in the point.
                point->progress = accumulator[point->objective->action()->id()];
                
                //qDebug() << point->time << point->progress << point->objective->action()->name();
                
                //if its end point, find its start point by pointer, calculate difference, and write status to the corresponding objective index in the occurrence.
                if (point->start != nullptr){
                    
                    //qDebug() << point->occurrence->plan()->name() << point->progress << point->start->progress << point->objective->length() << point->occurrence->status[point->objectiveIndex];
                    
                    Int amount = point->progress - point->start->progress;
                    
                    point->occurrence->status[point->objectiveIndex] += amount;
                    
                    if (point->time > cuttingTime){
                        point->occurrence->setMinRequirement(std::max(0, point->objective->length() - point->occurrence->status[point->objectiveIndex]));
                        /*
                        SimpleOccurrence* range = new SimpleOccurrence();
                        
                        range->start = point->start->time;
                        range->end = point->time;
                        range->requirement = point->objective->length() - point->occurrence->status[point->objectiveIndex];
                        
                        ranges.append(range);
                        */
                    }
                    else point->occurrence->statusNow[point->objectiveIndex] += amount;
                    
                    //point->occurrence->status[point->objectiveIndex] += point->progress - point->start->progress;
                    
                }
            }
        }
        
        for (MissionPoint* point:points){
            delete point;
        }
        
        
        //check conflict and write to global.
        this->m_impossibleConditions.clear();
        
        QVector<SimpleOccurrence*> ranges;
        
        for (QObject* object:occurrenceList.getData()){
            Occurrence* occurrence = static_cast<Occurrence*>(object);
            
            //qDebug() << occurrence->plan()->name() << occurrence->minRequirement();
            occurrence->updateProgress();
            
            if (occurrence->minRequirement()){
                SimpleOccurrence* range = new SimpleOccurrence(std::max(occurrence->startTime(), cuttingTime), occurrence->endTime(), occurrence->minRequirement(), occurrence);
                
                ranges.append(range);
            }
        }
        
        if (!ranges.size()) return;
        
        
        std::sort(ranges.begin(), ranges.end(), compareSimpleOccurrences);
        
        std::set<TimeInterval> freeRanges;
        
        //scan for free sessions in the future
        TimelineMarker* markerPrev = static_cast<TimelineMarker*>(this->getMarker(cuttingTime));
        const QDateTime& futureBound = ranges.last()->end;
        while (true){
            TimelineMarker* marker = static_cast<TimelineMarker*>(this->getNextMarker());
            if (markerPrev == nullptr || markerPrev->action() == nullptr){
                QDateTime rangeStart = markerPrev == nullptr ? cuttingTime : std::max(cuttingTime, markerPrev->time());
                QDateTime rangeEnd = marker == nullptr ? futureBound : std::min(marker->time(), futureBound);
                freeRanges.insert(TimeInterval(rangeStart, rangeEnd));
            }
            if (marker == nullptr || marker->time() >= futureBound) break;
            markerPrev = marker;
        }
        
        freeRanges.insert(TimeInterval(futureBound.addSecs(60), futureBound.addSecs(120)));
        
        for (SimpleOccurrence* range:ranges){
            while (range->requirement){
                std::set<TimeInterval>::iterator firstFreeIt = freeRanges.upper_bound(TimeInterval(this->timeOrigin(), range->start));
                TimeInterval firstFree = *firstFreeIt;
                if (firstFree.start >= range->end) {
                    this->m_impossibleConditions.push(range->occurrence);
                    range->occurrence->setImpossible(true);
                    break;
                }
                else if (firstFree.start < range->start){
                    freeRanges.erase(firstFreeIt);
                    freeRanges.insert(TimeInterval(firstFree.start, range->start));
                    freeRanges.insert(TimeInterval(range->start, firstFree.end));
                    continue;
                }
                else {
                    if (firstFree.start > range->start){
                        range->start = firstFree.start;
                    }
                    Int rangeLength = range->start.secsTo(range->end) / 60;
                    if (rangeLength < range->requirement){
                        range->requirement = rangeLength;
                        this->m_impossibleConditions.push(range->occurrence);
                        range->occurrence->setImpossible(true);
                    }
                    Int length = firstFree.start.secsTo(firstFree.end) / 60;
                    if (length <= range->requirement){
                        range->start = firstFree.end;
                        range->requirement -= length;
                        freeRanges.erase(firstFreeIt);
                        continue;
                    }
                    else {
                        freeRanges.erase(firstFreeIt);
                        freeRanges.insert(TimeInterval(firstFree.start.addSecs((Int64)range->requirement * 60), firstFree.end));
                        break;
                    }
                }
            }
            //if (this->m_impossibleCondition != nullptr) break;
        }
        
        for (SimpleOccurrence* range:ranges){
            delete range;
        }
        
        /*
        for (QObject* object:occurrenceList.getData()){
            Occurrence* occurrence = static_cast<Occurrence*>(object);
            qDebug() << occurrence->startTime() << occurrence->endTime() << occurrence->plan()->name();
            for (int i = 0; i < occurrence->status.size(); i++){
                qDebug() << (static_cast<Objective*>(occurrence->plan()->objectives()->at(i))->action()->name()) << this->minutesToString(occurrence->status[i]);
            }
        }
        */ 
        
        
        
        std::chrono::steady_clock::time_point _end = std::chrono::steady_clock::now();
        
        qDebug() << "Time Elapsed for Condition Check = " << std::chrono::duration_cast<std::chrono::microseconds>(_end - _begin).count();
    }
    
    QObject* Engine::impossibleConditions()
    {
        this->occurrences();
        return &this->m_impossibleConditions;
    }

    /*
    Action* Engine::test()
    {
        return this->m_test;
    }
    
    void Engine::setTest(Action *value)
    {
        this->m_test = value;
        emit this->testChanged();
    }
    
    */

}
