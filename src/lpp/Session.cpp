#include "Session.h"
#include "Action.h"

namespace LPP
{
    Session::Session()
    {
        this->m_parentAction = nullptr;
    }

    Session::~Session()
    {
        
    }
    
    Action* Session::parentAction()
    {
        return this->m_parentAction;
    }
}
