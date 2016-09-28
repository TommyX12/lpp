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
    
    QString Instance::getParams()
    {
        QString str;
        QTextStream text(&str);
        text << "startTime," << Engine::current()->timeToString(this->startTime()) << ",";
        text << "endTime," << Engine::current()->timeToString(this->endTime()) << ",";
        text << "repeatMode," << this->repeatMode() << ",";
        text << "repeatParam," << this->repeatParam() << ",";
        text << "repeatUntil," << Engine::current()->timeToString(this->repeatUntil()) << ",";
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
        }
    }
}
