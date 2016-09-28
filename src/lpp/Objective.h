#pragma once

#include <QObject>
#include <QQuickItem>

//#include "Mission.h"
#include "utils/Types.h"

#include "Action.h"

namespace LPP
{
    
    class Objective: public QObject
    {
        Q_OBJECT
        
        Q_PROPERTY(Action* action READ action WRITE setAction NOTIFY actionChanged)
        Q_PROPERTY(Int length READ length WRITE setLength NOTIFY lengthChanged)
        
    public:
        
        Objective();
        virtual ~Objective();
        
        Action* action();
        Action* setAction(Action*);
        
        Int length();
        Int setLength(Int);
        
        QString getParams();
        void setParams(const QString&);
        
        Int tempActionID;
        
    private:
        Action* m_action;
        Int m_length;
        
    signals:
        void actionChanged();
        void lengthChanged();
    };
}
