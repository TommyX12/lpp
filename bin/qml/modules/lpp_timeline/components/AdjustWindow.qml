import QtQuick 2.6
import QtQuick.Controls 1.4
import QtQuick.Layouts 1.3
import lpp 1.0
import QtQuick.Dialogs 1.2

import lpp 1.0
import modules.lpp_utils 1.0

ApplicationWindow {
    visible: false
    id: window
    minimumWidth: 400
    minimumHeight: 300
    title: qsTr("Adjust by Progress")
    flags: Qt.Dialog;
    modality: Qt.WindowModal
    maximumWidth: 65536
    maximumHeight: 65536
    width: 400
    height: 300
    
    Rectangle {
        color: "white"
        anchors.fill: parent
    }
    
    property Occurrence occurrence;
    property int objectiveIndex;
    property Objective objective;
    
    property int statusNow: 0
    property real newProgress: objective == null ? 0 : (Math.max(0.001, slider.value));
    property int newRequirement: Math.min(Math.ceil(statusNow / newProgress), 52560000);
    
    Component.onCompleted: {
        root.timeline.timeChanged.connect(onTimeChanged);
    }
    
    function onTimeChanged(){
        if (occurrence != null){
            statusNow = occurrence.getStatusNow(objectiveIndex);
            
            objItem.refresh();
        }
    }
    
    function show(_occurrence, _objectiveIndex){
        window.visible = true;
        occurrence = _occurrence;
        objectiveIndex = _objectiveIndex;
        objective = occurrence.plan.objectives.at(objectiveIndex);
        
        onTimeChanged();
        
        slider.value = Math.min(1.0, statusNow / objective.length);
    }
    
    function save(){
        objective.length = newRequirement;
        
        Engine.savePlan(occurrence.plan);
        
        root.enter();
        
        window.close();
    }
    
    onOccurrenceChanged: {
        if (occurrence == null){
            window.close();
        }
    }
    
    ColumnLayout {
        anchors.fill: parent;
        anchors.topMargin: 10
        anchors.leftMargin: 10
        anchors.rightMargin: 10
        anchors.bottomMargin: 10
        
        ObjectiveItem {
            id: objItem
            
            Layout.fillWidth: true
            Layout.minimumWidth: 50
            Layout.maximumWidth: 65536
            
            adjustBtnVisible: false
            clickEnabled: false
            
            object: occurrence
            index: objectiveIndex
        }
        
        GroupBox {
            Layout.minimumHeight: 40
            Layout.maximumHeight: 65536
            Layout.minimumWidth: 40
            Layout.maximumWidth: 65536
            Layout.fillWidth: true
            Layout.fillHeight: true
            title: qsTr("Help")
            Label {
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
                wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                anchors.fill: parent
                text: qsTr("Some objective requirements are estimates and may change during the task and / or after the task is done.\nThe requirement can be adjusted here by providing the actual progress of the task. The required amount will be changed to match this progress.");
            }
        }
        
        GroupBox {
            Layout.minimumHeight: 40
            Layout.maximumHeight: 65536
            Layout.minimumWidth: 40
            Layout.maximumWidth: 65536
            Layout.fillWidth: true
            height: 40
            title: qsTr("Desired Progress")
            ColumnLayout {
                
                anchors.fill: parent
                
                RowLayout {
                    
                    Layout.fillWidth: true
                    Layout.minimumWidth: 50
                    Layout.maximumWidth: 65536
                    
                    Slider {
                        id: slider
                        Layout.fillWidth: true
                        Layout.minimumWidth: 50
                        Layout.maximumWidth: 65536
                    }
                    
                    Label {
                        Layout.minimumWidth: 50
                        Layout.maximumWidth: 65536
                        
                        text: (newProgress * 100).toFixed(2) + '%'
                    }
                }
            }
        }
        
        GroupBox {
            Layout.minimumHeight: 40
            Layout.maximumHeight: 65536
            Layout.minimumWidth: 40
            Layout.maximumWidth: 65536
            Layout.fillWidth: true
            height: 40
            title: qsTr("Final Requirement")
            Label {
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
                wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                anchors.fill: parent
                text: Engine.minutesToString(newRequirement)
            }
        }
        
        Button {
            text: qsTr("Save")
            Layout.fillWidth: true
            Layout.minimumWidth: 10
            Layout.maximumWidth: 65536
            onClicked: {
                window.save();
                
                root.occurrenceWindow.show(occurrence);
            }
        }
        
        Button {
            text: qsTr("Discard")
            Layout.fillWidth: true
            Layout.minimumWidth: 10
            Layout.maximumWidth: 65536
            onClicked: {
                window.close();
                
                root.occurrenceWindow.show(occurrence);
            }
        }
    }
}
