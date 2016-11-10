#include "Objective.h"

#include "GlobalVars.h"

#include "QTextStream"

#include "Engine.h"

namespace LPP
{
    Objective::Objective()
    {
        
        this->m_action = nullptr;
        this->m_length = 0;
        
        this->tempActionID = -1;
    }
    
    Objective::~Objective()
    {
        
        
    }
    
    Action* Objective::action()
    {
        if (this->tempActionID != -1 && this->m_action == nullptr){
            this->setAction(static_cast<Action*>(Engine::current()->getActionByID(this->tempActionID)));
        }
        return this->m_action;
    }
    
    Action* Objective::setAction(Action* action)
    {
        Engine::current()->setTimeChanged();
        
        if (action != nullptr) this->tempActionID = action->id();
        
        this->m_action = action;
        emit this->actionChanged();
        return this->m_action;
    }
    
    Int Objective::length()
    {
        return this->m_length;
    }
    
    Int Objective::setLength(Int length)
    {
        Engine::current()->setTimeChanged();
        
        this->m_length = length;
        emit this->lengthChanged();
        return this->m_length;
    }
    
    /*
    QString Objective::getParams()
    {
        QString str;
        QTextStream text(&str);
        text << "action," << this->action()->id() << ",";
        text << "length," << this->length() << ",";
        return str;
    }
    
    void Objective::setParams(const QString& str)
    {
        QStringList list = str.split(',', QString::SkipEmptyParts);
        for (int i = 1; i < list.length(); i+=2){
            const QString& name = list[i-1];
            const QString& value = list[i];
            if (name == "action") this->tempActionID = value.toInt();
            else if (name == "length") this->setLength(value.toInt());
        }
    }
    */
    
    QJsonObject Objective::saveToJson()
    {
        QJsonObject json = QJsonObject();
        
        json["action"] = this->action()->id();
        json["length"] = this->length();
        
        return json;
    }
    
    void Objective::loadFromJson(const QJsonObject& json)
    {
        this->tempActionID = json["action"].toInt();
        this->setAction(nullptr);
        
        this->setLength(json["length"].toInt());
    }
}
