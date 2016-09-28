import QtQuick 2.0
import QtQuick.Controls 1.4
import QtQuick.Layouts 1.1
import QtQuick.Dialogs 1.2

import lpp 1.0

import modules.lpp_utils 1.0

import "editors"

PageView {
    id: editor
    
    /*
    TODO:
        make sure to catch all changes into dirty flag.    
        display full path of item in an editor entry
      */
    
    property string title: currentItem.title;
    
        
    property alias folderEditor: folderEditor;
    property alias actionEditor: actionEditor;
    property alias planEditor: planEditor;
    
    anchors.fill: parent
    
    Component.onCompleted: {
        mainWindow.moduleChange.connect(onModuleChange);
    }
    
    function onModuleChange(event){
        if (visible && !currentItem.backAttempt()) event.accepted = false;
    }
    
    function load(item){
        if (item.type == "action"){
            show(actionEditor);
            actionEditor.load(item);
        }
        else if (item.type == "folder"){
            show(folderEditor);
            folderEditor.load(item);
        }
        else if (item.type == "plan"){
            show(planEditor);
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
    
    Item {
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
    }
    
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
