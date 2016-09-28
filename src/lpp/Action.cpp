#include "Action.h"
#include "Session.h"


#include "GlobalVars.h"

#include "Engine.h"


namespace LPP
{
    Action::Action()
    {
        
        this->m_id = -1;
        this->m_name = "--";
        this->m_note = "";
        this->updateFullPath();
    }
    
    Action::~Action()
    {
        
        /*
        for (Session* session:this->m_sessions){
            delete session;
        }
        */
    }
    
    QString Action::type()
    {
        return "action";
    }
    QString Action::typeName()
    {
        return "Action";
    }
    
    Int Action::id()
    {
        return this->m_id;
    }
    
    Int Action::setID(Int id)
    {
        Engine::current()->setOccurrencesChanged();
        
        return this->m_id = id;
    }
    
    void Action::updateFullPath()
    {
        if (this->parentFolder() != nullptr) this->setFullPath(this->parentFolder()->fullPath() + "/" + this->name());
        else this->setFullPath(this->name());
    }
    
    Folder* Action::setParentFolder(Folder* parentFolder)
    {
        Engine::current()->setOccurrencesChanged();
        
        this->m_parentFolder = parentFolder;
        emit this->parentFolderChanged();
        this->updateFullPath();
        return this->m_parentFolder;
    }
    
    QString Action::name()
    {
        return this->m_name;
    }
    
    QString Action::setName(const QString & name)
    {
        Engine::current()->setOccurrencesChanged();
        
        this->m_name = name;
        emit this->nameChanged();
        this->updateFullPath();
        return this->m_name;
    }
    
    QString Action::note()
    {
        return this->m_note;
    }
    
    QString Action::setNote(const QString & note)
    {
        Engine::current()->setOccurrencesChanged();
        
        this->m_note = note;
        emit this->noteChanged();
        return this->m_note;
    }
    
    void Action::setParam(const QString& name, const QString& value)
    {
        if (name == "name") this->setName(value);
        else if (name == "note") this->setNote(value);
    }

    QVector<QPair<QString, QString>> Action::getParams()
    {
        QVector<QPair<QString, QString>> params;
        params.append(QPair<QString, QString>("name", this->name()));
        params.append(QPair<QString, QString>("note", this->note()));
        
        return params;
    }
    
    QString Action::getFileName()
    {
        return "/" + e_actionFileNamePrefix + QString::number(this->id());
    }
}
