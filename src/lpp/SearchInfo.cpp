#include "SearchInfo.h"

namespace LPP
{
    SearchInfo::SearchInfo(): QObject(nullptr)
    {
        this->m_object = nullptr;
        this->maxJ = this->maxJPos = 0;
    }
    
    SearchInfo::~SearchInfo()
    {
        
    }
    
    IQmlSearchable* SearchInfo::object()
    {
        return this->m_object;
    }
    
    IQmlSearchable* SearchInfo::setObject(IQmlSearchable* object)
    {
        return this->m_object = object;
    }
}
