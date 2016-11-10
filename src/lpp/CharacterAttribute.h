#pragma once

#include <QObject>
#include <QQuickItem>
#include <QString>

//#include "Mission.h"
#include "utils/Types.h"

namespace LPP
{
    
    class CharacterAttribute: public QObject
    {
        Q_OBJECT
        
        Q_PROPERTY(QString name READ name NOTIFY nameChanged)
        Q_PROPERTY(Int id READ id NOTIFY idChanged)
        //Q_PROPERTY(QString name READ name WRITE setName NOTIFY nameChanged)
        //Q_PROPERTY(bool isBuiltIn READ isBuiltIn NOTIFY isBuiltInChanged)
        
    public:
        
        CharacterAttribute();
        virtual ~CharacterAttribute();
        
        QString name();
        QString setName(const QString&);
        
        Int id();
        Int setID(Int);        
        
        //bool isBuiltIn();
        //bool setIsBuiltIn(bool);
        
    private:
        QString m_name;
        Int m_id;
        //bool m_isBuiltIn;
        
    signals:
        void nameChanged();
        void idChanged();
        //void isBuiltInChanged();
        
    };
}

