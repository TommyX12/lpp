import QtQuick 2.0
import QtQuick.Controls 1.4
import QtQuick.Layouts 1.1
import QtQuick.Dialogs 1.2

import lpp 1.0

import modules.lpp_utils 1.0

import "editors"

ColumnLayout {
    id: editor
    
    property string title: qsTr("Editor");
    
    property alias folderEditor: folderEditor;
    property alias actionEditor: actionEditor;
    property alias planEditor: planEditor;
    
    property alias currentItem: pageView.currentItem;
    
    onVisibleChanged: {
        if (visible) Engine.noAutoDelete = true;
        else Engine.noAutoDelete = false;
    }
    
    Component.onCompleted: {
        mainWindow.moduleChange.connect(onModuleChange);
    }
    
    function onModuleChange(event){
        if (visible && !currentItem.backAttempt()) event.accepted = false;
    }
    
    function load(item){
        if (item.type == "action"){
            pageView.show(actionEditor);
            actionEditor.load(item);
        }
        else if (item.type == "folder"){
            pageView.show(folderEditor);
            folderEditor.load(item);
        }
        else if (item.type == "plan"){
            pageView.show(planEditor);
            planEditor.load(item);
        }
    }
    
    function select(item){
        if (visible){
            if (currentItem.currentItem != item){
                if (currentItem.dirty){
                    messageBox_saveChanges.open();
                    messageBox_saveChanges.nextItem = item;
                }
                else {
                    load(item);
                }
            }
        }
        else {
            root.content.show(root.content.editor);
            load(item);
        }
    }
    
    MessageDialog {
        property var nextItem: null;
        
        id: messageBox_saveChanges
        title: qsTr("Save Changes")
        text: qsTr("Would you like to save the changes?")
        icon: StandardIcon.Question
        standardButtons: StandardButton.Save | StandardButton.Discard | StandardButton.Cancel;
        
        onAccepted: {
            currentItem.save();
        }
        onDiscard: {
            load(nextItem);
        }
    }
    
    RowLayout {
        Layout.minimumWidth: 100
        Layout.maximumWidth: 65536
        Layout.fillWidth: true
        
        spacing: 10
        
        Button {
            text: qsTr("Back")
            
            onClicked: {
                currentItem.backAttempt();
            }
        }
        
        Label {
            Layout.minimumWidth: 100
            Layout.maximumWidth: 65536
            Layout.fillWidth: true
            width: 10
            elide: Text.ElideMiddle
            text: currentItem.title;
            //horizontalAlignment: Text.AlignHCenter
            font.bold: true;
        }
    }
    
    PageView {
        id: pageView
        /*
        TODO:
            make sure to catch all changes into dirty flag.    
            display full path of item in an editor entry
          */
        
        Layout.minimumWidth: 200
        Layout.minimumHeight: 200
        Layout.maximumWidth: 65536
        Layout.maximumHeight: 65536
        Layout.fillHeight: true
        Layout.fillWidth: true
        
        
        ActionEditor {
            id: actionEditor;
        }
        
        FolderEditor {
            id: folderEditor;
        }
        
        PlanEditor {
            id: planEditor;
        }
    }
}
