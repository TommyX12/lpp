import QtQuick 2.0
import QtQuick.Controls 1.4
import QtQuick.Dialogs 1.2
import lpp 1.0

import modules.lpp_utils 1.0

PageView {
    id: content
    
    property string title: currentItem.title;
    
    property alias overview: overview;
    property alias editor: editor;
    
    anchors.fill: parent
    
    Component.onCompleted: function (){
        show(overview);
    }
    
    Overview {
        id: overview
    }
    
    Editor {
        id: editor
    }
}
