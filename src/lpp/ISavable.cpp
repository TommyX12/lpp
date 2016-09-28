#include "ISavable.h"

namespace LPP
{
    ISavable::ISavable()
    {
        this->m_parentFolder = nullptr;
    }
    
    ISavable::~ISavable()
    {
        
    }
    
    void ISavable::setParam(const QString& name, const QString& value)
    {
        
    }
    
    void ISavable::setParams(const QVector<QPair<QString, QString>>& params)
    {
        for (auto param:params){
            setParam(param.first, param.second);
        }
    }
    
    QVector<QPair<QString, QString>> ISavable::getParams()
    {
        
    }
    
    QString ISavable::getFileName()
    {
        
    }
    
    Folder* ISavable::parentFolder()
    {
        return this->m_parentFolder;
    }
    
    Folder* ISavable::setParentFolder(Folder* parentFolder)
    {
        
    }
}
