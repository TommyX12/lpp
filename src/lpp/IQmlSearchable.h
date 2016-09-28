#pragma once

#include <QObject>
#include <QString>

#include "utils/Types.h"

namespace LPP
{
    
    class IQmlSearchable: public QObject
    {
        Q_OBJECT
        
        Q_PROPERTY(QString fullPath READ fullPath NOTIFY fullPathChanged)
        
    public:
        
        IQmlSearchable();
        virtual ~IQmlSearchable();
        
        QString fullPath();
        QString fullPathLower();
        QString setFullPath(const QString&);
        virtual void updateFullPath();
        
    private:
        QString m_fullPath, m_fullPathLower;
        
    public slots:
        
    signals:
        void fullPathChanged();
    };
}

