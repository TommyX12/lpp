import QtQuick 2.6
import QtQuick.Controls 1.4
import QtQuick.Layouts 1.3
import lpp 1.0
import QtQuick.Dialogs 1.2

import lpp 1.0
import modules.lpp_utils 1.0
import QtQuick.Layouts 1.1

RowLayout {
    height: 30
    
    property Occurrence object: null;
    property int index: 0;
    property Objective objective: object == null ? null : object.plan.objectives.at(index);
    property real progress: 0
    property real progressNow: 0
    property var list: null;
    
    property bool adjustBtnVisible: true
    property bool clickEnabled: true
    
    function refresh(){
        progressTxt.text = (objective == null) ? "" : "[ " + 
                                                 qsTr("Done: ") + Engine.minutesToString(object.getStatusNow(index)) + "  " + 
                                                 qsTr("Plan: ") + Engine.minutesToString(object.getStatus(index)) + "  " + 
                                                 qsTr("Left: ") + Engine.minutesToString(Math.max(0, objective.length - object.getStatusNow(index))) + "  " +
                                                 qsTr("Req: ") + Engine.minutesToString(objective.length) + " ]";
        progress = objective == null ? 0.0 : Math.min(1.0, object.getStatus(index) / objective.length);
        progressNow = objective == null ? 0.0 : Math.min(1.0, object.getStatusNow(index) / objective.length);
    }
    
    Item {
        height: 30
        
        Layout.minimumWidth: 50
        Layout.maximumWidth: 65536
        Layout.fillWidth: true
        
        SimpleButton {
            
            id: button
            
            clip: true
            
            height: 25
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
                border.color: "grey"
                border.width: 1 
                color: {
                    if (object == null) return "#000000"
                    else if (progress < 1.0) return "#eebb55"
                    else if (progressNow == 1.0) return "#44cc44"
                    else if (progressNow > 0.0) return "#5588ff"
                    else return "#cccccc"
                }
                
                
            }
            
            RowLayout {
                
                anchors.verticalCenter: button.verticalCenter
                anchors.left: button.left
                anchors.leftMargin: 10 
                
                spacing: 5
                
                
                Label {
                    
                    font.bold: true
                    color: button.label.color
                    
                    text: objective == null ? "" : objective.action.name
                }
                
                Label {
                    id: progressTxt
                    
                    color: button.label.color
                    
                    text: "";
                }
            }
            
            buttonColor: objective == null ? "#000000" : objective.action.parentFolder.color;
            
            text: ""
            
            onClicked: {
                if (clickEnabled){
                    mainWindow.showModuleDirect(root.missionsModule);                        
                    root.missionsModule.selector.select(objective.action);
                    
                    root.occurrenceWindow.close();
                }
            }
        }
        
        DoubleProgressBar {
            anchors.left: button.left
            anchors.right: button.right
            anchors.top: button.bottom
            height: 5
            progress1: progress
            progress2: progressNow
        }
    }
    
    SimpleButton {
        width: 50
        height: 30
        text: qsTr("Adjust")
        visible: adjustBtnVisible
        enabled: progressNow > 0;
        onClicked: {
            window.close();
            root.adjustWindow.show(object, index);
        }
    }

}
