#pragma once

#include <QString>
#include <QVector>
#include <QPair>

#include <QJsonObject>

#include "utils/Types.h"

namespace LPP
{

    class Folder;
    
    class ISavable
    {
        
    public:
        
        ISavable();
        virtual ~ISavable();
        
        //virtual void setParams(const QVector<QPair<QString, QString>>&);
        //virtual void setParam(const QString&, const QString&);
        //virtual QVector<QPair<QString, QString>> getParams();
        
        virtual QJsonObject saveToJson();
        QString saveToString();
        void saveToFile(const QString&, const QString&);
        
        virtual void loadFromJson(const QJsonObject&);
        void loadFromString(const QString&);
        void loadFromFile(const QString&);
        
        virtual QString getFileName();
        
        virtual Folder* parentFolder();
        virtual Folder* setParentFolder(Folder*);
        
    protected:
        Folder* m_parentFolder;
    };
}

