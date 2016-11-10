#include "Instance.h"

#include "GlobalVars.h"

#include "Plan.h"

#include "Engine.h"

namespace LPP
{

    Instance::Instance()
    {
        
        this->m_repeatMode = "none";
        this->m_repeatParam = 1;
        this->m_repeatUntil = Engine::current()->timeOrigin();
        this->m_plan = nullptr;
        
        this->m_permanent = true;
    }
    
    Instance::~Instance()
    {
        
        
    }
    
    QObject* Instance::plan()
    {
        return this->m_plan;
    }
    
    void Instance::setPlan(Plan* plan)
    {
        this->m_plan = plan;
    }
    
    QDateTime Instance::startTime()
    {
        return this->m_startTime;
    }
    
    QDateTime Instance::setStartTime(const QDateTime& startTime)
    {
        Engine::current()->setOccurrencesChanged();
        
        this->m_startTime = startTime.toUTC();
        emit this->startTimeChanged();
        return this->m_startTime;
    }
    
    QDateTime Instance::endTime()
    {
        return this->m_endTime;
    }
    
    QDateTime Instance::setEndTime(const QDateTime& endTime)
    {
        Engine::current()->setOccurrencesChanged();
        
        this->m_endTime = endTime.toUTC();
        emit this->endTimeChanged();
        return this->m_endTime;
    }
    
    QString Instance::repeatMode()
    {
        return this->m_repeatMode;
    }
    
    QString Instance::setRepeatMode(const QString& repeatMode)
    {
        Engine::current()->setOccurrencesChanged();
        
        this->m_repeatMode = repeatMode;
        emit this->repeatModeChanged();
        return this->m_repeatMode;
    }
    
    Int Instance::repeatParam()
    {
        return this->m_repeatParam;
    }
    
    Int Instance::setRepeatParam(Int repeatParam)
    {
        Engine::current()->setOccurrencesChanged();
        
        this->m_repeatParam = repeatParam;
        emit this->repeatParamChanged();
        return this->m_repeatParam;
    }
    
    QDateTime Instance::repeatUntil()
    {
        return this->m_repeatUntil;
    }
    
    QDateTime Instance::setRepeatUntil(const QDateTime& repeatUntil)
    {
        Engine::current()->setOccurrencesChanged();
        
        this->m_repeatUntil = repeatUntil.toUTC();
        emit this->repeatUntilChanged();
        return this->m_repeatUntil;
    }
    
    bool Instance::isForever()
    {
        return this->m_repeatUntil < this->m_startTime;
    }
    
    bool Instance::permanent()
    {
        return this->m_permanent;
    }
    
    bool Instance::setPermanent(bool permanent)
    {
        this->m_permanent = permanent;
        emit this->permanentChanged();
        return this->m_permanent;
    }
    
    QString Instance::getMask()
    {
        return this->m_mask;
    }
    
    const QVector<QPair<QDateTime, QDateTime>>& Instance::getMaskData()
    {
        return this->m_maskData;
    }
    
    bool Instance::compareDatePairs(const QPair<QDateTime, QDateTime>& a, const QPair<QDateTime, QDateTime>& b)
    {
        return a.first < b.first;
    }
    
    bool Instance::setMask(const QString& _mask)
    {
        QString mask = _mask.trimmed();
        
        QVector<QPair<QDateTime, QDateTime>> tempMaskData;
        
        QStringList entries = mask.split('\n', QString::SkipEmptyParts);
        
        for (QString& entry:entries){
            QStringList dates = entry.split('-', QString::SkipEmptyParts);
            if (dates.length() == 1){
                QDateTime start = QDateTime::fromString(dates[0].trimmed(), e_timeStringMaskFormat);
                start.setTimeSpec(Qt::UTC);
                if (!start.isValid()) return false;
                QDateTime end = start.addMSecs(c_dayMSec).toUTC();
                if (!end.isValid()) return false;
                
                tempMaskData.append(QPair<QDateTime, QDateTime>(start, end));
            }
            else if (dates.length() == 2){
                QDateTime start = QDateTime::fromString(dates[0].trimmed(), e_timeStringMaskFormat);
                start.setTimeSpec(Qt::UTC);
                if (!start.isValid()) return false;
                QDateTime end = QDateTime::fromString(dates[1].trimmed(), e_timeStringMaskFormat);
                end.setTimeSpec(Qt::UTC);
                if (!end.isValid()) return false;
                end = end.addMSecs(c_dayMSec).toUTC();
                if (!end.isValid()) return false;
                if (end <= start) return false;
                
                tempMaskData.append(QPair<QDateTime, QDateTime>(start, end));
            }
            else {
                return false;
            }
        }
        
        Engine::current()->setOccurrencesChanged();
        
        this->m_maskData.clear();
        this->m_maskData = tempMaskData;
        
        std::sort(this->m_maskData.begin(), this->m_maskData.end(), compareDatePairs);
        
        this->m_mask = mask;
        return true;
    }
    
    /*
    QString Instance::getParams()
    {
        QString str;
        QTextStream text(&str);
        text << "startTime," << Engine::current()->timeToString(this->startTime()) << ",";
        text << "endTime," << Engine::current()->timeToString(this->endTime()) << ",";
        text << "repeatMode," << this->repeatMode() << ",";
        text << "repeatParam," << this->repeatParam() << ",";
        text << "repeatUntil," << Engine::current()->timeToString(this->repeatUntil()) << ",";
        QString maskTxt = this->getMask();
        maskTxt.remove(',');
        maskTxt.replace('\n', ';');
        text << "mask," << maskTxt << ",";
        return str;
    }
    
    void Instance::setParams(const QString& str)
    {
        QStringList list = str.split(',', QString::SkipEmptyParts);
        for (int i = 1; i < list.length(); i+=2){
            const QString& name = list[i-1];
            const QString& value = list[i];
            if (name == "startTime") this->setStartTime(Engine::current()->stringToTime(value));
            else if (name == "endTime") this->setEndTime(Engine::current()->stringToTime(value));
            else if (name == "repeatMode") this->setRepeatMode(value);
            else if (name == "repeatParam") this->setRepeatParam(value.toInt());
            else if (name == "repeatUntil") this->setRepeatUntil(Engine::current()->stringToTime(value));
            else if (name == "mask") {
                QString maskTxt = value;
                maskTxt.replace(';', '\n');
                this->setMask(maskTxt);
            }
        }
    }
    */
    
    QJsonObject Instance::saveToJson()
    {
        QJsonObject json = QJsonObject();
        
        json["startTime"] = Engine::current()->timeToString(this->startTime());
        json["endTime"] = Engine::current()->timeToString(this->endTime());
        json["repeatMode"] = this->repeatMode();
        json["repeatParam"] = this->repeatParam();
        json["repeatUntil"] = Engine::current()->timeToString(this->repeatUntil());
        json["mask"] = this->getMask();
        json["permanent"] = this->permanent();
        
        return json;
    }
    
    void Instance::loadFromJson(const QJsonObject& json)
    {
        this->setStartTime(Engine::current()->stringToTime(json["startTime"].toString()));
        this->setEndTime(Engine::current()->stringToTime(json["endTime"].toString()));
        this->setRepeatMode(json["repeatMode"].toString());
        this->setRepeatParam(json["repeatParam"].toInt());
        this->setRepeatUntil(Engine::current()->stringToTime(json["repeatUntil"].toString()));
        this->setMask(json["mask"].toString());
        this->setPermanent(json["permanent"].toBool(false));
    }
}
