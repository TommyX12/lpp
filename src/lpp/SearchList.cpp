#include "SearchList.h"
#include "SearchInfo.h"

#include "utils/Utils.h"
#include <QString>
#include <QPair>

#include <algorithm>

#include <QQmlEngine>

#include "IQmlSearchable.h"

#include <QQuickItem>

namespace LPP
{
    SearchList::SearchList(): QObject(nullptr)
    {
        
    }
    
    SearchList::~SearchList()
    {
        this->clear();
    }
    
    void SearchList::clear()
    {
        for (SearchInfo* object:this->m_data){
            delete object;
        }
        this->m_data.clear();
    }
    
    void SearchList::addEntry(IQmlSearchable* object)
    {
        SearchInfo* newEntry = new SearchInfo();
        QQmlEngine::setObjectOwnership(newEntry, QQmlEngine::CppOwnership);
        newEntry->setObject(object);
        
        this->m_data.push_back(newEntry);
    }
    
    Int SearchList::size()
    {
        return this->m_data.size();
    }
    
    QObject* SearchList::at(Int i)
    {
        return (i >= 0 && i < this->m_data.size()) ? this->m_data[i] : nullptr;
    }
    
    bool SearchList::compare(SearchInfo* a, SearchInfo* b)
    {
        return a->maxJ > b->maxJ || (a->maxJ == b->maxJ && (a->maxJPos > b->maxJPos));
    }
    
    void SearchList::refresh(const QString& searchStr, bool caseSensitive, bool fuzzy)
    {
        QString matchingStr = caseSensitive ? searchStr : searchStr.toLower();
        QVector<Int> matchingInfo;
        if (!fuzzy){
            matchingInfo = Utils::generateMatchingInfo(matchingStr);
        }
        
        for (SearchInfo* info:this->m_data){
            const QString& baseStr = caseSensitive ? info->object()->fullPath() : info->object()->fullPathLower();
            QPair<Int, Int> matchingResult;
            if (fuzzy){
                matchingResult = Utils::sequenceMatching(baseStr, matchingStr, true);
            }
            else {
                matchingResult = Utils::stringMatching(baseStr, matchingStr, matchingInfo, true);
            }
            info->maxJ = matchingResult.first;
            info->maxJPos = matchingResult.second - baseStr.length();
            //qDebug() << matchingResult;
        }
        
        std::sort(this->m_data.begin(), this->m_data.end(), compare);
        
        //qDebug() << "did this shit even happen";
    }
    
    QVector<SearchInfo*>& SearchList::getData()
    {
        return this->m_data;
    }
}
