#pragma once

#include "Settings.h"
#include "utils/Types.h"

#include <QObject>
#include <QString>

namespace LPP
{
    
    class GlobalSettings: public Settings
    {
        Q_OBJECT
        
        Q_PROPERTY(bool autoAutoPlan MEMBER m_autoAutoPlan NOTIFY autoAutoPlanChanged)
        
    public:
        GlobalSettings();
        virtual ~GlobalSettings();
        
    private:
        bool m_autoAutoPlan;
        
    signals:
        void autoAutoPlanChanged();
        
    };

    //#define DEBUG 1
}
