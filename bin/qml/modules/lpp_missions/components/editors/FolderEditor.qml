import QtQuick 2.6
import QtQuick.Controls 1.4
import QtQuick.Layouts 1.3
import lpp 1.0
import QtQuick.Dialogs 1.2

import modules.lpp_utils 1.0

Item {
    
    
    
    property string title: qsTr("Editor:  ") + currentItem.fullPath;
    //property string subTitle;
    
    property Folder currentItem: null;
    property bool dirty: false;
    
    anchors.fill: parent
    width: 400
    height: 400
    
    function load(folder) {
        currentItem = folder;
        
        id_txt.text = folder.id;
        
        //subTitle = currentItem.name;
        name.text = folder.name;
        note.editor.text = folder.note;
        useParentColor.checked = folder.useParentFolderColor;
        colorBtn.buttonColor = folder.color;
        
        dirty = false;
    }
    
    function save() {
        name.text = name.text.trim();
        
        if (name.text.length == 0){
            mainWindow.showError(qsTr("Error"), qsTr("Name cannot be empty."));
            return;
        }
        
        var i, item;
        for (i = 0; i < currentItem.parentFolder.folders.size; i++){
            item = currentItem.parentFolder.folders.at(i);
            if (item != currentItem && item.name == name.text){
                mainWindow.messageBox_error.title = qsTr("Name Conflict")
                mainWindow.messageBox_error.text = qsTr("There is already one folder with this name.")
                mainWindow.messageBox_error.open();
                return false;
            }
        }
        
        currentItem.name = name.text;
        currentItem.note = note.editor.text;
        currentItem.useParentFolderColor = useParentColor.checked;
        currentItem.color = colorBtn.buttonColor;
        
        dirty = false;
        
        root.selector.refreshDisplay();
        
        //subTitle = currentItem.name;
        
        Engine.saveFolder(currentItem);
        
        return true;
    }
    
    function back() {
        content.show(content.overview);
    }
    
    function backAttempt() {
        if (dirty){
            messageBox_saveChanges.open();
            return false;
        }
        else {
            back();
            return true;
        }
    }
    
    ColorPicker {
        id: colorPicker
    }
    
    MessageDialog {
        id: messageBox_saveChanges
        title: qsTr("Save Changes")
        text: qsTr("Would you like to save the changes?")
        icon: StandardIcon.Question
        standardButtons: StandardButton.Save | StandardButton.Discard | StandardButton.Cancel;
        onAccepted: {
            if (save()) back();
        }
        onDiscard: {
            back();
        }
    }
    
    Button {
        text: qsTr("Back")
        
        onClicked: {
            backAttempt();
        }
    }
    
    ColumnLayout {
    
        anchors.fill: parent
        
        RowLayout {
            Layout.alignment: Qt.AlignLeft | Qt.AlignVCenter
            Layout.fillWidth: true
            
            
            Button {
                text: qsTr("Back")
                
                onClicked: {
                    backAttempt();
                }
            }
        }
        
        GroupBox{
            title: qsTr("General")
            
            Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
            Layout.fillWidth: true
            Layout.fillHeight: true
    
            GridLayout {
                layoutDirection: Qt.LeftToRight
                columnSpacing: 10
                rows: 3
                flow: GridLayout.LeftToRight
                columns: 2
                rowSpacing: 10
                
                anchors.fill: parent
                
                Label {
                    text: qsTr("ID:")
                }
                
                RowLayout {
                    Layout.fillWidth: true
                    Layout.minimumWidth: 200
                    Layout.maximumWidth: 65536
                    Label {
                        id: id_txt
                        Layout.fillWidth: true
                    }
                    Button {
                        Layout.alignment: Qt.AlignRight | Qt.AlignVCenter
                        text: qsTr("Save")
                        enabled: dirty
                        onClicked: save();
                    }
                }
                
                Label {
                    text: qsTr("Name:")
                }
                
                TextField {
                    id: name
                    Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
                    Layout.fillWidth: true
                    placeholderText: qsTr("Enter Action Name")
                    
                    onTextChanged: dirty = true;
                }
                
                Label {
                    text: qsTr("Color:")
                }
                
                RowLayout {
                    
                    CheckBox {
                        id:useParentColor
                        Layout.alignment: Qt.AlignLeft | Qt.AlignVCenter
                        text: qsTr("Use Parent Folder Color");
                        onCheckedChanged: dirty = true;
                    }
                    
                    SimpleButton {
                        id: colorBtn
                        Layout.alignment: Qt.AlignLeft | Qt.AlignVCenter
                        
                        text: qsTr("Select")
                        
                        Layout.fillWidth: true
                        height: 28
                        
                        enabled: !useParentColor.checked
                        opacity: useParentColor.checked ? 0 : 1
                        
                        onClicked: {
                            colorPicker.visible = true;
                            colorPicker.load(buttonColor)
                            colorPicker.handlerFunction = function (newColor){
                                buttonColor = newColor;
                                dirty = true;
                            }
                        }
                    }
                }
                
                /*
                Label {
                    id: label3
                    text: qsTr("Potential:")
                    Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
                }
                
                
                RowLayout {
                    id: rowLayout1
                    width: 100
                    height: 100
                    Layout.fillWidth: true
                    
                    Slider {
                        id: slider
                        Layout.fillWidth: true
                    }
                    
                    Label {
                        id: sliderValueText
                        text: slider.value.toFixed(2)
                        Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
                    }
                }
                */
                
                Label {
                    text: qsTr("Note:")
                    Layout.alignment: Qt.AlignLeft | Qt.AlignTop
                }
                
                TextEditor {
                    id: note
                    Layout.fillHeight: true
                    Layout.fillWidth: true
                    
                    editor.onTextChanged: dirty = true;
                }
                
            }
        }
    }
}
