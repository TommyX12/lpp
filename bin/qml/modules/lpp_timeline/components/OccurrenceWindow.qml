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
    minimumWidth: 550
    minimumHeight: 450
    title: qsTr("Mission Occurrence")
    flags: Qt.Dialog;
    modality: Qt.WindowModal
    maximumWidth: 65536
    maximumHeight: 65536
    width: 550
    height: 450
    
    Rectangle {
        color: "white"
        anchors.fill: parent
    }
    
    property Occurrence occurrence;
    
    readonly property int maxNoteChar: 64;
    
    Component.onCompleted: {
        root.timeline.timeChanged.connect(onTimeChanged);
    }
    
    function onTimeChanged(){
        occItemContainer.refresh();
        
        statusTxt.text = getStatusTxt();
        statusTxt.color = getStatusColor();
    }
    
    function show(_occurrence){
        window.visible = true;
        occurrence = _occurrence
        
        occItemContainer.clear()
        
        var i, length = occurrence.plan.objectives.size;
        
        for (i = 0; i < length; i++){
            occItemContainer.add(occurrence);
        }
        
        occItemContainer.refresh();
        
        statusTxt.text = getStatusTxt();
        statusTxt.color = getStatusColor();
    }
    
    function getStatusTxt(){
        if (occurrence == null) return ""
        else if (occurrence.impossible) return occurrence.endTime <= Engine.currentTime() ? qsTr("Failed") : qsTr("Impossible without Causing Conflicts")
        else if (occurrence.progress < 1.0) return qsTr("Insufficient Planning")
        else if (occurrence.progressNow == 1.0) return qsTr("Completed")
        else if (occurrence.progressNow > 0.0) return qsTr("In Progress")
        else return qsTr("Fully Planned")
    }
    
    function getStatusColor(){
        if (occurrence == null) return "#000000"
        else if (occurrence.impossible) return "#ff0000"
        else if (occurrence.progress < 1.0) return "#ee9922"
        else if (occurrence.progressNow == 1.0) return "#44bb44"
        else if (occurrence.progressNow > 0.0) return "#5588ff"
        else return "#666666"
    }
    
    Component {
        id: objItem_comp
        ObjectiveItem{
            
        }
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
        
        GroupBox {
            title: qsTr("Mission Info")
            Layout.fillWidth: true
            Layout.minimumHeight: 50
            Layout.maximumHeight: 65536
            Layout.minimumWidth: 100
            Layout.maximumWidth: 65536
            GridLayout {
                anchors.fill: parent
                anchors.topMargin: 5
                layoutDirection: Qt.LeftToRight
                columnSpacing: 5
                rows: 6
                flow: GridLayout.LeftToRight
                columns: 2
                rowSpacing: 8
                
                Label {
                    font.bold: true
                    text: qsTr("Name: ")
                }
                
                Label {
                    Layout.fillWidth: true
                    text: occurrence == null ? "" : (occurrence.plan.name.length == 0 ? qsTr("(unnamed)") : occurrence.plan.name)
                }
                
                Label {
                    font.bold: true
                    text: qsTr("Note: ")
                }
                
                Label {
                    Layout.fillWidth: true
                    text: {
                        if (occurrence == null) return "";
                        var note = occurrence.plan.note;
                        if (occurrence.plan.parentFolder == null) note = occurrence.plan.objectives.at(0).action.note;
                        if (note.length == 0) return qsTr("(none)");
                        note = note.split("\n");
                        if (note.length > 1) note = note[0] + "\n...";
                        else note = note[0];
                        if (note.length > maxNoteChar) return note.substring(0, maxNoteChar) + "...";
                        else return note;
                    }
                }
                
                Label {
                    font.bold: true
                    text: qsTr("Time Frame: ")
                }
                
                Label {
                    Layout.fillWidth: true
                    text: occurrence == null ? "" : Engine.timeSpanToString(occurrence.startTime, occurrence.endTime);
                }
                
                Label {
                    font.bold: true
                    text: qsTr("Repeat: ")
                }
                
                Label {
                    Layout.fillWidth: true
                    text: occurrence == null ? "" : Utils.getRepeatTxt(occurrence.instance);
                }
                
                Label {
                    font.bold: true
                    text: qsTr("Progress: ")
                }
                
                DoubleProgressBar {
                    Layout.fillWidth: true
                    progress1: occurrence.progress
                    progress2: occurrence.progressNow
                    
                    height: 20
                    
                    Label {
                        anchors.centerIn: parent
                        text: qsTr("Done: ") + qsTr("%1\%").arg(Math.floor(occurrence.progressNow*100)) + "    " + qsTr("Planned: ") + qsTr("%1\%").arg(Math.floor(occurrence.progress*100))
                    }
                    
                    Rectangle {
                        anchors.fill: parent
                        color: "transparent"
                        border.width: 1
                        border.color: "black"
                    }
                }
                
                Label {
                    font.bold: true
                    text: qsTr("Status: ")
                }
                
                Label {
                    id: statusTxt
                    font.bold: true
                    Layout.fillWidth: true
                    text: ""
                    
                }
            }            
        }
        
        RowLayout {
            id: rowLayout1
            
            
            SimpleButton {
                Layout.minimumWidth: 50
                Layout.maximumWidth: 65536
                Layout.fillWidth: true
                height: 30
                text: qsTr("Find Mission in Library")
                onClicked: {
                    mainWindow.showModuleDirect(root.missionsModule);
                    if (occurrence.plan.parentFolder == null) root.missionsModule.selector.select(occurrence.plan.objectives.at(0).action);
                    else root.missionsModule.selector.select(occurrence.plan);
                    
                    window.close();
                }
            }
            
            SimpleButton {
                Layout.minimumWidth: 50
                Layout.maximumWidth: 65536
                Layout.fillWidth: true
                height: 30
                text: qsTr("Go to Occurrence on Timeline")
                onClicked: {
                    root.timeline.setCamera(occurrence.startTime.getTime(), root.timeline.cameraZoom);
                    
                    window.close();
                }
            }
            
        }
        
        Item {
            Layout.fillWidth: true
            Layout.fillHeight: true
            Layout.minimumHeight: 50
            Layout.maximumHeight: 65536
            Layout.minimumWidth: 100
            Layout.maximumWidth: 65536
            
            GroupBox {
                
                title: qsTr("Objectives")
                anchors.fill: parent
                
                RowLayout {
                    id: compModeTxtGroup
                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.top: parent.top
                    
                    Label {
                        font.bold: true
                        text: qsTr("Completion Mode: ")
                    }
                    
                    Label {
                        Layout.fillWidth: true
                        text: occurrence == null ? "" : (occurrence.plan.completionMode == 0 ? qsTr("All") : qsTr("Any"))
                    }
                }
                
                SimpleList {
                    id: occItemContainer
                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.bottom: parent.bottom
                    anchors.top: compModeTxtGroup.bottom
                    anchors.topMargin: 5
                    objItemHeight: 30
                    objItemComponent: objItem_comp
                    objItemScroll.verticalScrollBarPolicy: Qt.ScrollBarAlwaysOn
                }
            }
        }
    }
}
