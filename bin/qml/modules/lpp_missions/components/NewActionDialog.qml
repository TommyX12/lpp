import QtQuick 2.0
import QtQuick.Dialogs 1.2
import QtQuick.Controls 1.4
import QtQuick.Layouts 1.1

Dialog {
    id: dialog_newAction
    title: qsTr("New Action")
    modality: Qt.WindowModal
    standardButtons: StandardButton.Ok | StandardButton.Cancel; 
    width: 200
    onAccepted: {
        txt.text = txt.text.trim();
        
        var i, item;
        for (i = 0; i < currentFolder.actions.size; i++){
            item = currentFolder.actions.at(i);
            if (item.name == txt.text){
                mainWindow.messageBox_error.title = qsTr("Name Conflict")
                mainWindow.messageBox_error.text = qsTr("There is already one action with this name.")
                mainWindow.messageBox_error.open();
                return;
            }
        }
        
        var newAction = Engine.createAction(currentFolder, -1)
        //console.log(newAction.parentFolder.name);
        if (newAction == null) {
            mainWindow.messageBox_error.text = qsTr("Maximum number of actions reached.");
            mainWindow.messageBox_error.open();
            return;
        }
        /*
        var prefix = qsTr("New Action ");
        var i, actionName, number, knownNumbers = [0];
        for (i = 0; i < currentFolder.actions.size; i++){
            actionName = currentFolder.actions.at(i).name;
            actionName = actionName.split("(", 2);
            if (actionName[0] == prefix){
                number = parseInt(actionName[1], 10);
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
        newAction.name = prefix + "(" + number + ")";
        */
        newAction.name = txt.text;
        
        selectedItem = newAction
        
        /*
        if (!content.editor.visible) {
            content.editor.load(newAction, "action");
            content.show(content.editor);
        }
        */
        
        selector.refreshDisplay();
        
        Engine.saveAction(newAction);
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
            text: qsTr("Enter Action Name: ")
        }
        TextField {
            id: txt
            Layout.minimumWidth: 100
            Layout.fillWidth: true
        }
    }
    
    function show() {
        txt.text = qsTr("New Action")
        txt.selectAll();
        visible = true;
        txt.focus = true;
    }
}
