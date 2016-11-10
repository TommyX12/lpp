#pragma once

#include "Types.h"
#include <QPair>
#include <QVector>

class QString;

namespace LPP
{
    namespace Utils
    {
        QPair<Int, Int> stringMatching(const QString&, const QString&, const QVector<Int>&, bool);
        QVector<Int> generateMatchingInfo(const QString&);
        
        QPair<Int, Int> sequenceMatching(const QString&, const QString&, bool);
    }
}
