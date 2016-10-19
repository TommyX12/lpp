#include "GlobalVars.h"

namespace LPP
{
    Int e_maxID = 1024;
    QString e_savePath = "/save";
    QString e_rootFolderFileName = "/rootFolder";
    QString e_timelineFileName = "/timeline";
    QString e_folderDataFileName = "/folderData";
    QString e_globalSettingsFileName = "/global_settings";
    QString e_globalStatusFileName = "/global_status";
    QString e_saveFileNameExtension = ".sav";
    QString e_folderFileNamePrefix = "folder_";
    QString e_actionFileNamePrefix = "action_";
    QString e_planFileNamePrefix = "mission_";
    Int t_maxPastYears = 100;
    Int t_maxFutureYears = 100;
    Int t_maxPlanningDays = 365;
    Int t_maxAutoplanDays = 16;
    Int t_maxPastDays = 16;
    QString e_timeStringFormat = "yyyy-MM-dd HH:mm";
    QString e_timeStringReadFormat = "yyyy-MM-dd ddd HH:mm";
    QString e_timeStringMinuteFormat = "mm";
    QString e_timeStringHourFormat = "HH:mm";
    QString e_timeStringDayFormat = "dd HH:mm";
    QString e_timeStringMonthFormat = "MM-dd HH:mm";
    QString e_timeStringReadFullFormat = "yyyy-MM-dd ddd HH:mm:ss";
    QString e_timeStringMaskFormat = "yyyy/M/d";
    Int64 t_cleanUpThresholdSec = 300;
    Int64 c_minuteMSec = 60000;
    Int64 c_hourMSec = 3600000;
    Int64 c_dayMSec = 86400000;
}
