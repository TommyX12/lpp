#include "Action.h"
#include "Session.h"
#include "Plan.h"

#include <QQmlEngine>


#include "GlobalVars.h"

#include "Engine.h"

#include <QJsonArray>


namespace LPP
{
    Action::Action()
    {
        
        this->m_id = -1;
        this->m_name = "";
        this->m_note = "";
        this->updateFullPath();
    }
    
    Action::~Action()
    {
        
        /*
        for (Session* session:this->m_sessions){
            delete session;
        }
        */
    }
    
    QString Action::type()
    {
        return "action";
    }
    QString Action::typeName()
    {
        return "Action";
    }
    
    Int Action::id()
    {
        return this->m_id;
    }
    
    Int Action::setID(Int id)
    {
        Engine::current()->setOccurrencesChanged();
        
        this->m_id = id;
        emit this->idChanged();
        return this->m_id;
    }
    
    void Action::updateFullPath()
    {
        if (this->parentFolder() != nullptr) this->setFullPath(this->parentFolder()->fullPath() + "/" + this->name());
        else this->setFullPath(this->name());
    }
    
    Folder* Action::setParentFolder(Folder* parentFolder)
    {
        Engine::current()->setOccurrencesChanged();
        
        this->m_parentFolder = parentFolder;
        emit this->parentFolderChanged();
        this->updateFullPath();
        return this->m_parentFolder;
    }
    
    QString Action::name()
    {
        return this->m_name;
    }
    
    QString Action::setName(const QString & name)
    {
        Engine::current()->setOccurrencesChanged();
        
        this->m_name = name;
        emit this->nameChanged();
        this->updateFullPath();
        return this->m_name;
    }
    
    QString Action::note()
    {
        return this->m_note;
    }
    
    QString Action::setNote(const QString & note)
    {
        Engine::current()->setOccurrencesChanged();
        
        this->m_note = note;
        emit this->noteChanged();
        return this->m_note;
    }
    
    bool Action::comparePlans(QObject* a, QObject* b)
    {
        return static_cast<Instance*>(static_cast<Plan*>(a)->instances()->at(0))->startTime() < static_cast<Instance*>(static_cast<Plan*>(b)->instances()->at(0))->startTime();
    }
    
    QObjectVector* Action::plans()
    {
        return &this->m_plans;
    }
    
    QObject* Action::createPlan()
    {
        Engine::current()->setOccurrencesChanged();
        
        Plan* newPlan = new Plan();
        
        QQmlEngine::setObjectOwnership(newPlan, QQmlEngine::CppOwnership);
        
        this->plans()->push(newPlan);
        
        Instance* instance = static_cast<Instance*>(newPlan->createInstance());
        newPlan->createObjective(this);
        
        instance->setPermanent(false);
        
        return newPlan;
    }
    
    bool Action::deletePlan(QObject* plan)
    {   
        if (plan != nullptr){
            
            Engine::current()->setOccurrencesChanged();
            
            Engine::current()->objectDeleted(plan);
            
            this->plans()->remove(plan);
            
            return true;
        }
        
        return false;
    }
    
    /*
    void Action::setParam(const QString& name, const QString& value)
    {
        if (name == "name") this->setName(value);
        else if (name == "note") this->setNote(value);
        else if (name == "missions") {
            QStringList params = value.split('\n', QString::KeepEmptyParts);
            for (int i = 2; i < params.size(); i += 3){
                Plan* plan = static_cast<Plan*>(this->createPlan());
                QString name = params[i-2];
                plan->setName(name.right(name.length() - 1));
                static_cast<Objective*>(plan->objectives()->at(0))->setParams(params[i-1]);
                static_cast<Instance*>(plan->instances()->at(0))->setParams(params[i]);
            }
        }
    }

    QVector<QPair<QString, QString>> Action::getParams()
    {
        QVector<QPair<QString, QString>> params;
        params.append(QPair<QString, QString>("name", this->name()));
        params.append(QPair<QString, QString>("note", this->note()));
        
        QString plansStr;
        
        for (int i = 0; i < this->plans()->size(); ++i){
            Plan* plan = static_cast<Plan*>(this->plans()->at(i));
            plansStr.append(">" + plan->name() + "\n");
            plansStr.append(static_cast<Objective*>(plan->objectives()->at(0))->getParams() + "\n");
            plansStr.append(static_cast<Instance*>(plan->instances()->at(0))->getParams() + "\n");
        }
        
        params.append(QPair<QString, QString>("missions", plansStr));
        
        return params;
    }
    */
    
    QJsonObject Action::saveToJson()
    {
        QJsonObject json = QJsonObject();
        
        json["name"] = this->name();
        json["note"] = this->note();
        
        QJsonArray missionsArray = QJsonArray(); 
        
        for (QObject* object:this->plans()->getData()){
            Plan* plan = static_cast<Plan*>(object);
            missionsArray.append(plan->saveToJson());
        }
        
        json["missions"] = missionsArray;
        
        return json;
    }
    
    void Action::loadFromJson(const QJsonObject& json)
    {
        this->setName(json["name"].toString());
        this->setNote(json["note"].toString());
        
        this->plans()->clear();
        QJsonArray missionsArray = json["missions"].toArray();
        
        for (int i = 0; i < missionsArray.size(); ++i){
            QJsonObject planJson = missionsArray[i].toObject();
            Plan* plan = static_cast<Plan*>(this->createPlan());
            plan->loadFromJson(planJson);
        }
    }
    
    QString Action::getFileName()
    {
        return "/" + e_actionFileNamePrefix + QString::number(this->id());
    }
}
