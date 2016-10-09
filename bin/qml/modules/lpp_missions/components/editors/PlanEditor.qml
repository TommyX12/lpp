import QtQuick 2.6
import QtQuick.Controls 1.4
import QtQuick.Layouts 1.3
import lpp 1.0
import QtQuick.Dialogs 1.2

import ".."

Item {
    
    property string title: currentItem.fullPath;
    //property string subTitle;
    
    property Plan currentItem: null;
    property bool dirty: false;
    
    anchors.fill: parent
    width: 400
    height: 400
    
    property var backHandler: null;
    
    function findAction(){
        root.finder.show(false, true, false, selectAction, qsTr("Select Action for New Objective"));
    }
    
    function selectAction(item){
        if (item != null) {
            var objective = currentItem.createObjective(item);
            Engine.savePlan(currentItem);
            refreshExtra();
            editObjective(objective);
        }
    }
    
    function load(plan) {
        currentItem = plan;
        
        //subTitle = currentItem.name;
        
        id_txt.text = plan.id;
        name.text = plan.name;
        note.editor.text = plan.note;
        
        if (plan.completionMode == 0) allRadioBtn.checked = true;
        else allRadioBtn.checked = false;
        if (plan.completionMode == 1) anyRadioBtn.checked = true;
        else anyRadioBtn.checked = false;
        
        dirty = false;
        
        refreshExtra();
    }
    
    function save() {
        name.text = name.text.trim();
        
        if (name.text.length == 0){
            mainWindow.showError(qsTr("Error"), qsTr("Name cannot be empty."));
            return;
        }
        
        var i, item;
        for (i = 0; i < currentItem.parentFolder.plans.size; i++){
            item = currentItem.parentFolder.plans.at(i);
            if (item != currentItem && item.name == name.text){
                mainWindow.messageBox_error.title = qsTr("Name Conflict")
                mainWindow.messageBox_error.text = qsTr("There is already one mission with this name.")
                mainWindow.messageBox_error.open();
                return false;
            }
        }
        
        currentItem.name = name.text;
        currentItem.note = note.editor.text;
        
        dirty = false;
        
        root.selector.refreshDisplay();
        
        Engine.savePlan(currentItem);
        
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
    
    ObjectiveWindow{
        id: objWindow
        
        onClosing: {
            refreshExtra();
        }
        
        onJumpToAction: function (action){
            backHandler = function(){
                root.selector.select(action)
            }
            backAttempt();
        }
    }
    
    Component {
        id: objItem_comp
        
        ObjectiveItem{
            
            
                
        }
    }
    
    function editObjective(objective){
        objWindow.show(currentItem, objective);
    }
    
    function moveObjective(objective, indexChange){
        currentItem.moveObjective(objective, indexChange);
        Engine.savePlan(currentItem);
        refreshExtra();
    }
    
    function deleteObjective(objective){
        currentItem.deleteObjective(objective);
        Engine.savePlan(currentItem);
        refreshExtra();
    }
    
    property var objItemPool: []
    
    InstanceWindow{
        id: insWindow
        
        onClosing: {
            refreshExtra();
        }
    }
    
    Component {
        id: insItem_comp
        InstanceItem{
            
        }
    }
    
    function editInstance(instance){
        insWindow.show(currentItem, instance);
    }
    
    function deleteInstance(instance){
        currentItem.deleteInstance(instance);
        Engine.savePlan(currentItem);
        refreshExtra();
    }
    
    property var insItemPool: []
    
    function refreshExtra(){
        
        var i, objItem, insItem;
        
        for (i = 0; i < objItemPool.length; i++){
            objItemPool[i].visible = false;
        }
        
        for (i = 0; i < currentItem.objectives.size; i++){
            if (i >= objItemPool.length){
                objItem = objItem_comp.createObject(objContainer);
                objItem.Layout.fillWidth = true;
                objItem.editFunc = editObjective;
                objItem.deleteFunc = deleteObjective;
                objItem.moveFunc = moveObjective;
                objItemPool.push(objItem);
            }
            
            objItem = objItemPool[i];
            
            objItem.visible = true;
            
            objItem.objective = currentItem.objectives.at(i);
        }
        
        for (i = 0; i < insItemPool.length; i++){
            insItemPool[i].visible = false;
        }
        
        for (i = 0; i < currentItem.instances.size; i++){
            if (i >= insItemPool.length){
                insItem = insItem_comp.createObject(insContainer);
                insItem.Layout.fillWidth = true;
                insItem.editFunc = editInstance;
                insItem.deleteFunc = deleteInstance;
                insItemPool.push(insItem);
            }
            
            insItem = insItemPool[i];
            
            insItem.visible = true;
            
            insItem.instance = currentItem.instances.at(i);
            insItem.refresh();
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
        
        GroupBox{
            title: qsTr("General")
            
            Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
            Layout.fillWidth: true
            Layout.minimumHeight: 250
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
                    placeholderText: qsTr("Enter Mission Name")
                    
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
                title: qsTr("Objectives")
                Layout.fillHeight: true
                Layout.fillWidth: true
                Layout.minimumWidth: 175
                Layout.maximumWidth: 65536
                Layout.minimumHeight: 200
                Layout.maximumHeight: 65536
                
                RowLayout {
                    id: objSettings
                    
                    anchors.top: parent.top
                    anchors.topMargin: 5
                    anchors.left: parent.left
                    anchors.leftMargin: 10
                    anchors.right: parent.right
                    anchors.rightMargin: 10
                    
                    ExclusiveGroup {
                        id: exGroup
                    }
                    
                    Label {
                        text: qsTr("Completion Mode: ")
                    }
                    
                    RadioButton {
                        id: allRadioBtn
                        text: qsTr("All");
                        exclusiveGroup: exGroup
                        
                        onClicked: {
                            currentItem.completionMode = 0;
                            Engine.savePlan(currentItem);
                        }
                    }
                    
                    RadioButton {
                        id: anyRadioBtn
                        text: qsTr("Any");
                        exclusiveGroup: exGroup
                        
                        onClicked: {
                            currentItem.completionMode = 1;
                            Engine.savePlan(currentItem);
                        }
                    }
                }
                
                ScrollView{
                    id: objScroll
                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.bottom: parent.bottom
                    anchors.top: objSettings.bottom
                    anchors.topMargin: 10
                    clip: true
                    
                    Item {
                        
                        width: objScroll.flickableItem.width
                        height: objContainer.height + 15 + addObjBtn.height
                        
                        ColumnLayout{
                            
                            y: 5
                            
                            id: objContainer
                            anchors.left: parent.left
                            anchors.leftMargin: 5
                            anchors.right: parent.right
                            anchors.rightMargin: 5
                        }
                        
                        ObjectiveItem{
                            id: addObjBtn
                            objective: null
                            anchors.top: objContainer.bottom
                            anchors.topMargin: 5
                            anchors.left: parent.left
                            anchors.leftMargin: 5
                            anchors.right: parent.right
                            anchors.rightMargin: 5
                            
                            button.onClicked: findAction();
                        }
                    }
                }
                
                Rectangle {
                    anchors.top: objScroll.top
                    anchors.bottom: objScroll.bottom
                    anchors.left: objScroll.left
                    anchors.right: objScroll.right
                    
                    color: "transparent"
                    
                    border.color: "black"
                    border.width: 1
                }
            }
            
            GroupBox{
                title: qsTr("Instances")
                Layout.fillHeight: true
                Layout.fillWidth: true
                Layout.minimumWidth: 200
                Layout.maximumWidth: 65536
                Layout.minimumHeight: 200
                Layout.maximumHeight: 65536
                
                ScrollView{
                    id: insScroll
                    anchors.fill: parent
                    clip: true
                    
                    Item {
                        
                        width: insScroll.flickableItem.width
                        height: insContainer.height + 30 + addInsBtn.height
                        
                        ColumnLayout{
                            id: insContainer
                            
                            y: 5
                            
                            anchors.left: parent.left
                            anchors.leftMargin: 5
                            anchors.right: parent.right
                            anchors.rightMargin: 5
                        }
                        
                        ObjectiveItem{
                            id: addInsBtn
                            objective: null
                            anchors.top: insContainer.bottom
                            anchors.topMargin: 5
                            anchors.left: parent.left
                            anchors.leftMargin: 5
                            anchors.right: parent.right
                            anchors.rightMargin: 5
                            
                            button.onClicked: {
                                var instance = currentItem.createInstance();
                                Engine.savePlan(currentItem);
                                refreshExtra();
                                editInstance(instance);
                            }
                        }
                    }
                }
                
                Rectangle {
                    anchors.fill: parent
                    
                    color: "transparent"
                    
                    border.color: "black"
                    border.width: 1
                }
            }
        }
    }
}
