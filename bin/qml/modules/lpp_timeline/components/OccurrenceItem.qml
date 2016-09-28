import QtQuick 2.6
import QtQuick.Controls 1.4
import QtQuick.Layouts 1.3
import lpp 1.0
import QtQuick.Dialogs 1.2

import lpp 1.0
import modules.lpp_utils 1.0

Item {
    height: 27
    
    property Occurrence object: null;
    property int index: 0;
    
    function refresh(){
        
    }
    
    SimpleButton {
        
        id: button
        
        clip: true
        
        height: 23
        anchors.left: parent.left
        anchors.right: parent.right
        
        Component.onCompleted: {
            //borderColor = Qt.binding(function(){return object.plan.parentFolder.color;});
        }
        
        Rectangle {
            anchors.top: parent.top
            anchors.topMargin: 2
            anchors.bottom: parent.bottom
            anchors.bottomMargin: 2
            anchors.left: parent.left
            anchors.leftMargin: 2
            width: 5
            border.width: 1
            border.color: "grey"
            color: {
                if (object == null) return "#000000"
                else if (object.impossible) return "#ff0000"
                else if (object.progress < 1.0) return "#eebb55"
                else if (object.progressNow == 1.0) return "#44cc44"
                else return "#cccccc"
            }
            
            
        }
        
        RowLayout {
            
            anchors.verticalCenter: button.verticalCenter
            anchors.left: button.left
            anchors.leftMargin: 10 
            
            spacing: 5
            
            
            Rectangle {
                width: 15
                height: 12
                color: object == null ? "#000000" : object.plan.parentFolder.color
            }
            
            Label {
                
                font.bold: true
                
                color: button.label.color
                
                text: object == null ? "" : object.plan.name
            }
            
            Label {
                id: repeatTxt
                
                //font.bold: true
                
                color: button.label.color
                
                text: object == null ? "" : ("[" + Engine.timeSpanToString(object.startTime, object.endTime) + "]");
            }
        }
        
        //buttonColor: object == null ? "#000000" : object.plan.parentFolder.color
        buttonColor: "#E0E0E0"
        
        text: ""
        
        onClicked: {
            root.occurrenceWindow.show(object);
        }
    }
    
    DoubleProgressBar {
        anchors.left: button.left
        anchors.right: button.right
        anchors.top: button.bottom
        height: 4
        progress1: object.progress
        progress2: object.progressNow
    }
}
