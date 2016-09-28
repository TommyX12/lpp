#pragma once

#include <QObject>
#include <QString>

#include "IQmlSearchable.h"

#include "utils/Types.h"

namespace LPP
{
    
    class SearchInfo: public QObject
    {
        Q_OBJECT
        
        Q_PROPERTY(IQmlSearchable* object READ object)
        
    public:
        
        SearchInfo();
        virtual ~SearchInfo();
        
        IQmlSearchable* object();
        IQmlSearchable* setObject(IQmlSearchable*);
        
        Int maxJ, maxJPos;
        
    private:
        IQmlSearchable* m_object;
        
    public slots:
        
    signals:
    };
}

