import QtQuick 2.6
import QtQuick.Controls 1.4
import QtQuick.Layouts 1.3
import "components"

import modules.lpp_utils 1.0

Item {
    id: root
    
    property string title: qsTr("Test")
    
    signal enter();
    
    
    Rectangle {
        width: 480
        height: 320
        Rectangle {
            x: 30; y: 30
            width: 300; height: 240
            color: "lightsteelblue"
    
            MouseArea {
                anchors.fill: parent
                drag.target: parent;
                drag.axis: "XAxis"
                drag.minimumX: 30
                drag.maximumX: 150
                drag.filterChildren: true
    
                Rectangle {
                    color: ma.pressed ? "yellow" : "black"
                    x: 50; y : 50
                    width: 100; height: 100
                    MouseArea {
                        id: ma
                        anchors.fill: parent
                        onClicked: console.log("Clicked")
                    }
                }
            }
        }
    }
}
