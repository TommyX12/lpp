#include "QObjectVector.h"

#include <QQuickItem>

namespace LPP
{
    QObjectVector::QObjectVector() : QObject()
    {
        this->deleteChildrenOnDestroy = true;
    }
    
    QObjectVector::~QObjectVector()
    {
        this->clear();
    }
    
    Int QObjectVector::size()
    {
        return this->m_data.size();
    }
    
    QObject* QObjectVector::at(Int i)
    {
        return (i >= 0 && i < this->m_data.size()) ? this->m_data[i] : nullptr;
    }
    
    void QObjectVector::push(QObject* element)
    {
        this->m_data.push_back(element);
        emit this->sizeChanged();
    }
    
    void QObjectVector::insert(Int i, QObject* element)
    {
        this->m_data.insert(i, element);
        emit this->sizeChanged();
    }
    
    void QObjectVector::remove(Int i)
    {
        if (i >= 0 && i < this->m_data.size()){
            if (this->deleteChildrenOnDestroy) delete this->m_data[i];
            this->m_data.remove(i);
            emit this->sizeChanged();
        }
    }
    
    void QObjectVector::remove(QObject* pointer)
    {
        for (int i = 0; i < this->m_data.size(); i++){
            if (this->m_data[i] == pointer){
                if (this->deleteChildrenOnDestroy) delete pointer;
                this->m_data.remove(i);
                emit this->sizeChanged();
                return;
            }
        }
    }
    
    void QObjectVector::clear()
    {
        if (this->deleteChildrenOnDestroy) {
            for (QObject* object:this->m_data){
                delete object;
            }
        }
        this->m_data.clear();
        emit this->sizeChanged();
    }
    
    QVector<QObject*>& QObjectVector::getData()
    {
        return this->m_data;
    }
}
