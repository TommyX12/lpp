#include "Types.h"

#include <QMetaType>

namespace LPP
{
    void registerQtTypes()
    {
        qRegisterMetaType<Int>("Int");
        qRegisterMetaType<Uint>("Uint");
        qRegisterMetaType<Uint8>("Uint8");
        qRegisterMetaType<Int64>("Int64");
        qRegisterMetaType<Uint64>("Uint64");
        qRegisterMetaType<Float>("Float");
        qRegisterMetaType<Float64>("Float64");
        qRegisterMetaType<Float128>("Float128");
    }
}
