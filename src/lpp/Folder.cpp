#include "Folder.h"
#include "Action.h"
#include "Plan.h"
#include "GlobalVars.h"

#include "Engine.h"

#include <QJsonArray>

namespace LPP
{
    Folder::Folder()
    {
        
        this->m_id = -1;
        
        this->m_name = "";
        this->m_note = "";
        this->m_color.setRgb(200, 200, 200, 255);
        this->m_useParentFolderColor = false;
        
        this->updateFullPath();
    }
    
    Folder::~Folder()
    {
        
        
    }
    
    QString Folder::type()
    {
        return "folder";
    }
    QString Folder::typeName()
    {
        return "Folder";
    }
    
    QObjectVector* Folder::folders()
    {
        return &this->m_folders;
    }
    
    QObjectVector* Folder::actions()
    {
        return &this->m_actions;
    }
    
    QObjectVector* Folder::plans()
    {
        return &this->m_plans;
    }
    
    Int Folder::id()
    {
        return this->m_id;
    }
    
    Int Folder::setID(Int id)
    {
        Engine::current()->setOccurrencesChanged();
        
        this->m_id = id;
        emit this->idChanged();
        return this->m_id;
    }
    
    void Folder::updateFullPath()
    {
        if (this->parentFolder() != nullptr) this->setFullPath(this->parentFolder()->fullPath() + "/" + this->name());
        else this->setFullPath("");
        for (auto object:this->folders()->getData()) static_cast<IQmlSearchable*>(object)->updateFullPath();
        for (auto object:this->actions()->getData()) static_cast<IQmlSearchable*>(object)->updateFullPath();
        for (auto object:this->plans()->getData()) static_cast<IQmlSearchable*>(object)->updateFullPath();
    }
    
    void Folder::updateChildrenColor()
    {
        for (auto object:this->folders()->getData()) {
            Folder* folder = static_cast<Folder*>(object);
            if (folder->useParentFolderColor()) folder->setColor(this->color());
        }
    }
    
    QString Folder::name()
    {
        return this->m_name;
    }
    
    QString Folder::setName(const QString& name)
    {
        Engine::current()->setOccurrencesChanged();
        
        this->m_name = name;
        emit this->nameChanged();
        this->updateFullPath();
        return this->m_name;
    }
    
    QString Folder::note()
    {
        return this->m_note;
    }
    
    QString Folder::setNote(const QString& note)
    {
        Engine::current()->setOccurrencesChanged();
        
        this->m_note = note;
        emit this->noteChanged();
        return this->m_note;
    }
    
    QColor Folder::color()
    {
        return this->m_color;
    }
    
    QColor Folder::setColor(const QColor& color)
    {
        Engine::current()->setOccurrencesChanged();
        
        this->m_color = (this->m_useParentFolderColor && this->parentFolder() != nullptr) ? this->parentFolder()->color(): color;
        emit this->colorChanged();
        this->updateChildrenColor();
        return this->m_color;
    }
    
    bool Folder::useParentFolderColor()
    {
        return this->m_useParentFolderColor;
    }
    
    bool Folder::setUseParentFolderColor(bool value)
    {
        this->m_useParentFolderColor = value;
        emit useParentFolderColorChanged();
        this->setColor(this->color());
        return this->m_useParentFolderColor;
    }
    
    Folder* Folder::setParentFolder(Folder* parentFolder)
    {
        Engine::current()->setOccurrencesChanged();
        
        this->m_parentFolder = parentFolder;
        emit this->parentFolderChanged();
        this->updateFullPath();
        this->setColor(this->color());
        return this->m_parentFolder;
    }
    
    /*
    void Folder::setParam(const QString& name, const QString& value)
    {
        if (name == "name") this->setName(value);
        else if (name == "note") this->setNote(value);
        else if (name == "color") this->setColor(QColor(value));
        else if (name == "useParentFolderColor") this->setUseParentFolderColor(value.toInt());
    }

    QVector<QPair<QString, QString>> Folder::getParams()
    {
        QVector<QPair<QString, QString>> params;
        params.append(QPair<QString, QString>("name", this->name()));
        params.append(QPair<QString, QString>("note", this->note()));
        params.append(QPair<QString, QString>("useParentFolderColor", QString::number(this->useParentFolderColor())));
        params.append(QPair<QString, QString>("color", this->color().name()));
        
        return params;
    }
    */
    
    QJsonObject Folder::saveToJson()
    {
        QJsonObject json = QJsonObject();
        
        json["name"] = this->name();
        json["note"] = this->note();
        json["useParentFolderColor"] = this->useParentFolderColor();
        json["color"] = this->color().name();
        
        return json;
    }
    
    void Folder::loadFromJson(const QJsonObject& json)
    {
        this->setName(json["name"].toString());
        this->setNote(json["note"].toString());
        this->setUseParentFolderColor(json["useParentFolderColor"].toBool());
        this->setColor(QColor(json["color"].toString()));
    }
    
    QString Folder::getFileName()
    {
        return this->id() == -1 ? e_rootFolderFileName : "/" + e_folderFileNamePrefix + QString::number(this->id());
    }
}
