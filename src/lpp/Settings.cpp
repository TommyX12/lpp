#include "Settings.h"

#include <QVariant>
#include <QMetaObject>
#include <QMetaProperty>

namespace LPP
{
    Settings::Settings()
    {
        
    }
    
    Settings::~Settings()
    {
        
    }
    
    /*
    void Settings::setParam(const QString& name, const QString& value)
    {
        QByteArray array = name.toLatin1();
        this->setProperty(array.data(), QVariant(value));
    }
    
    QVector<QPair<QString, QString>> Settings::getParams()
    {
        QVector<QPair<QString, QString>> params;
        
        const QMetaObject* metaObject = this->metaObject();
        
        for(int i = metaObject->propertyOffset(); i < metaObject->propertyCount(); ++i){
            QString name = QString::fromLatin1(metaObject->property(i).name());
            QByteArray array = name.toLatin1();
            QString value = this->property(array.data()).toString();
            params.append(QPair<QString, QString>(name, value));
        }
        
        return params;
    }
    */
    
    QJsonObject Settings::saveToJson()
    {
        QJsonObject json = QJsonObject();
        
        const QMetaObject* metaObject = this->metaObject();
        
        for(int i = metaObject->propertyOffset(); i < metaObject->propertyCount(); ++i){
            QString name = QString::fromLatin1(metaObject->property(i).name());
            QByteArray array = name.toLatin1();
            json[name] = this->property(array.data()).toString();
        }
        
        return json;
    }
    
    void Settings::loadFromJson(const QJsonObject& json)
    {
        const QMetaObject* metaObject = this->metaObject();
        
        for(int i = metaObject->propertyOffset(); i < metaObject->propertyCount(); ++i){
            QString name = QString::fromLatin1(metaObject->property(i).name());
            QByteArray array = name.toLatin1();
            this->setProperty(array.data(), QVariant(json[name].toString()));
        }
    }
}
