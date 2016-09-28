import QtQuick 2.6
import QtQuick.Controls 1.4
import QtQuick.Layouts 1.3
import lpp 1.0
import QtQuick.Dialogs 1.2

Item {
    
    property string title: qsTr("Editor:  ") + currentItem.fullPath;
    //property string subTitle;
    
    property Action currentItem: null;
    property bool dirty: false;
    
    anchors.fill: parent
    width: 400
    height: 400
    
    function load(action) {
        currentItem = action;
        
        //subTitle = currentItem.name;
        
        id_txt.text = action.id;
        name.text = action.name;
        note.editor.text = action.note;
        
        dirty = false;
    }
    
    function save() {
        name.text = name.text.trim();
        
        var i, item;
        for (i = 0; i < currentItem.parentFolder.actions.size; i++){
            item = currentItem.parentFolder.actions.at(i);
            if (item != currentItem && item.name == name.text){
                mainWindow.messageBox_error.title = qsTr("Name Conflict")
                mainWindow.messageBox_error.text = qsTr("There is already one action with this name.")
                mainWindow.messageBox_error.open();
                return false;
            }
        }
        
        currentItem.name = name.text;
        currentItem.note = note.editor.text;
        
        dirty = false;
        
        root.selector.refreshDisplay();
        
        Engine.saveAction(currentItem);
        
        //subTitle = currentItem.name;
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
