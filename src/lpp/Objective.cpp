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
        return this->m_action;
    }
    
    Action* Objective::setAction(Action* action)
    {
        Engine::current()->setOccurrencesChanged();
        
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
        Engine::current()->setOccurrencesChanged();
        
        this->m_length = length;
        emit this->lengthChanged();
        return this->m_length;
    }
    
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
}
