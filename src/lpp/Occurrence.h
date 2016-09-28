#pragma once

#include <QObject>
#include <QQuickItem>

//#include "Mission.h"
#include "utils/Types.h"

#include "QDateTime"

#include "Plan.h"

namespace LPP
{

    class Plan;
    
    class Occurrence: public QObject
    {
        Q_OBJECT
        
        Q_PROPERTY(QDateTime startTime READ startTime WRITE setStartTime NOTIFY startTimeChanged)
        Q_PROPERTY(QDateTime endTime READ endTime WRITE setEndTime NOTIFY endTimeChanged)
        
        Q_PROPERTY(Plan* plan READ plan WRITE setPlan NOTIFY planChanged)
        Q_PROPERTY(Instance* instance READ instance WRITE setInstance NOTIFY instanceChanged)
        
        Q_PROPERTY(bool impossible READ impossible NOTIFY impossibleChanged)
        
        Q_PROPERTY(Float progress READ progress NOTIFY progressChanged)
        Q_PROPERTY(Float progressNow READ progressNow NOTIFY progressNowChanged)
        
    public:
        
        Occurrence();
        virtual ~Occurrence();
        
        void reset();
        
        QDateTime startTime();
        QDateTime setStartTime(const QDateTime&);
        
        QDateTime endTime();
        QDateTime setEndTime(const QDateTime&);
        
        Plan* plan();
        Plan* setPlan(Plan*);
        
        Instance* instance();
        Instance* setInstance(Instance*);
        
        Q_INVOKABLE Int getStatus(Int);
        Q_INVOKABLE Int getStatusNow(Int);
        
        QVector<Int> status, statusNow;
        
        Int minRequirement();
        void resetMinRequirement();
        void setMinRequirement(Int);
        
        bool impossible();
        bool setImpossible(bool);
        
        Float progress();
        Float progressNow();
        
        Q_INVOKABLE void updateProgress();
        
    private:
        QDateTime m_startTime, m_endTime;
        
        Plan* m_plan;
        Instance* m_instance;
        
        Int m_minRequirement;
        
        bool m_impossible;
        
        Float m_progress, m_progressNow;
        
    signals:
        void startTimeChanged();
        void endTimeChanged();
        
        void planChanged();
        void instanceChanged();
        
        void impossibleChanged();
        
        void progressChanged();
        void progressNowChanged();
    };
}

