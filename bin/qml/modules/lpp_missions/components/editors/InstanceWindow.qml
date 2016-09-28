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
    minimumHeight: 380
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
        
        if (instance.repeatMode == "none") noneRadioBtn.checked = true;
        else noneRadioBtn.checked = false;
        if (instance.repeatMode == "days") {
            daysRadioBtn.checked = true;
            daysTxt.text = instance.repeatParam
        }
        else {
            daysRadioBtn.checked = false;
            daysTxt.text = ""
        }
        if (instance.repeatMode == "months") {
            monthsRadioBtn.checked = true;
            monthsTxt.text = instance.repeatParam
        }
        else {
            monthsRadioBtn.checked = false;
            monthsTxt.text = ""
        }
        if (instance.repeatMode == "years") {
            yearsRadioBtn.checked = true;
            yearsTxt.text = instance.repeatParam
        }
        else {
            yearsRadioBtn.checked = false;
            yearsTxt.text = ""
        }
        
        if (instance.isForever()) {
            foreverBox.checked = true;
            untilTxt.text = ""
        }
        else {
            foreverBox.checked = false;
            untilTxt.text = Engine.timeToString(instance.repeatUntil);
        }
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
        
        var repeatMode, repeatParam = 1, repeatUntilTime;
        if (noneRadioBtn.checked) {
            repeatMode = "none"
        }
        else if (daysRadioBtn.checked){
            repeatMode = "days"
            repeatParam = parseInt(daysTxt.text);
        }
        else if (monthsRadioBtn.checked){
            repeatMode = "months"
            repeatParam = parseInt(monthsTxt.text);
        }
        else if (yearsRadioBtn.checked){
            repeatMode = "years"
            repeatParam = parseInt(yearsTxt.text);
        }
        
        if (foreverBox.checked) repeatUntilTime = Engine.timeOrigin.getTime();
        else repeatUntilTime = Utils.parseDate(untilTxt.text);
        var repeatUntil = new Date(repeatUntilTime);
        
        if (isNaN(repeatParam) || repeatParam <= 0 || isNaN(repeatUntilTime)) {
            mainWindow.showError(qsTr("Error"), qsTr("Invalid parameter."));
            return;
        }
        
        instance.startTime = editBeginDate;
        instance.endTime = editEndDate;
        instance.repeatMode = repeatMode;
        instance.repeatParam = repeatParam;
        instance.repeatUntil = repeatUntil;
        
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
            Layout.fillHeight: true
            Layout.minimumWidth: 100
            Layout.maximumWidth: 65536
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
            ColumnLayout {
                anchors.fill: parent
                anchors.topMargin: 5
                anchors.bottomMargin: 5
                anchors.leftMargin: 5
                anchors.rightMargin: 5
                GridLayout {
                    Layout.fillWidth: true
                    layoutDirection: Qt.LeftToRight
                    columnSpacing: 10
                    rows: 3
                    flow: GridLayout.LeftToRight
                    columns: 3
                    rowSpacing: 10
                    
                    ExclusiveGroup {
                        id: excGroup
                    }
                    
                    RadioButton {
                        id: noneRadioBtn
                        exclusiveGroup: excGroup
                        text: qsTr("None")
                    }
                    Label{}
                    Label{}
                    
                    RadioButton{
                        id: daysRadioBtn
                        exclusiveGroup: excGroup
                        text: qsTr("Every")
                        onClicked: {
                            daysTxt.focus = true;
                            daysTxt.selectAll();
                        }
                    }
                    
                    TextField {
                        id: daysTxt
                        enabled: daysRadioBtn.checked
                        Layout.fillWidth: true
                        horizontalAlignment: Text.AlignHCenter
                        validator: IntValidator{
                            bottom: 1
                            top: 40000
                        }
                    }
                    
                    Label {
                        enabled: daysRadioBtn.checked
                        text: qsTr("Days")
                    }
                    
                    
                    RadioButton{
                        id: monthsRadioBtn
                        exclusiveGroup: excGroup
                        text: qsTr("Every")
                        onClicked: {
                            monthsTxt.focus = true;
                            monthsTxt.selectAll();
                        }
                    }
                    
                    TextField {
                        id: monthsTxt
                        enabled: monthsRadioBtn.checked
                        Layout.fillWidth: true
                        horizontalAlignment: Text.AlignHCenter
                        validator: IntValidator{
                            bottom: 1
                            top: 1200
                        }
                    }
                    
                    Label {
                        enabled: monthsRadioBtn.checked
                        text: qsTr("Months")
                    }
                    
                    
                    RadioButton{
                        id: yearsRadioBtn
                        exclusiveGroup: excGroup
                        text: qsTr("Every")
                        onClicked: {
                            yearsTxt.focus = true;
                            yearsTxt.selectAll();
                        }
                    }
                    
                    TextField {
                        id: yearsTxt
                        enabled: yearsRadioBtn.checked
                        Layout.fillWidth: true
                        horizontalAlignment: Text.AlignHCenter
                        validator: IntValidator{
                            bottom: 1
                            top: 100
                        }
                    }
                    
                    Label {
                        enabled: yearsRadioBtn.checked
                        text: qsTr("Years")
                    }
                }
                
                RowLayout{
                    enabled: !noneRadioBtn.checked
                    anchors.left: parent.left
                    anchors.right: parent.right
                    Label {
                        text: qsTr("Repeat Until: ")
                    }
                
                    CheckBox {
                        id: foreverBox
                        text: qsTr("Forever")
                    }
                    
                    TextField {
                        id: untilTxt
                        enabled: !foreverBox.checked
                        Layout.fillWidth: true
                        Layout.minimumWidth: 50
                        Layout.maximumWidth: 65536
                        horizontalAlignment: Text.AlignHCenter
                        inputMask: "0000-00-00 00:00";
                    }
                    
                    Button {
                        enabled: !foreverBox.checked
                        text: qsTr("Now")
                        onClicked: {
                            untilTxt.text = Engine.timeToString(Engine.currentTime());
                        }
                    }
                }
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
