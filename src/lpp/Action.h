#pragma once

#include <QObject>
#include <QQuickItem>
#include <QVector>
#include <QString>
#include "IQmlSearchable.h"
#include "ISavable.h"

#include "Folder.h"

#include "utils/Types.h"

namespace LPP 
{
    class Session;
    
    class Action: public IQmlSearchable, public ISavable
    {
        Q_OBJECT
        
        Q_PROPERTY(QString type READ type NOTIFY typeChanged)
        Q_PROPERTY(QString typeName READ typeName)
        Q_PROPERTY(Int id READ id)
        Q_PROPERTY(QString name READ name WRITE setName NOTIFY nameChanged)
        Q_PROPERTY(QString note READ note WRITE setNote NOTIFY noteChanged)
        Q_PROPERTY(Folder* parentFolder READ parentFolder NOTIFY parentFolderChanged)
        
    public:
        
        Action();
        virtual ~Action();
        
        QString type();
        QString typeName();
        
        Int id();
        Int setID(Int);
        
        virtual void updateFullPath();
        
        virtual Folder* setParentFolder(Folder*);
        
        QString name();
        QString setName(const QString&);
        
        QString note();
        QString setNote(const QString&);
        
        virtual void setParam(const QString&, const QString&);
        virtual QVector<QPair<QString, QString>> getParams();
        
        virtual QString getFileName();
        
    private:
        Int m_id;
        QString m_name, m_note;
        
        //QVector<Session*> m_sessions;
        
    public slots:
        
    signals:  
        void nameChanged();
        void noteChanged();
        void parentFolderChanged();
        
        void typeChanged();
    };
}
