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
    minimumWidth: 400
    minimumHeight: 550
    title: qsTr("Edit Instance")
    flags: Qt.Dialog;
    modality: Qt.WindowModal
    maximumHeight: minimumHeight
    maximumWidth: minimumWidth
    
    readonly property real dayLength: 86400000;
    readonly property real hourLength: 3600000;
    readonly property real minuteLength: 60000;
    
    property var timeFrameLimit: dayLength * 3650; 
    
    property Plan plan;
    property Instance instance;
    
    function show(_plan, _instance){
        window.visible = true;
        plan = _plan;
        instance = _instance;
        
        intvSelector.begin = Engine.timeToString(instance.startTime);
        intvSelector.end = Engine.timeToString(instance.endTime);
        
        repeatSelector.loadFromInstance(instance)
        
        maskSelector.loadFromInstance(instance)
    }
    
    function save(){
        var editBeginTime = intvSelector.getBeginTime();
        var editEndTime = intvSelector.getEndTime();
        
        if (Math.abs(editBeginTime - editEndTime) > timeFrameLimit) {
            mainWindow.showError(qsTr("Error"), qsTr("Time frame size limit exceeded."));
            return;
        }
        
        var editBeginDate = new Date(Math.min(editBeginTime, editEndTime));
        var editEndDate = new Date(Math.max(editBeginTime, editEndTime));
        if (isNaN(editBeginDate.getTime()) || isNaN(editEndDate.getTime()) || editBeginTime == editEndTime){
            mainWindow.showError(qsTr("Error"), qsTr("Invalid time frame."));
            return;
        }
        
        if (!repeatSelector.saveToInstance()) return;
        if (!maskSelector.saveToInstance()) return;
        
        instance.startTime = editBeginDate;
        instance.endTime = editEndDate;
        
        Engine.savePlan(plan);
        
        window.close();
    }
    
    ColumnLayout {
        anchors.fill: parent;
        anchors.topMargin: 10
        anchors.leftMargin: 10
        anchors.rightMargin: 10
        anchors.bottomMargin: 10
        
        GroupBox {
            title: qsTr("Time Frame")
            Layout.fillWidth: true
            Layout.minimumWidth: 50
            Layout.maximumWidth: 65536
            width: 50
            IntervalSelector{
                id: intvSelector
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.verticalCenter: parent.verticalCenter
            }
        }
        
        GroupBox {
            title: qsTr("Repeat Mode")
            Layout.fillWidth: true
            Layout.minimumHeight: 50
            Layout.maximumHeight: 65536
            Layout.minimumWidth: 50
            Layout.maximumWidth: 65536
            width: 50
            RepeatSelector {
                id: repeatSelector
                anchors.fill: parent
                anchors.topMargin: 5
                anchors.bottomMargin: 5
                anchors.leftMargin: 5
                anchors.rightMargin: 5
            }
        }
        
        GroupBox {
            title: qsTr("Canceled Occurrences")
            Layout.fillWidth: true
            Layout.fillHeight: true
            Layout.minimumHeight: 50
            Layout.maximumHeight: 65536
            Layout.minimumWidth: 50
            Layout.maximumWidth: 65536
            width: 50
            height: 50
            MaskSelector {
                id: maskSelector
                anchors.fill: parent
                anchors.topMargin: 5
                anchors.bottomMargin: 5
                anchors.leftMargin: 5
                anchors.rightMargin: 5
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
