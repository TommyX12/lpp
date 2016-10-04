import QtQuick 2.6
import QtQuick.Controls 1.4
import QtQuick.Layouts 1.3
import lpp 1.0
import QtQuick.Dialogs 1.2

import lpp 1.0
import modules.lpp_utils 1.0

RowLayout {
    id: item
    
    property Plan object: null;
    property int index: 0;
    property var list: null;
    
    property alias button: button
    
    property var editFunc: null;
    property var deleteFunc: null;

    SimpleButton {
        
        clip: true
        
        Layout.fillWidth: true;
        
        id: button
        
        height: 25
        
        RowLayout {
            
            anchors.verticalCenter: button.verticalCenter
            anchors.left: button.left
            anchors.leftMargin: 5
            
            spacing: 5
            
            Rectangle {
                height: 15
                width: 20
                visible: object != null
                color: object == null ? "#000000" : object.objectives.at(0).action.parentFolder.color;
                border.color: "grey"
            }
            
            Label {
                
                font.bold: true
                
                color: button.label.color
                
                text: object == null ? "" : ((object.name.length == 0 ? qsTr("(unnamed)") : object.name) + (object.permanent ? qsTr("(permanent)") : ""));
            }
            
            Label {
                
                font.bold: true
                
                color: button.label.color
                
                text: object == null ? "" : ("[" + qsTr("Req: ") + Engine.minutesToString(object.objectives.at(0).length) + "]");
            }
            
            Label {
                
                //font.bold: true
                
                color: button.label.color
                
                text: object == null ? "" : ("[" + Engine.timeSpanToString(object.instances.at(0).startTime, object.instances.at(0).endTime) + "]");
            }
            
            Label {
                id: repeatTxt
                
                color: button.label.color
                
                text: ""
            }
        }
        
        buttonColor: "#dddddd"
        
        text: object != null ? "" : qsTr("+ Add")
        
        onClicked: {
            if (object != null) list.itemTriggered(object, index, 1);
            else list.itemTriggered(object, index, 0);
        }
    }
    
    SimpleButton {
        visible: object != null
        height: button.height
        width: 50
        text: qsTr("Delete");
        onClicked: {
            list.itemTriggered(object, index, 2);
        }
    }
    
    function refresh(){
        repeatTxt.text = object == null ? "" : Utils.getRepeatTxt(object.instances.at(0));
    }
}
