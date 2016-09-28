#pragma once

#include <QObject>
#include <QQuickItem>

#include "utils/Types.h"

namespace LPP
{
    class Action;
    
    class Session: public QObject
    {
        Q_OBJECT
        
        Q_PROPERTY(Action* parentAction READ parentAction)
        
    public:
        Session();
        virtual ~Session();
        
        Action* parentAction();
        
    private:
        Action* m_parentAction;
    };
}
