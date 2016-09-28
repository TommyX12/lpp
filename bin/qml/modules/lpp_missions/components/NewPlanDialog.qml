import QtQuick 2.0
import QtQuick.Dialogs 1.2
import QtQuick.Controls 1.4
import QtQuick.Layouts 1.1

Dialog {
    id: dialog_newPlan
    title: qsTr("New Mission")
    modality: Qt.WindowModal
    standardButtons: StandardButton.Ok | StandardButton.Cancel; 
    width: 200
    onAccepted: {
        txt.text = txt.text.trim();
        
        var i, item;
        for (i = 0; i < currentFolder.plans.size; i++){
            item = currentFolder.plans.at(i);
            if (item.name == txt.text){
                mainWindow.messageBox_error.title = qsTr("Name Conflict")
                mainWindow.messageBox_error.text = qsTr("There is already one mission with this name.")
                mainWindow.messageBox_error.open();
                return;
            }
        }
        
        var newPlan = Engine.createPlan(currentFolder, -1)
        //console.log(newPlan.parentFolder.name);
        if (newPlan == null) {
            mainWindow.messageBox_error.text = qsTr("Maximum number of missions reached.");
            mainWindow.messageBox_error.open();
            return;
        }
        /*
        var prefix = qsTr("New Plan ");
        var i, planName, number, knownNumbers = [0];
        for (i = 0; i < currentFolder.plans.size; i++){
            planName = currentFolder.plans.at(i).name;
            planName = planName.split("(", 2);
            if (planName[0] == prefix){
                number = parseInt(planName[1], 10);
                if (!isNaN(number)) knownNumbers.push(number);
            }
        }
        knownNumbers.sort(function (a, b) {return a - b;});
        //console.log(knownNumbers);
        number = knownNumbers[knownNumbers.length - 1] + 1;
        for (i = 0; i < knownNumbers.length-1; i++){
            if (knownNumbers[i] >= 0 && knownNumbers[i+1] - knownNumbers[i] > 1){
                number = knownNumbers[i] + 1;
                break;
            }
        }
        //console.log(number)
        newPlan.name = prefix + "(" + number + ")";
        */
        newPlan.name = txt.text;
        
        selectedItem = newPlan
        
        /*
        if (!content.editor.visible) {
            content.editor.load(newPlan, "plan");
            content.show(content.editor);
        }
        */
        
        selector.refreshDisplay();
        
        Engine.savePlan(newPlan);
    }
    RowLayout{
        height: 50
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.leftMargin: 10
        anchors.rightMargin: 10
        anchors.verticalCenter: parent.verticalCenter
        Label {
            id: label
            text: qsTr("Enter Mission Name: ")
        }
        TextField {
            id: txt
            Layout.minimumWidth: 100
            Layout.fillWidth: true
        }
    }
    
    function show() {
        txt.text = qsTr("New Mission")
        txt.selectAll();
        visible = true;
        txt.focus = true;
    }
}
