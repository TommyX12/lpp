#pragma once

#include <QObject>
#include <QQuickItem>
#include <QVector>

//#include "Mission.h"
#include "utils/Types.h"

#include "utils/QObjectVector.h"

#include "Folder.h"

#include "Objective.h"
#include "Instance.h"

#include "IQmlSearchable.h"
#include "ISavable.h"

namespace LPP
{
    
    class Plan: public IQmlSearchable, public ISavable
    {
        Q_OBJECT
        
        Q_PROPERTY(QString type READ type NOTIFY typeChanged)
        Q_PROPERTY(QString typeName READ typeName NOTIFY typeChanged)
        Q_PROPERTY(Int id READ id NOTIFY idChanged)
        Q_PROPERTY(QString name READ name WRITE setName NOTIFY nameChanged)
        Q_PROPERTY(QString note READ note WRITE setNote NOTIFY noteChanged)
        Q_PROPERTY(Folder* parentFolder READ parentFolder NOTIFY parentFolderChanged)
        
        Q_PROPERTY(QObjectVector* objectives READ objectives NOTIFY objectivesChanged)
        Q_PROPERTY(Int completionMode READ completionMode WRITE setCompletionMode NOTIFY completionModeChanged)
            //0: ALL, 1: ANY
        Q_PROPERTY(QObjectVector* instances READ instances NOTIFY instancesChanged)
        
    public:
        
        Plan();
        virtual ~Plan();
        
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
        
        QObjectVector* objectives();
        QObjectVector* instances();
        
        static bool compareObjective(QObject*, QObject*);
        static bool compareInstance(QObject*, QObject*);
        
        Q_INVOKABLE QObject* createObjective(Action*);
        Q_INVOKABLE void moveObjective(Objective*, Int);
        Q_INVOKABLE void deleteObjective(Objective*);
        
        Q_INVOKABLE QObject* createInstance();
        Q_INVOKABLE void deleteInstance(Instance*);
        
        Int completionMode();
        Int setCompletionMode(Int);
        
    private:
        Int m_id;
        QString m_name, m_note;
        
        QObjectVector m_objectives, m_instances;
        
        Int m_completionMode;
        
    public slots:
        
    signals:
        void idChanged();
        void nameChanged();
        void noteChanged();
        void completionModeChanged();
        void parentFolderChanged();
        
        void typeChanged();
        
        void objectivesChanged();
        void instancesChanged();
    };
}

