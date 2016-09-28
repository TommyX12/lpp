#include "TimelineMarker.h"

namespace LPP
{
    TimelineMarker::TimelineMarker()
    {
        this->m_action = nullptr;
        this->m_isAuto = false;
    }
    
    TimelineMarker::~TimelineMarker()
    {
        
    }
    
    QDateTime TimelineMarker::time()
    {
        return this->m_time;
    }
    
    QDateTime TimelineMarker::setTime(const QDateTime& time)
    {
        this->m_time = time.toUTC();
        emit this->timeChanged();
        return this->m_time;
    }
    
    Action* TimelineMarker::action()
    {
        return this->m_action;
    }
    
    Action* TimelineMarker::setAction(Action* action, bool isAuto)
    {
        this->m_action = action;
        emit this->actionChanged();
        
        this->m_isAuto = isAuto;
        emit this->isAutoChanged();
        
        return this->m_action;
    }
    
    bool TimelineMarker::isAuto()
    {
        return this->m_isAuto;
    }
    
    bool TimelineMarker::mergable(TimelineMarker* marker)
    {
        return this->action() == marker->action() && this->isAuto() == marker->isAuto();
    }
    
    /*
    bool TimelineMarker::setIsAuto(bool isAuto)
    {
        this->m_isAuto = isAuto;
        emit this->isAutoChanged();
        return this->m_isAuto;
    }
    */
}
