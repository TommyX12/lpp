import QtQuick 2.6
import QtQuick.Controls 1.4
import QtQuick.Layouts 1.3
import lpp 1.0
import QtQuick.Dialogs 1.2

import modules.lpp_utils 1.0
import ".."

ApplicationWindow {
    visible: false
    id: window
    minimumWidth: 300
    minimumHeight: 200
    title: qsTr("Edit Objective")
    flags: Qt.Dialog;
    modality: Qt.WindowModal
    maximumHeight: minimumHeight
    maximumWidth: minimumWidth
    
    signal jumpToAction(Action action)
    
    property Plan plan;
    property Objective objective;
    
    property Action action;
    
    Finder {
        id: finder
        
    }
    
    function show(plan, objective){
        window.visible = true;
        window.plan = plan;
        window.objective = objective;
        lengthSelector.setMinutes(objective.length);
        window.action = objective.action;
    }
    
    function save(){
        var length = lengthSelector.getMinutes();
        if (length < 0) {
            mainWindow.showError(qsTr("Error"), qsTr("Invalid time amount."));
            return;
        }
        objective.length = length;
        objective.action = window.action;
        Engine.savePlan(plan);
        
        window.close();
    }
    
    function findAction(){
        finder.show(false, true, false, selectAction, qsTr("Select Action"));
    }
    
    function selectAction(item){
        if (item != null) window.action = item;
    }
    
    ColumnLayout {
        anchors.fill: parent;
        anchors.topMargin: 10
        anchors.leftMargin: 10
        anchors.rightMargin: 10
        anchors.bottomMargin: 10
    
        GroupBox {
            Layout.fillWidth: true
            Layout.fillHeight: true
            Layout.minimumHeight: 30
            Layout.maximumHeight: 65536
            title: qsTr("Action");
            RowLayout {
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.verticalCenter: parent.verticalCenter
                Button {
                    text: qsTr("Select")
                    
                    onClicked: {
                        window.findAction();
                    }
                }

                SimpleButton {
                    Layout.fillWidth: true
                    height: 25
                    text: window.action.name;
                    buttonColor: window.action.parentFolder.color;
                    
                    onClicked: {
                        window.close();
                        window.jumpToAction(window.action);
                    }
                }
            }
        }
        
        GroupBox {
            title: qsTr("Amount")
            Layout.fillWidth: true
            Layout.minimumWidth: 100
            Layout.maximumWidth: 65536
            DurationSelector {
                id: lengthSelector
                anchors.fill: parent
            }
        }
        
        Button {
            text: qsTr("Save")
            Layout.fillWidth: true
            Layout.minimumWidth: 10
            Layout.maximumWidth: 65536
            onClicked: {
                window.save();
            }
        }
        
        Button {
            text: qsTr("Discard")
            Layout.fillWidth: true
            Layout.minimumWidth: 10
            Layout.maximumWidth: 65536
            onClicked: {
                window.close();
            }
        }
    }
}
