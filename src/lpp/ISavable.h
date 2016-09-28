#pragma once

#include <QString>
#include <QVector>
#include <QPair>

#include "utils/Types.h"

namespace LPP
{

    class Folder;
    
    class ISavable
    {
        
    public:
        
        ISavable();
        virtual ~ISavable();
        
        virtual void setParams(const QVector<QPair<QString, QString>>&);
        virtual void setParam(const QString&, const QString&);
        virtual QVector<QPair<QString, QString>> getParams();
        
        virtual QString getFileName();
        
        virtual Folder* parentFolder();
        virtual Folder* setParentFolder(Folder*);
        
    protected:
        Folder* m_parentFolder;
    };
}

