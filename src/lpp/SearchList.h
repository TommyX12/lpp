#pragma once

#include <QObject>

#include "utils/QObjectVector.h"
#include "utils/Types.h"

class QString;

namespace LPP
{

    class SearchInfo;
    class IQmlSearchable;
    
    class SearchList: public QObject
    {
        Q_OBJECT
        
        Q_PROPERTY(Int size READ size)
        
    public:
        
        SearchList();
        virtual ~SearchList();
        
        void clear();
        void addEntry(IQmlSearchable*);
        
        Int size();
        Q_INVOKABLE QObject* at(Int);
        
        Q_INVOKABLE void refresh(const QString&, bool, bool);
        
        static bool compare(SearchInfo*, SearchInfo*);
        
        QVector<SearchInfo*> &getData();
        
    private:
        QVector<SearchInfo*> m_data;
        
    public slots:
        
    signals:
        //void sizeChanged();
    };
}

