#include "Utils.h"

#include <Qstring>

namespace LPP
{
    namespace Utils
    {
        QPair<Int, Int> stringMatching(const QString& baseStr, const QString& matchingStr, const QVector<Int>& matchingInfo, bool preferHigherPos)
        {
            if (!baseStr.length() || !matchingStr.length()) return QPair<Int, Int>(-1, 0);
            
            Int score = 0;
            
            int j = 0, maxJ = 0, maxJPos = -1;
            for (int i = 0; i < baseStr.length(); i++){
                while (baseStr[i] != matchingStr[j] && j >= 0) j = matchingInfo[j];
                j++;
                if (j > maxJ || (j == maxJ && preferHigherPos)){
                    maxJ = j;
                    maxJPos = i - j + 1;
                }
                if (j == matchingStr.length()) j = matchingInfo[j];
            }
            
            return QPair<Int, Int>(maxJ, maxJPos);
        }
        
        QVector<Int> generateMatchingInfo(const QString& matchingStr)
        {
            QVector<Int> next(matchingStr.length()+1);
            
            if (!matchingStr.length()) return next;
            
            //Int* next = new Int[matchingStr.length()+1];
            
            next[0] = -1; next[1] = 0;
            
            int j = 0;
            for (int i = 1; i < matchingStr.length(); i++){
                while (matchingStr[i] != matchingStr[j] && j >= 0) j = next[j];
                next[i+1] = ++j;
            }
            
            return next;
        }
    }
}
