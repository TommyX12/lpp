#include "Occurrence.h"

#include "GlobalVars.h"

#include "Plan.h"

#include "Engine.h"

namespace LPP
{

    Occurrence::Occurrence()
    {
        this->m_plan = nullptr;
        this->m_instance = nullptr;
        this->m_impossible = false;
        
        this->m_progress = this->m_progressNow = 0.0;
        
        this->resetMinRequirement();
    }
    
    Occurrence::~Occurrence()
    {
        
    }
    
    void Occurrence::reset()
    {
        this->resetMinRequirement();
        
        int l = this->plan()->objectives()->size();
        for (int i = 0; i < l; ++i) {
            this->status[i] = this->statusNow[i] = 0;
        }
        
        this->setImpossible(false);
    }
    
    QDateTime Occurrence::startTime()
    {
        return this->m_startTime;
    }
    
    QDateTime Occurrence::setStartTime(const QDateTime& startTime)
    {
        this->m_startTime = startTime.toUTC();
        emit this->startTimeChanged();
        return this->m_startTime;
    }
    
    QDateTime Occurrence::endTime()
    {
        return this->m_endTime;
    }
    
    QDateTime Occurrence::setEndTime(const QDateTime& endTime)
    {
        this->m_endTime = endTime.toUTC();
        emit this->endTimeChanged();
        return this->m_endTime;
    }
    
    Plan* Occurrence::plan()
    {
        return this->m_plan;
    }
    
    Plan* Occurrence::setPlan(Plan* plan)
    {
        this->m_plan = plan;
        emit this->planChanged();
        return this->m_plan;
    }
    
    Instance* Occurrence::instance()
    {
        return this->m_instance;
    }
    
    Instance* Occurrence::setInstance(Instance* instance)
    {
        this->m_instance = instance;
        emit this->instanceChanged();
        return this->m_instance;
    }
    
    Int Occurrence::getStatus(Int index)
    {
        return this->status[index];
    }
    
    Int Occurrence::getStatusNow(Int index)
    {
        return this->statusNow[index];
    }
    
    Int Occurrence::minRequirement()
    {
        return this->m_minRequirement < 0 ? 0 : this->m_minRequirement;
    }
    
    void Occurrence::resetMinRequirement()
    {
        this->m_minRequirement = -1;
    }
    
    void Occurrence::setMinRequirement(Int value)
    {
        if (this->m_plan->completionMode() == 0){
            if (this->m_minRequirement < 0) this->m_minRequirement = value;
            else this->m_minRequirement += value;
        }
        else if (this->m_plan->completionMode() == 1){
            if (this->m_minRequirement < 0) this->m_minRequirement = value;
            else this->m_minRequirement = std::min(this->m_minRequirement, value);
        }
    }
    
    bool Occurrence::impossible()
    {
        return this->m_impossible;
    }
    
    bool Occurrence::setImpossible(bool impossible)
    {
        this->m_impossible = impossible;
        emit this->impossibleChanged();
        return this->m_impossible;
    }
    
    Float Occurrence::progress()
    {
        return this->m_progress;
    }
    
    Float Occurrence::progressNow()
    {
        return this->m_progressNow;
    }
    
    void Occurrence::updateProgress()
    {
        if (!this->status.size()) return;
        
        if (this->m_plan->completionMode() == 0){
            Float totalProgress = 0.0;
            Float totalProgressNow = 0.0;
            Float totalRequired = 0.0;
            for (int i = 0; i < this->status.size(); ++i){
                Float required = (Float)static_cast<Objective*>(this->plan()->objectives()->at(i))->length();
                totalProgress += std::min((Float)this->status[i], required);
                totalProgressNow += std::min((Float)this->statusNow[i], required);
                totalRequired += required;
            }
            if (totalRequired == 0.0) this->m_progress = this->m_progressNow = 1.0;
            else {
                this->m_progress = std::min(1.0f, totalProgress / totalRequired);
                this->m_progressNow = std::min(1.0f, totalProgressNow / totalRequired);
            }
        }
        else if (this->m_plan->completionMode() == 1){
            this->m_progress = this->m_progressNow = 0;
            for (int i = 0; i < this->status.size(); ++i){
                Float required = (Float)static_cast<Objective*>(this->plan()->objectives()->at(i))->length();
                if (required == 0.0){
                    this->m_progress = this->m_progressNow = 1.0;
                    break;
                }
                else {
                    this->m_progress = std::max(this->m_progress, std::min(1.0f, (Float)this->status[i] / required));
                    this->m_progressNow = std::max(this->m_progressNow, std::min(1.0f, (Float)this->statusNow[i] / required));
                }
            }
        }
        emit this->progressChanged();
        emit this->progressNowChanged();
    }
}
