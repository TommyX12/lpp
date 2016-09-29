#pragma once

#include "Settings.h"
#include "utils/Types.h"

#include <QObject>
#include <QString>

#include <QDateTime>

namespace LPP
{
    
    class GlobalStatus: public Settings
    {
        Q_OBJECT
        
        Q_PROPERTY(QDateTime pastMax MEMBER m_pastMax NOTIFY pastMaxChanged)
        
    public:
        GlobalStatus();
        virtual ~GlobalStatus();
        
        QDateTime m_pastMax;
        
    signals:
        void pastMaxChanged();
        
    };

    //#define DEBUG 1
}
