#pragma once

#include "utils/Types.h"
#include <QString>

namespace LPP
{
    extern Int e_maxID;
    extern QString e_savePath;
    extern QString e_rootFolderFileName;
    extern QString e_timelineFileName;
    extern QString e_folderDataFileName;
    extern QString e_saveFileNameExtension;
    extern QString e_folderFileNamePrefix;
    extern QString e_actionFileNamePrefix;
    extern QString e_planFileNamePrefix;
    extern QString e_globalSettingsFileName;
    extern QString e_globalStatusFileName;
    extern Int t_maxPastYears;
    extern Int t_maxFutureYears;
    extern Int t_maxPlanningDays;
    extern Int t_maxAutoplanDays;
    extern Int t_maxPastDays;
    extern QString e_timeStringFormat;
    extern QString e_timeStringReadFormat;
    extern QString e_timeStringMinuteFormat;
    extern QString e_timeStringHourFormat;
    extern QString e_timeStringDayFormat;
    extern QString e_timeStringMonthFormat;
    extern QString e_timeStringReadFullFormat;
    extern Int64 t_cleanUpThresholdSec;
    extern Int64 c_minuteMSec;
    extern Int64 c_hourMSec;
    extern Int64 c_dayMSec;
    //#define DEBUG 1
}
