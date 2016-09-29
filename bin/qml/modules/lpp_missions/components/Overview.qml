import QtQuick 2.0
import QtQuick.Controls 1.4
import QtQuick.Dialogs 1.2
import QtQuick.Layouts 1.1

import lpp 1.0

Item {
    
    /*
      TODO:
        overview menu: when selected one / multiple, can: edit(one only), send to folder(open a new window for searchbar)
        if none selected: display statistics on currentFolder (action: most done action; mission: most done plan, active + upcoming mission instance ranked by imminence, 
        if one selected: display statistics on selected item (total time done, average time per[day, week, year]), also list of related items (such as plans that used this action, recent action sessions)
        if multiple selected: display culmulative statistics on selected items(total time, total reward gain)
        each sub statistics list can be clicked on to open new window that display list in full/ScrollView. 
    */
    id: overview;
    
    property string title: qsTr("Overview")
    
    anchors.fill: parent
    
    MessageDialog {
        id: messageBox_delete
        title: qsTr("Delete")
        icon: StandardIcon.Warning
        standardButtons: StandardButton.Yes | StandardButton.No;
        onYes: {
            del();
        }
    }
    
    property var timelineModule;
    
    Component.onCompleted: {
        mainWindow.allModulesLoaded.connect(onAllModulesLoaded);
    }
    
    function onAllModulesLoaded(){
        timelineModule = mainWindow.getModule("lpp_timeline/Main.qml");
    }
    
    function del() {
        /*
        var item = root.selector.currentFolder;
        //when the selector's current folder is deleted
        while (item != null){
            if (item == currentItem){
                root.selector.gotoFolder(currentItem.parentFolder);
                break;
            }
            item = item.parentFolder;
        }
        */
        if (root.selector.selectedItem.type == "folder"){
            Engine.deleteFolder(root.selector.selectedItem);
        }
        else if (root.selector.selectedItem.type == "action"){
            Engine.deleteAction(root.selector.selectedItem);
        }
        else if (root.selector.selectedItem.type == "plan"){
            Engine.deletePlan(root.selector.selectedItem);
        }
        
        root.selector.refreshDisplay();
    }
    
    function paste(destFolder){
        var i, item, targetVector, parents;
        var cutItem = root.selector.cutItem;
        
        if (cutItem.type == "folder"){
            parents = destFolder;
            while (parents != null){
                if (parents == cutItem){
                    mainWindow.showError(qsTr("Error"), qsTr("A folder cannot be pasted inside of itself."));
                    return false;
                }
                parents = parents.parentFolder;
            }
            
            targetVector = destFolder.folders;
        }
        else if (cutItem.type == "action") targetVector = destFolder.actions;
        else if (cutItem.type == "plan") targetVector = destFolder.plans;

        for (i = 0; i < targetVector.size; i++){
            item = targetVector.at(i);
            if (item != cutItem && item.name == cutItem.name){
                mainWindow.showError(qsTr("Name Conflict"), qsTr("Name of the item cut already exists in destination folder."));
                return false;
            }
        }
        
        if (cutItem.type == "folder") Engine.moveFolder(cutItem, destFolder);
        else if (cutItem.type == "action") Engine.moveAction(cutItem, destFolder);
        else if (cutItem.type == "plan") Engine.movePlan(cutItem, destFolder);
        
        root.selector.cutItem = null;
        
        root.selector.refreshDisplay();
    }
    
    ColumnLayout {
        id: test
        
        anchors.fill: parent
        GroupBox {
            Layout.fillWidth: true;
            Layout.minimumWidth: 200;
            Layout.maximumWidth: 65536;
            title: qsTr("Selected Items");
            
            RowLayout {
                
                Button {
                    Layout.alignment: Qt.AlignLeft | Qt.AlignVCenter
                    text: qsTr("Edit");
                    visible: root.selector.selectedItem != null
                    onClicked: {
                        content.editor.select(root.selector.selectedItem);
                    }
                }
                
                Button {
                    Layout.alignment: Qt.AlignLeft | Qt.AlignVCenter
                    text: qsTr("Cut");
                    visible: root.selector.selectedItem != null
                    enabled: root.selector.cutItem != root.selector.selectedItem;
                    onClicked: {
                        root.selector.cutItem = root.selector.selectedItem;
                    }
                }
                
                Button {
                    Layout.alignment: Qt.AlignLeft | Qt.AlignVCenter
                    text: qsTr("Paste Inside");
                    visible: root.selector.selectedItem != null && root.selector.selectedItem.type == "folder"
                    enabled: root.selector.cutItem != null;
                    onClicked: {
                        paste(root.selector.selectedItem);
                    }
                }
                
                Button {
                    Layout.alignment: Qt.AlignLeft | Qt.AlignVCenter
                    text: qsTr("Paste Here");
                    visible: root.selector.selectedItem == null;
                    enabled: root.selector.cutItem != null;
                    onClicked: {
                        paste(root.selector.currentFolder);
                    }
                }
                
                Button {
                    Layout.alignment: Qt.AlignLeft | Qt.AlignVCenter
                    text: qsTr("Set as Active");
                    visible: root.selector.selectedItem != null && root.selector.selectedItem.type == "action";
                    enabled: !timelineModule.timeline.activeDrawEnabled || root.selector.selectedItem != timelineModule.timeline.activeAction;
                    onClicked: {
                        timelineModule.timeline.activeDrawEnabled = true;
                        timelineModule.timeline.activeAction = root.selector.selectedItem;
                    }
                }
                
                Button {
                    Layout.alignment: Qt.AlignLeft | Qt.AlignVCenter
                    text: qsTr("Draw on Timeline");
                    visible: root.selector.selectedItem != null && root.selector.selectedItem.type == "action";
                    onClicked: {
                        mainWindow.showModuleDirect(timelineModule);
                        timelineModule.timeline.startEdit(root.selector.selectedItem);
                    }
                }
                
                Button {
                    Layout.alignment: Qt.AlignLeft | Qt.AlignVCenter
                    text: qsTr("New Attached Mission");
                    visible: root.selector.selectedItem != null && root.selector.selectedItem.type == "action";
                    onClicked: {
                        mainWindow.showModuleDirect(timelineModule);
                        timelineModule.timeline.startNewPlanEdit(root.selector.selectedItem);
                    }
                }
            }
            
            //*
            Button {
                //Layout.alignment: Qt.AlignLeft | Qt.AlignVCenter
                anchors.right: parent.right
                text: qsTr("Delete");
                enabled: root.selector.selectedItem != null
                onClicked: {
                    if (root.selector.selectedItem.type == "folder"){
                        messageBox_delete.text = qsTr("Do you really want to delete this folder (%1) and all of its contents? This cannot be undone.").arg(root.selector.selectedItem.name);
                    }
                    else if (root.selector.selectedItem.type == "action"){
                        messageBox_delete.text = qsTr("Do you really want to delete this action (%1)? This cannot be undone.").arg(root.selector.selectedItem.name);
                    }
                    else if (root.selector.selectedItem.type == "plan"){
                        messageBox_delete.text = qsTr("Do you really want to delete this mission plan (%1)? This cannot be undone.").arg(root.selector.selectedItem.name);
                    }
                    
                    messageBox_delete.open();
                }
            }
            //*/
            
        }
        
        GroupBox {
            Layout.fillHeight: true;
            Layout.fillWidth: true;
        }
    }
    
    signal closing();
}
