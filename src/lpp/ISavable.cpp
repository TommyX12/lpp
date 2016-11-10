#include "ISavable.h"

#include <QJsonDocument>
#include <QDir>
#include <QTextStream>

#include <QDebug>

//#include "Engine.h"

namespace LPP
{
    ISavable::ISavable()
    {
        this->m_parentFolder = nullptr;
    }
    
    ISavable::~ISavable()
    {
        
    }
    
    /*
    void ISavable::setParam(const QString& name, const QString& value)
    {
        
    }
    
    void ISavable::setParams(const QVector<QPair<QString, QString>>& params)
    {
        for (auto param:params){
            setParam(param.first, param.second);
        }
    }
    
    QVector<QPair<QString, QString>> ISavable::getParams()
    {
        
    }
    */
    
    
    //implement those new methods
    QJsonObject ISavable::saveToJson()
    {
        return QJsonObject();
    }
    
    QString ISavable::saveToString()
    {
        return QString(QJsonDocument(this->saveToJson()).toJson(QJsonDocument::Indented));
    }
    
    void ISavable::saveToFile(const QString& filePath, const QString& fileName)
    {
        qDebug() << "saving:" << filePath + fileName;
        
        QDir dir;
        dir.mkpath(filePath);
        QFile file(filePath + fileName);
        if (file.open(QIODevice::WriteOnly | QIODevice::Truncate | QIODevice::Text)){
            QTextStream outText(&file);
            outText << this->saveToString();
            
            file.close();
            
            qDebug() << "done.";
        }
        
        else {
            throw "!!!WARNING: saving failed!!!";
        }
    }
    
    
    void ISavable::loadFromJson(const QJsonObject& json)
    {
        
    }
    
    void ISavable::loadFromString(const QString& string)
    {
        this->loadFromJson(QJsonDocument::fromJson(string.toUtf8()).object());
    }
    
    void ISavable::loadFromFile(const QString& fileFullPath)
    {
        qDebug() << "loading:" << fileFullPath;
        
        QFile file(fileFullPath);
        if (!file.exists()) {
            qDebug() << "file does not exist.";
            return;
        }
        
        if (file.open(QIODevice::ReadOnly | QIODevice::Text)){
            QTextStream inText(&file);
            this->loadFromString(inText.readAll());
            
            file.close();
            
            qDebug() << "done.";
        }
        
        else {
            throw "!!!WARNING: loading failed!!!";
        }
    }
    
    
    QString ISavable::getFileName()
    {
        return "";
    }
    
    Folder* ISavable::parentFolder()
    {
        return this->m_parentFolder;
    }
    
    Folder* ISavable::setParentFolder(Folder* parentFolder)
    {
        
    }
}
