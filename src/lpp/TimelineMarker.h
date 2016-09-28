#pragma once

#include <QDateTime>
#include <QObject>

#include "Action.h"

namespace LPP
{
    class Action;
    
    class TimelineMarker: public QObject
    {
        Q_OBJECT
        
        Q_PROPERTY(QDateTime time READ time NOTIFY timeChanged)
        Q_PROPERTY(Action* action READ action NOTIFY actionChanged)
        Q_PROPERTY(bool isAuto READ isAuto NOTIFY isAutoChanged)
        
    public:
        TimelineMarker();
        virtual ~TimelineMarker();
        
        QDateTime time();
        QDateTime setTime(const QDateTime&);
        Action* action();
        Action* setAction(Action*, bool);
        bool isAuto();
        bool mergable(TimelineMarker*);
        //bool setIsAuto(bool);
        
    private:
        QDateTime m_time;
        Action* m_action;
        bool m_isAuto;
        
    signals:
        void timeChanged();
        void actionChanged();
        void isAutoChanged();
    };
}
