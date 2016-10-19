import QtQuick 2.6
import QtQuick.Controls 1.4
import QtQuick.Layouts 1.3
import lpp 1.0
import QtQuick.Dialogs 1.2

import modules.lpp_utils 1.0
import ".."
    
    
ColumnLayout {
    property Instance instance;
    spacing: 5
    
    function loadFromInstance(_instance){
        instance = _instance;
        
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
            //console.log("dafuq")
            foreverBox.checked = true;
            untilTxt.text = ""
        }
        else {
            foreverBox.checked = false;
            untilTxt.text = Engine.timeToString(instance.repeatUntil);
        }
        
        permanentBox.checked = !instance.permanent
    }
    
    function saveToInstance(){
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
            return false;
        }
        
        if (repeatUntilTime < instance.startTime){
            repeatUntil = new Date(Engine.timeOrigin.getTime());
        }
        
        instance.repeatMode = repeatMode;
        instance.repeatParam = repeatParam;
        instance.repeatUntil = repeatUntil;
        
        instance.permanent = !permanentBox.checked;
        
        return true;
    }
    
    GridLayout {
        Layout.fillWidth: true
        layoutDirection: Qt.LeftToRight
        columnSpacing: 5
        rows: 3
        flow: GridLayout.LeftToRight
        columns: 3
        rowSpacing: 5
        
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
    
    CheckBox {
        id: permanentBox
        text: qsTr("Delete Instance Automatically when Finished")
    }
}
