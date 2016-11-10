#include "CharacterAttribute.h"

#include "GlobalVars.h"

#include "Plan.h"

#include "Engine.h"

namespace LPP
{

    CharacterAttribute::CharacterAttribute()
    {
        this->m_name = "";
        //this->m_isBuiltIn = false;
    }
    
    CharacterAttribute::~CharacterAttribute()
    {
        
    }
    
    QString CharacterAttribute::name()
    {
        return this->m_name;
        //return this->isBuiltIn() ? tr(qPrintable(this->m_name)) : this->m_name;
    }
    
    QString CharacterAttribute::setName(const QString & name)
    {   
        //if (this->isBuiltIn()) return "";
        
        this->m_name = name;
        emit this->nameChanged();
        return this->m_name;
    }
    
    Int CharacterAttribute::id()
    {
        return this->m_id;
    }
    
    Int CharacterAttribute::setID(Int id)
    {
        Engine::current()->setOccurrencesChanged();
        
        this->m_id = id;
        emit this->idChanged();
        return this->m_id;
    }
    
    /*
    bool CharacterAttribute::isBuiltIn()
    {
        return this->m_isBuiltIn;
    }
    
    bool CharacterAttribute::setIsBuiltIn(bool value)
    {
        this->m_isBuiltIn = value;
        emit this->isBuiltInChanged();
        return this->m_isBuiltIn;
    }
    */
}
