import QtQuick 2.0
import QtQuick.Dialogs 1.2
import QtQuick.Controls 1.4
import QtQuick.Layouts 1.1

Dialog {
    id: dialog_newFolder
    title: qsTr("New Folder")
    modality: Qt.WindowModal
    standardButtons: StandardButton.Ok | StandardButton.Cancel; 
    width: 200
    onAccepted: {
        txt.text = txt.text.trim();
        
        var i, item;
        for (i = 0; i < currentFolder.folders.size; i++){
            item = currentFolder.folders.at(i);
            if (item.name == txt.text){
                mainWindow.messageBox_error.title = qsTr("Name Conflict")
                mainWindow.messageBox_error.text = qsTr("There is already one folder with this name.")
                mainWindow.messageBox_error.open();
                return;
            }
        }
        
        var newFolder = Engine.createFolder(currentFolder, -1)
        //console.log(newFolder.parentFolder.name);
        ///*
        if (newFolder == null) {
            mainWindow.messageBox_error.text = qsTr("Maximum number of folders reached.");
            mainWindow.messageBox_error.open();
            return;
        }
        /*
        var prefix = qsTr("New Folder ");
        var i, folderName, number, knownNumbers = [0];
        for (i = 0; i < currentFolder.folders.size; i++){
            folderName = currentFolder.folders.at(i).name;
            folderName = folderName.split("(", 2);
            if (folderName[0] == prefix){
                number = parseInt(folderName[1], 10);
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
        newFolder.name = prefix + "(" + number + ")";
        */
        newFolder.name = txt.text;
        
        newFolder.useParentFolderColor = currentFolder != Engine.rootFolder; 
        if (currentFolder == Engine.rootFolder){
            newFolder.color = Qt.rgba(Math.random(), Math.random(), Math.random(), 1.0);
        }
        
        selectedItem = newFolder
        
        /*
        if (!content.editor.visible) {
            content.editor.load(newFolder, "folder");
            content.show(content.editor);
        }
        */
        
        selector.refreshDisplay();
        
        Engine.saveFolder(newFolder);
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
            text: qsTr("Enter Folder Name: ")
        }
        TextField {
            id: txt
            Layout.minimumWidth: 100
            Layout.fillWidth: true
        }
    }
    
    function show() {
        txt.text = qsTr("New Folder")
        txt.selectAll();
        visible = true;
        txt.focus = true;
    }
}
