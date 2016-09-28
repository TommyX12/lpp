#include "IQmlSearchable.h"

namespace LPP
{
    IQmlSearchable::IQmlSearchable(): QObject(nullptr)
    {
        this->m_fullPath = this->m_fullPathLower = "";
    }
    
    IQmlSearchable::~IQmlSearchable()
    {
        
    }
    
    QString IQmlSearchable::fullPath()
    {
        return this->m_fullPath;
    }
    
    QString IQmlSearchable::fullPathLower()
    {
        return this->m_fullPathLower;
    }
    
    QString IQmlSearchable::setFullPath(const QString& str)
    {
        this->m_fullPath = str;
        this->m_fullPathLower = this->m_fullPath.toLower();
        emit this->fullPathChanged();
        return this->m_fullPath;
    }
    
    void IQmlSearchable::updateFullPath()
    {
        
    }
}
