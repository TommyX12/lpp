import QtQuick 2.0
import QtQuick.Controls 1.4
import lpp 1.0

import modules.lpp_utils 1.0

    
PageView {
    
    id: content;
    
    property string title: currentItem.title;
    
    property alias overview: overview;
    
    enabled: !root.timeline.editing;
    
    Component.onCompleted: function(){
        show(overview);
    }
    
    Overview {
        id: overview
    }
}

