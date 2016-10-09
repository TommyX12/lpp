import QtQuick 2.6
import QtQuick.Controls 1.4
import QtQuick.Layouts 1.3
import lpp 1.0
import QtQuick.Dialogs 1.2

import lpp 1.0
import modules.lpp_utils 1.0

Item {
    
    property string title: currentItem.fullPath;
    //property string subTitle;
    
    property Action currentItem: null;
    property bool dirty: false;
    
    anchors.fill: parent
    width: 400
    height: 400
    
    property var backHandler: null;
    
    property alias aplanWindow: aplanWindow
    
    function load(action) {
        currentItem = action;
        
        //subTitle = currentItem.name;
        
        id_txt.text = action.id;
        name.text = action.name;
        note.editor.text = action.note;
        
        dirty = false;
        
        refreshExtra();
    }
    
    onVisibleChanged: {
        if (visible) Engine.noAutoDelete = true;
        else Engine.noAutoDelete = false;
    }
    
    function save() {
        name.text = name.text.trim();
        
        if (name.text.length == 0){
            mainWindow.showError(qsTr("Error"), qsTr("Name cannot be empty."));
            return;
        }
        
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
        if (backHandler != null) {
            backHandler();
            backHandler = null;
        }
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
    
    AttachedPlanWindow{
        id: aplanWindow
        
        onClosing: {
            refreshExtra();
        }
    }
    
    Component {
        id: aplanItem_comp
        AttachedPlanItem{
            
        }
    }
    
    function createAttachedPlan(){
        var aplan = currentItem.createPlan();
        Engine.saveAction(currentItem);
        refreshExtra();
        editAttachedPlan(aplan);
        
        return aplan;
    }
    
    function editAttachedPlan(attachedPlan){
        aplanWindow.show(attachedPlan);
    }
    
    function deleteAttachedPlan(attachedPlan){
        currentItem.deletePlan(attachedPlan);
        Engine.saveAction(currentItem);
        refreshExtra();
    }
    
    function refreshExtra(){
        
        var i;
        
        aplanList.clear();
        
        for (i = 0; i < currentItem.plans.size; i++){
            aplanList.add(currentItem.plans.at(i));
        }
        aplanList.add(null);
        
        aplanList.refresh();
        
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
        
        GroupBox{
            title: qsTr("General")
            
            Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
            Layout.fillWidth: true
            Layout.fillHeight: true
            Layout.minimumHeight: 350
            Layout.maximumHeight: Layout.minimumHeight
            
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
        
        RowLayout {
            Layout.fillWidth: true
            Layout.fillHeight: true
            Layout.minimumHeight: 200
            Layout.maximumHeight: 65536
            GroupBox{
                title: qsTr("Skill Points")
                Layout.fillHeight: true
                Layout.fillWidth: true
                Layout.minimumWidth: 200
                Layout.maximumWidth: 65536
                Layout.minimumHeight: 200
                Layout.maximumHeight: 65536
                
                
            }
            
            GroupBox{
                title: qsTr("Attached Missions")
                Layout.fillHeight: true
                Layout.fillWidth: true
                Layout.minimumWidth: 200
                Layout.maximumWidth: 65536
                Layout.minimumHeight: 200
                Layout.maximumHeight: 65536
                
                PooledList {
                    id: aplanList
                    anchors.fill: parent
                    objItemComponent: aplanItem_comp
                    
                    onItemTriggered: {
                        if (data == 0) createAttachedPlan();
                        else if (data == 1) editAttachedPlan(object);
                        else if (data == 2) deleteAttachedPlan(object);
                    }
                }
            }
        }
    }
}
