#pragma once

#include <QObject>

#include <QVector>
#include <QMap>
#include <QDateTime>
#include "utils/Types.h"
#include "utils/QObjectVector.h"
#include "ISavable.h"
#include "Action.h"
#include "Plan.h"
#include "Occurrence.h"
#include "Folder.h"
#include "TimelineMarker.h"
#include "SearchList.h"

#include "GlobalSettings.h"

#include <set>

class QApplication;
class QQmlApplicationEngine;

namespace LPP
{
    
    void registerQtClasses();
    
    struct MissionPoint
    {
        QDateTime time;
        MissionPoint* start;
        Objective* objective;
        Int progress;
        Occurrence* occurrence;
        int objectiveIndex;
    };
    
    struct SimpleOccurrence
    {
        QDateTime start, end;
        Int requirement;
        Occurrence* occurrence;
        Action* action;
        SimpleOccurrence(const QDateTime& start, const QDateTime& end, Int requirement, Occurrence* occurrence, Action* action = nullptr){
            this->start = start;
            this->end = end;
            this->requirement = requirement;
            this->occurrence = occurrence;
            this->action = action;
        };
    };

    class Engine : public QObject
    {
        Q_OBJECT
        
        //Q_PROPERTY(Action* test READ test WRITE setTest NOTIFY testChanged)
        Q_PROPERTY(Int numFolders READ numFolders NOTIFY numFoldersChanged)
        Q_PROPERTY(Int numActions READ numActions NOTIFY numActionsChanged)
        Q_PROPERTY(Int numPlans READ numPlans NOTIFY numPlansChanged)
        Q_PROPERTY(QDateTime timeOrigin READ timeOrigin)
        Q_PROPERTY(Folder* rootFolder READ rootFolder NOTIFY rootFolderChanged)
        
        Q_PROPERTY(GlobalSettings* globalSettings READ globalSettings NOTIFY globalSettingsChanged)
        
        Q_PROPERTY(QDateTime timelineMin READ timelineMin NOTIFY timelineMinChanged)
        Q_PROPERTY(QDateTime timelineMax READ timelineMax NOTIFY timelineMaxChanged)
        Q_PROPERTY(QDateTime planningMax READ planningMax NOTIFY planningMaxChanged)
        Q_PROPERTY(QDateTime autoplanMax READ autoplanMax NOTIFY autoplanMaxChanged)
        
        Q_PROPERTY(QObjectVector* occurrences READ occurrences)
                
    public:
        Engine();
        virtual ~Engine();
        
        static Engine* current();
        
        void initialize(QApplication&, QQmlApplicationEngine&);
        
        //void setTest(Action*);
        //Action* test();
        
        QDateTime timeOrigin();
        
        Folder* rootFolder();
        
        GlobalSettings* globalSettings();
        
        Int numFolders();
        Int numActions();
        Int numPlans();
        
        Q_INVOKABLE void print(const QString&);
        
        //Int getNextID(const QVector<Int>&);
        
        Q_INVOKABLE QObject* createFolder(Folder*, Int);
        Q_INVOKABLE QObject* getFolderByID(Int);
        Q_INVOKABLE bool moveFolder(Folder*, Folder*);
        Q_INVOKABLE bool deleteFolder(Folder*);
        Q_INVOKABLE void saveFolder(Folder*);
        
        Q_INVOKABLE QObject* createAction(Folder*, Int);
        Q_INVOKABLE QObject* getActionByID(Int);
        Q_INVOKABLE bool moveAction(Action*, Folder*);
        Q_INVOKABLE bool deleteAction(Action*);
        Q_INVOKABLE void saveAction(Action*);
        
        Q_INVOKABLE QObject* createPlan(Folder*, Int);
        Q_INVOKABLE QObject* getPlanByID(Int);
        Q_INVOKABLE bool movePlan(Plan*, Folder*);
        Q_INVOKABLE bool deletePlan(Plan*);
        Q_INVOKABLE void savePlan(Plan*);
        
        Q_INVOKABLE QObject* requestSearchList(bool, bool, bool);
        
        QString getFilePath(ISavable&);
        void saveToFile(const QString&, const QString&, ISavable&);
        void loadFromFile(const QString&, ISavable&);
        void deleteDirectory(const QString&);
        void deleteFile(const QString&);
        void loadDirectory(const QString&, Folder*);
        
        QString encodeParams(const QVector<QPair<QString, QString>>&);
        QVector<QPair<QString, QString>> decodeParams(const QString&);
        
        QString qmlPath, appPath, savePath;
        
        QDateTime timelineMin();
        QDateTime setTimelineMin(const QDateTime&);
        QDateTime timelineMax();
        QDateTime setTimelineMax(const QDateTime&);
        QDateTime planningMax();
        QDateTime setPlanningMax(const QDateTime&);
        QDateTime autoplanMax();
        QDateTime setAutoplanMax(const QDateTime&);
        
        Q_INVOKABLE QDateTime currentTime();
        Q_INVOKABLE QDateTime dateToTime(Int, Int, Int);
        Q_INVOKABLE QDateTime stringToTime(const QString&);
        Q_INVOKABLE QString timeToString(const QDateTime&);
        Q_INVOKABLE QString timeSpanToString(const QDateTime&, const QDateTime&);
        Q_INVOKABLE QString timeToStringRead(const QDateTime&);
        Q_INVOKABLE QString timeToStringReadFull(const QDateTime&);
        Q_INVOKABLE QString minutesToString(Int);
        QDateTime limitTimePrecision(const QDateTime&);
        
        QString encodeMonth(QVector<TimelineMarker*>*);
        QVector<TimelineMarker*>* createMonth(Int, Int);
        QVector<TimelineMarker*>* decodeMonth(const QString&, Int, Int);
        
        Int monthToKey(QVector<TimelineMarker*>*);
        
        Q_INVOKABLE void load();
        Q_INVOKABLE void save();
        static bool compareMonth(const QDateTime&, QVector<TimelineMarker*>*);
        static bool compareMonths(QVector<TimelineMarker*>*, QVector<TimelineMarker*>*);
        Int binarySearchMonth(const QDateTime&);
        static bool compareMarker(const QDateTime&, TimelineMarker*);
        static bool compareMarkers(TimelineMarker*, TimelineMarker*);
        Int binarySearchMarker(QVector<TimelineMarker*>*, const QDateTime&);
        Q_INVOKABLE QObject* createMarker(const QDateTime&, Action*, bool);
        Q_INVOKABLE QObject* getMarker(const QDateTime&);
        Q_INVOKABLE QObject* getMarkerAfter(const QDateTime&);
        Q_INVOKABLE QObject* getPrevMarker();
        Q_INVOKABLE QObject* getNextMarker();
        Q_INVOKABLE void deleteMarker(TimelineMarker*);
        Q_INVOKABLE void moveMarker(TimelineMarker*, const QDateTime&);
        Q_INVOKABLE void setMarkerAction(TimelineMarker*, Action*, bool);
        void mergeMarkers(const QDateTime&);
        Q_INVOKABLE void refresh();
        Q_INVOKABLE bool drawTimelineRange(Action*, const QDateTime&, const QDateTime&, bool = false);
        Q_INVOKABLE void autoPlan(bool = false);
        Q_INVOKABLE void eraseAutoPlan();
        
        void setOccurrencesChanged();
        void setSessionsChanged();
        void setTimeChanged();
        
        Int toMonthNumber(const QDate&);
        QDate fromMonthNumber(Int);
        
        static bool compareOccurrences(QObject*, QObject*);
        
        QObjectVector* occurrences();
        void extractOccurrences(QDateTime, QDateTime, QObjectVector&, bool = false);
        void checkConflicts();
        
        static bool compareMissionPoints(MissionPoint*, MissionPoint*);
        static bool compareSimpleOccurrences(SimpleOccurrence*, SimpleOccurrence*);
        
        void checkConditions(QObjectVector&);
        
        Q_INVOKABLE QObject* impossibleConditions();
        
    private:
        //Action* m_test;
        static Engine* m_current;
        
        QDateTime m_timeOrigin;
        
        SearchList m_searchList;
        
        QVector<Folder*> m_folders;
        Int m_numFolders;
        //QVector<bool> m_folderIDs;
        
        Folder m_rootFolder;
        
        GlobalSettings m_globalSettings;
        
        QVector<Action*> m_actions;
        Int m_numActions;
        //QVector<bool> m_actionIDs;
        
        QVector<Plan*> m_plans;
        Int m_numPlans;
        //QVector<bool> m_planIDs;
        
        QVector<QVector<TimelineMarker*>*> m_timeline;
        QMap<Int, QVector<TimelineMarker*>*> m_monthModified;
        QDateTime m_timelineMin, m_timelineMax, m_planningMax, m_autoplanMax;
        
        bool m_mergeDisabled;
        
        Int m_currentMonthIndex, m_currentMarkerIndex;
        
        bool m_occurrencesChanged, m_sessionsChanged, m_timeChanged, m_autoplanDesynced;
        QObjectVector m_occurrences;
        
        QObjectVector m_impossibleConditions;
        
    public slots:
        
    signals:
        //void testChanged();
        void numFoldersChanged();
        void numActionsChanged();
        void numPlansChanged();
        
        void rootFolderChanged();
        void globalSettingsChanged();
        
        void timelineMinChanged();
        void timelineMaxChanged();
        void planningMaxChanged();
        void autoplanMaxChanged();
        
        void objectDeleted(QObject*);
        void actionDeleted(Action*);
    };

}
