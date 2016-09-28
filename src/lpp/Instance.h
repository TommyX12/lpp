#pragma once

#include <QObject>
#include <QQuickItem>

//#include "Mission.h"
#include "utils/Types.h"

#include "QDateTime"

namespace LPP
{

    class Plan;
    
    class Instance: public QObject
    {
        Q_OBJECT
        
        Q_PROPERTY(QDateTime startTime READ startTime WRITE setStartTime NOTIFY startTimeChanged)
        Q_PROPERTY(QDateTime endTime READ endTime WRITE setEndTime NOTIFY endTimeChanged)
        
        Q_PROPERTY(QString repeatMode READ repeatMode WRITE setRepeatMode NOTIFY repeatModeChanged)
        Q_PROPERTY(Int repeatParam READ repeatParam WRITE setRepeatParam NOTIFY repeatParamChanged)
        Q_PROPERTY(QDateTime repeatUntil READ repeatUntil WRITE setRepeatUntil NOTIFY repeatUntilChanged)
        
    public:
        
        Instance();
        virtual ~Instance();
        
        Q_INVOKABLE QObject* plan();
        void setPlan(Plan*);
        
        QDateTime startTime();
        QDateTime setStartTime(const QDateTime&);
        
        QDateTime endTime();
        QDateTime setEndTime(const QDateTime&);
        
        QString repeatMode();
        QString setRepeatMode(const QString&);
        
        Int repeatParam();
        Int setRepeatParam(Int);
        
        QDateTime repeatUntil();
        QDateTime setRepeatUntil(const QDateTime&);
        
        Q_INVOKABLE bool isForever();
        
        QString getParams();
        void setParams(const QString&);
        
    private:
        Plan* m_plan;
        
        QDateTime m_startTime, m_endTime;
        
        QString m_repeatMode;
        Int m_repeatParam;
        QDateTime m_repeatUntil;
        
    signals:
        void startTimeChanged();
        void endTimeChanged();
        
        void repeatModeChanged();
        void repeatParamChanged();
        void repeatUntilChanged();
    };
}

