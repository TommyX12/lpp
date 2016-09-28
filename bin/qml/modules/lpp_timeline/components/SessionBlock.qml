import QtQuick 2.0
import QtQuick.Controls 1.4

import lpp 1.0

import modules.lpp_utils 1.0

Item {
    id: block
    
    height: 100
    width: 320
    
    property alias sessionBlock: sessionBlock
    
    property TimelineMarker marker: null;
    property var time;
    
    property real hideDistance: 15;
    
    property color autoColor: "#aaaaaa"
    
    Component.onCompleted: {
        reposition();
    }
    
    Rectangle {
        id: autoRect
        
        anchors.left: parent.left
        anchors.top: parent.top
        anchors.bottom: parent.bottom
        
        color: autoColor
        
        width: (marker == null || marker.isAuto || marker.action == null) ? 0 : 5
        
    }
    
    SimpleButton {
        id: sessionBlock
        
        anchors.top: parent.top
        anchors.bottom: parent.bottom
        anchors.right: parent.right
        anchors.left: parent.left//autoRect.right;
        
        anchors.leftMargin: 8//(marker != null && marker.isAuto) ? 3 : 0
        /*
        anchors.right: parent.right
        anchors.rightMargin: parent.rightMargin;
        anchors.left: parent.left;
        anchors.leftMargin: parent.sessionViewX;
        */
        
        enabled: sessionBlock.visible;
        
        
        label.anchors.centerIn: null
        label.anchors.left: sessionBlock.left
        label.anchors.leftMargin: 20
        label.anchors.verticalCenter: sessionBlock.verticalCenter
    }
    
    MouseArea {
        anchors.fill: parent;
        enabled: block.visible;
        onClicked: {
            timeline.editSession(block.marker);
        }
    }
    
    function reposition(){
        sessionBlock.label.visible = height >= hideDistance;
    }
}
