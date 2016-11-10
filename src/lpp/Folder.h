#pragma once

#include "utils/QObjectVector.h"
#include <QString>
#include <QColor>
#include "IQmlSearchable.h"
#include "ISavable.h"

namespace LPP
{
    class Folder: public IQmlSearchable, public ISavable
    {
        Q_OBJECT
        
        Q_PROPERTY(QString type READ type NOTIFY typeChanged)
        Q_PROPERTY(QString typeName READ typeName NOTIFY typeChanged)
        Q_PROPERTY(Int id READ id NOTIFY idChanged)
        Q_PROPERTY(QString name READ name WRITE setName NOTIFY nameChanged)
        Q_PROPERTY(QString note READ note WRITE setNote NOTIFY noteChanged)
        Q_PROPERTY(QColor color READ color WRITE setColor NOTIFY colorChanged)
        Q_PROPERTY(bool useParentFolderColor READ useParentFolderColor WRITE setUseParentFolderColor NOTIFY useParentFolderColorChanged)
        Q_PROPERTY(Folder* parentFolder READ parentFolder NOTIFY parentFolderChanged)
        Q_PROPERTY(QObjectVector* folders READ folders)
        Q_PROPERTY(QObjectVector* actions READ actions)
        Q_PROPERTY(QObjectVector* plans READ plans)
        
    public:
        Folder();
        virtual ~Folder();
        
        QString type();
        QString typeName();
        
        Int id();
        Int setID(Int);
        
        virtual void updateFullPath();
        void updateChildrenColor();
        
        QString name();
        QString setName(const QString&);
        
        QString note();
        QString setNote(const QString&);
        
        QColor color();
        QColor setColor(const QColor&);
        
        bool useParentFolderColor();
        bool setUseParentFolderColor(bool);
        
        virtual Folder* setParentFolder(Folder*);
        
        QObjectVector* folders();
        QObjectVector* actions();
        QObjectVector* plans();
        
        //virtual void setParam(const QString&, const QString&);
        //virtual QVector<QPair<QString, QString>> getParams();
        
        virtual QJsonObject saveToJson();
        virtual void loadFromJson(const QJsonObject&);
        
        virtual QString getFileName();
        
    private:
        Int m_id;
        QString m_name, m_note;
        QColor m_color;
        bool m_useParentFolderColor;
        
        QObjectVector m_folders, m_actions, m_plans;
    
    signals:
        void idChanged();
        void nameChanged();
        void noteChanged();
        void colorChanged();
        void parentFolderChanged();
        void useParentFolderColorChanged();
        
        void typeChanged();
    };
    
}
