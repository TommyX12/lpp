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
    class Plan;
    
    class Action: public IQmlSearchable, public ISavable
    {
        Q_OBJECT
        
        Q_PROPERTY(QString type READ type NOTIFY typeChanged)
        Q_PROPERTY(QString typeName READ typeName NOTIFY typeChanged)
        Q_PROPERTY(Int id READ id NOTIFY idChanged)
        Q_PROPERTY(QString name READ name WRITE setName NOTIFY nameChanged)
        Q_PROPERTY(QString note READ note WRITE setNote NOTIFY noteChanged)
        Q_PROPERTY(Folder* parentFolder READ parentFolder NOTIFY parentFolderChanged)
        
        Q_PROPERTY(QObjectVector* plans READ plans NOTIFY plansChanged)
        
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
        
        //virtual void setParam(const QString&, const QString&);
        //virtual QVector<QPair<QString, QString>> getParams();
        
        virtual QJsonObject saveToJson();
        virtual void loadFromJson(const QJsonObject&);
        
        virtual QString getFileName();
        
        static bool comparePlans(QObject*, QObject*);
        
        QObjectVector* plans();
        
        Q_INVOKABLE QObject* createPlan();
        Q_INVOKABLE bool deletePlan(QObject*);
        
    private:
        Int m_id;
        QString m_name, m_note;
        
        QObjectVector m_plans;
        
        //QVector<Session*> m_sessions;
        
    public slots:
        
    signals:  
        void idChanged();
        void nameChanged();
        void noteChanged();
        void parentFolderChanged();
        
        void typeChanged();
        
        void plansChanged();
    };
}
