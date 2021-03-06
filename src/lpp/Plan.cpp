#include "Plan.h"

#include "GlobalVars.h"

#include "Engine.h"

#include "Action.h"

#include <QQmlEngine>

#include <QJsonArray>


namespace LPP
{
    Plan::Plan()
    {
        
        this->m_id = -1;
        this->m_name = "";
        this->m_note = "";
        this->m_completionMode = 0;
        this->updateFullPath();
    }
    
    Plan::~Plan()
    {
        
        /*
        for (Mission* mission:this->m_missions){
            delete mission;
        }
        
        
        while (this->m_instances.size()){
            this->deleteInstance(static_cast<Instance*>(this->m_instances.at(0)));
        }
        */
    }
    
    QString Plan::type()
    {
        return "plan";
    }
    QString Plan::typeName()
    {
        return "Mission";
    }
    
    Int Plan::id()
    {
        return this->m_id;
    }
    
    Int Plan::setID(Int id)
    {
        Engine::current()->setOccurrencesChanged();
        
        this->m_id = id;
        emit this->idChanged();
        return this->m_id;
    }
    
    void Plan::updateFullPath()
    {
        if (this->m_parentFolder != nullptr) this->setFullPath(this->m_parentFolder->fullPath() + "/" + this->m_name);
        else this->setFullPath(this->m_name);
    }
    
    Folder *Plan::setParentFolder(Folder* parentFolder)
    {
        Engine::current()->setOccurrencesChanged();
        
        this->m_parentFolder = parentFolder;
        emit this->parentFolderChanged();
        this->updateFullPath();
        return this->m_parentFolder;
    }
    
    QString Plan::name()
    {
        return this->m_name;
    }
    
    QString Plan::setName(const QString & name)
    {
        Engine::current()->setOccurrencesChanged();
        
        this->m_name = name;
        emit this->nameChanged();
        this->updateFullPath();
        return this->m_name;
    }
    
    QString Plan::note()
    {
        return this->m_note;
    }
    
    QString Plan::setNote(const QString & note)
    {
        Engine::current()->setOccurrencesChanged();
        
        this->m_note = note;
        emit this->noteChanged();
        return this->m_note;
    }
    
    /*
    void Plan::setParam(const QString& name, const QString& value)
    {
        if (name == "name") this->setName(value);
        else if (name == "note") this->setNote(value);
        else if (name == "completionMode") this->setCompletionMode(value.toInt());
        else if (name == "objectives") {
            QStringList list = value.split("\n", QString::SkipEmptyParts);
            for (QString param:list){
                Objective* objective = static_cast<Objective*>(this->createObjective(nullptr));
                objective->setParams(param);
            }
        }
        else if (name == "instances") {
            QStringList list = value.split("\n", QString::SkipEmptyParts);
            for (QString param:list){
                Instance* instance = static_cast<Instance*>(this->createInstance());
                instance->setParams(param);
            }
        }
    }

    QVector<QPair<QString, QString>> Plan::getParams()
    {
        QVector<QPair<QString, QString>> params;
        params.append(QPair<QString, QString>("name", this->name()));
        params.append(QPair<QString, QString>("note", this->note()));
        params.append(QPair<QString, QString>("completionMode", QString::number(this->completionMode())));
        
        QString objectivesStr;
        for (auto object:this->objectives()->getData()){
            objectivesStr += static_cast<Objective*>(object)->getParams() + "\n";
        }
        params.append(QPair<QString, QString>("objectives", objectivesStr));
        
        QString instancesStr;
        for (auto object:this->instances()->getData()){
            instancesStr += static_cast<Instance*>(object)->getParams() + "\n";
        }
        params.append(QPair<QString, QString>("instances", instancesStr));
        
        return params;
    }
    */
    
    QJsonObject Plan::saveToJson()
    {
        QJsonObject json = QJsonObject();
        
        json["name"] = this->name();
        json["note"] = this->note();
        json["completionMode"] = this->completionMode();
        
        
        QJsonArray objectivesArray = QJsonArray(); 
        
        for (QObject* object:this->objectives()->getData()){
            Objective* objective = static_cast<Objective*>(object);
            objectivesArray.append(objective->saveToJson());
        }
        
        json["objectives"] = objectivesArray;
        
        
        QJsonArray instancesArray = QJsonArray(); 
        
        for (QObject* object:this->instances()->getData()){
            Instance* instance = static_cast<Instance*>(object);
            instancesArray.append(instance->saveToJson());
        }
        
        json["instances"] = instancesArray;
        
        
        return json;
    }
    
    void Plan::loadFromJson(const QJsonObject& json)
    {
        this->setName(json["name"].toString());
        this->setNote(json["note"].toString());
        this->setCompletionMode(json["completionMode"].toInt());
        
        this->objectives()->clear();
        QJsonArray objectivesArray = json["objectives"].toArray();
        
        for (int i = 0; i < objectivesArray.size(); ++i){
            QJsonObject objectiveJson = objectivesArray[i].toObject();
            Objective* objective = static_cast<Objective*>(this->createObjective(nullptr));
            objective->loadFromJson(objectiveJson);
        }
        
        this->instances()->clear();
        QJsonArray instancesArray = json["instances"].toArray();
        
        for (int i = 0; i < instancesArray.size(); ++i){
            QJsonObject instanceJson = instancesArray[i].toObject();
            Instance* instance = static_cast<Instance*>(this->createInstance());
            instance->loadFromJson(instanceJson);
        }
    }
    
    QString Plan::getFileName()
    {
        return "/" + e_planFileNamePrefix + QString::number(this->id());
    }
    
    
    QObjectVector* Plan::objectives()
    {
        return &this->m_objectives;
    }
    
    QObjectVector* Plan::instances()
    {
        return &this->m_instances;
    }
    
    bool Plan::compareObjective(QObject* a, QObject* b)
    {
        return static_cast<Objective*>(a)->length() < static_cast<Objective*>(b)->length();
    }
    
    bool Plan::compareInstance(QObject* a, QObject* b)
    {
        return static_cast<Instance*>(a)->startTime() < static_cast<Instance*>(b)->startTime();
    }
    
    QObject* Plan::createObjective(Action* action)
    {
        Engine::current()->setOccurrencesChanged();
        
        Objective* newObject = new Objective();
        QQmlEngine::setObjectOwnership(newObject, QQmlEngine::CppOwnership);
        newObject->setAction(action);
        this->m_objectives.push(newObject);
        
        
        
        return newObject;
    }
    
    void Plan::moveObjective(Objective* objective, Int indexChange)
    {
        Engine::current()->setOccurrencesChanged();
        
        for (int i = 0; i < this->objectives()->size(); ++i){
            Objective* _objective = static_cast<Objective*>(this->objectives()->at(i));
            if (objective == _objective){
                this->objectives()->getData().move(i, std::min(std::max(i + indexChange, 0), this->objectives()->size() - 1));
                break;
            }
        }
    }
    
    void Plan::deleteObjective(Objective* objective)
    {
        Engine::current()->setOccurrencesChanged();
        
        if (objective == nullptr) return;
        
        this->m_objectives.remove(objective);
        
    }
    
    QObject* Plan::createInstance()
    {   
        Engine::current()->setSessionsChanged();
        
        Instance* newObject = new Instance();
        QQmlEngine::setObjectOwnership(newObject, QQmlEngine::CppOwnership);
        newObject->setPlan(this);
        QDateTime current = Engine::current()->limitTimePrecision(Engine::current()->currentTime());
        newObject->setStartTime(current);
        newObject->setEndTime(current.addSecs(3600).toUTC());
        this->m_instances.push(newObject);
        
        
        
        return newObject;
    }
    
    void Plan::deleteInstance(Instance* instance)
    {
        if (instance == nullptr) return;
        
        Engine::current()->setOccurrencesChanged();
        
        this->m_instances.remove(instance);
        
        
    }
    
    Int Plan::completionMode()
    {
        return this->m_completionMode;
    }
    
    Int Plan::setCompletionMode(Int completionMode)
    {
        Engine::current()->setOccurrencesChanged();
        
        this->m_completionMode = completionMode;
        emit this->completionModeChanged();
        return this->m_completionMode;
    }
}
