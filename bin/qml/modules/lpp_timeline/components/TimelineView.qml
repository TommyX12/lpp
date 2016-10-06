import QtQuick 2.4
import QtQuick.Controls 1.4
import QtQuick.Layouts 1.3
import QtQuick.Dialogs 1.2

import modules.lpp_utils 1.0

ColumnLayout {
    id: timelineView
    anchors.fill: parent
    
    width: 400
    height: 600
    
    property real navButtonWidth: 50
    
    property alias timeline: timeline
    
    CalendarWindow {
        id: calendar
        visible: false
    }
    
    Component.onCompleted: {
        mainWindow.moduleChange.connect(onModuleChange);
        
        Engine.actionDeleted.connect(onActionDeleted);
        
        root.enter.connect(onEnter);
    }
    
    function onEnter(){
        
    }
    
    function onModuleChange(event){
        if (timeline.editing) {
            event.accepted = false;
            //messageBox_saveChanges.open();
        }
    }
    
    function findAction(){
        timeline.finder.show(false, true, false, selectAction, qsTr("Select Active Action"));
    }
    
    function selectAction(item){
        if (item != null) {
            timeline.activeDrawEnabled = true;
            timeline.activeAction = item;
        }
    }
    
    function onActionDeleted(action){
        if (action == timeline.activeAction) timeline.activeAction = null;
    }
    
    /*
    MessageDialog {
        
        id: messageBox_saveChanges
        title: qsTr("Save Changes")
        text: qsTr("Would you like to save changes to the timeline?")
        icon: StandardIcon.Question
        standardButtons: StandardButton.Save | StandardButton.Discard | StandardButton.Cancel;
        
        onAccepted: {
            timeline.saveEdit();
        }
        onDiscard: {
            timeline.discardEdit();
        }
    }
    */
    
    GroupBox {
        //checkable: true
        //checked: timeline.activeDrawEnabled
        Layout.fillWidth: true
        Layout.minimumHeight: 10
        Layout.maximumHeight: 65536
        Layout.minimumWidth: 10
        Layout.maximumWidth: 65536
        title: qsTr("Active Draw");
        
        
        RowLayout {
            anchors.fill: parent
            SimpleButton {
                Layout.alignment: Qt.AlignCenter
                Layout.fillWidth: false
                Layout.minimumWidth: 50
                Layout.maximumWidth: 65536
                height: 25
                text: qsTr("Disable")
                enabled: timeline.activeDrawEnabled;
                onClicked: {
                    timeline.activeDrawEnabled = false;
                    timeline.activeAction = null;
                }
            }
            SimpleButton {
                Layout.fillWidth: false
                Layout.minimumWidth: 55
                Layout.maximumWidth: 65536
                height: 25
                text: qsTr("Erase")
                enabled: timeline.activeAction != null || !timeline.activeDrawEnabled;
                onClicked: {
                    timeline.activeDrawEnabled = true;
                    timeline.activeAction = null;
                }
            }
            SimpleButton {
                Layout.fillWidth: false
                Layout.minimumWidth: 55
                Layout.maximumWidth: 65536
                height: 25
                text: qsTr("Draw")
                onClicked: findAction();
            }
            Rectangle {
                Layout.fillWidth: true
                height: 25
                Layout.minimumWidth: 150
                Layout.maximumWidth: 65536
                border.color: "grey";
                border.width: 1;
                color: "transparent";
                
                SimpleButton {
                    anchors.fill: parent
                    enabled: visible
                    visible: timeline.activeAction != null && timeline.activeDrawEnabled;
                    text: timeline.activeAction.name;
                    buttonColor: timeline.activeAction.parentFolder.color;
                    clip: true;
                    
                    onClicked: {
                        mainWindow.showModuleDirect(root.missionsModule);                        
                        root.missionsModule.selector.select(timeline.activeAction);
                    }
                }
                
                Label {
                    anchors.centerIn: parent
                    text: timeline.activeDrawEnabled ? qsTr("(Erasing)") : qsTr("(Disabled)");
                    visible: timeline.activeAction == null;
                }
            }
        }
    }
    
    RowLayout {
        SimpleButton {
            Layout.minimumWidth: 50
            Layout.maximumWidth: 65536
            Layout.fillWidth: true
            text: qsTr("Manual Draw")
            enabled: !timeline.editing
            onClicked: {
                timeline.startEdit(null, true);
            }
        }
        
        SimpleButton {
            Layout.minimumWidth: 50
            Layout.maximumWidth: 65536
            Layout.fillWidth: true
            text: qsTr("Auto Draw")
            enabled: !timeline.editing
            onClicked: {
                timeline.autoPlan();
            }
        }
        
        SimpleButton {
            Layout.minimumWidth: 50
            Layout.maximumWidth: 65536
            Layout.fillWidth: true
            text: qsTr("New Attached Mission")
            enabled: !timeline.editing
            onClicked: {
                timeline.startNewPlan();
            }
        }
        
    }
    
    RowLayout {
        SimpleButton {
            text: qsTr("Select Date")
            enabled: true
            Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
            Layout.fillWidth: false
            width: 70
            
            onClicked: {
                var date = new Date(timeline.cameraTime);
                calendar.show(new Date(date.getUTCFullYear(), date.getUTCMonth(), date.getUTCDate()), function (date) {
                    timeline.setCamera(date.getTime(), timeline.cameraZoom);
                }, cameraTimeTxt.text);
            }
        }
        
        Rectangle{
            Layout.fillWidth: true
            height: 24
            
            border.width: 1
            border.color: "black"
            
            Label{
                id: cameraTimeTxt
                anchors.centerIn: parent
                text: Engine.timeToStringRead(new Date(timeline.cameraTime));
                font.bold: true
            }
        }
    }
    
    Item {
        id: tabView
        
        Layout.fillWidth: true
        Layout.fillHeight: true
        
        Timeline {
            id: timeline
            anchors.fill: parent
        }
        
        Rectangle {
            anchors.fill: parent
            
            color: "transparent"
            border.color: "black"
            border.width: 1
        }
    }
    
    RowLayout {
        SimpleButton {
            text: qsTr("<-")
            enabled: true
            Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
            Layout.fillWidth: false
            Layout.maximumWidth: navButtonWidth
            Layout.minimumWidth: Layout.maximumWidth
            
            onClicked: {
                timeline.moveCamera(-timeline.dayLength, 0);
            }
        }
        SimpleButton {
            text: qsTr("-")
            enabled: true
            Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
            Layout.fillWidth: false
            Layout.maximumWidth: navButtonWidth
            Layout.minimumWidth: Layout.maximumWidth
            
            onClicked: {
                timeline.moveCamera(0, -2.0);
            }
        }
        SimpleButton {
            text: qsTr("Current Time")
            enabled: true
            Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
            Layout.fillWidth: true
            Layout.maximumWidth: 65536
            Layout.minimumWidth: 20
            
            onClicked: {
                timeline.resetCamera(true, false);
            }
        }
        SimpleButton {
            text: qsTr("Reset Zoom")
            enabled: true
            Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
            Layout.fillWidth: true
            Layout.maximumWidth: 65536
            Layout.minimumWidth: 20
            
            onClicked: {
                timeline.resetCamera(false, true);
            }
        }
        SimpleButton {
            text: qsTr("+")
            enabled: true
            Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
            Layout.fillWidth: false
            Layout.maximumWidth: navButtonWidth
            Layout.minimumWidth: Layout.maximumWidth
            
            onClicked: {
                timeline.moveCamera(0, 2.0);
            }
        }
        SimpleButton {
            text: qsTr("->")
            enabled: true
            Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
            Layout.fillWidth: false
            Layout.maximumWidth: navButtonWidth
            Layout.minimumWidth: Layout.maximumWidth
            
            onClicked: {
                timeline.moveCamera(timeline.dayLength, 0);
            }
        }
    }
}
