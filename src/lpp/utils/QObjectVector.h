#pragma once

#include <QObject>
#include <QVector>

#include "Types.h"

namespace LPP
{
    class QObjectVector : public QObject
    {
        Q_OBJECT
        
        Q_PROPERTY(Int size READ size NOTIFY sizeChanged)
        
    public:
        explicit QObjectVector();
        virtual ~QObjectVector();
        
        Int size();
        Q_INVOKABLE QObject* at(Int);
        void push(QObject*);
        void insert(Int, QObject*);
        void remove(Int);
        void remove(QObject*);
        void clear();
        
        QVector<QObject*> &getData();
        
        bool deleteChildrenOnDestroy;
        
    private:
        QVector<QObject*> m_data;
        
    signals:
        void sizeChanged();
        
    public slots:
    };
}
