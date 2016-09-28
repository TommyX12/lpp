import QtQuick 2.0
import QtQuick.Controls 1.4
import QtQuick.Layouts 1.1
import QtQuick.Dialogs 1.2

import lpp 1.0
import modules.lpp_utils 1.0

ColumnLayout {
    id: selector
    
    //TODO:
    /*
        integrate searchbar in selector, using separate window. 
      */
    
    property real rightMargin: 5;
    property real leftMargin: 7;
    
    property real itemHeight: 30;
    property real itemVSpacing: 5;
    
    property var currentFolder: Engine.rootFolder;
    
    property var selectedItem: null;
    
    property var cutItem: null;
    
    anchors.left: parent.left
    anchors.right: parent.right
    
    property var tableItem_comp;
    property var itemList: [];
    
    enabled: !root.content.editor.visible
    
    Component.onCompleted: {
        tableItem_comp = Qt.createComponent("LibraryItem.qml");
        refreshDisplay();
        
        mainWindow.moduleChange.connect(onModuleChange);
        Engine.objectDeleted.connect(onObjectDeleted);
    }
    
    function onModuleChange(event){
        selectedItem = null;
        cutItem = null;
    }
    
    function onObjectDeleted(object){
        if (cutItem == object) cutItem = null;
    }
    
    onCurrentFolderChanged: {
        refreshDisplay();
    }
    
    MessageDialog {
        id: messageBox_error
        title: qsTr("Error")
        text: ""
        icon: StandardIcon.Critical
        standardButtons: StandardButton.Ok;
    }
    
    NewFolderDialog {
        id: dialog_newFolder
    }
    
    NewActionDialog {
        id: dialog_newAction
    }
    
    NewPlanDialog {
        id: dialog_newPlan
    }
    
    Finder {
        id: finder
        
    }
    
    function showFinder(){
        finder.show(true, true, true, select);
    }
    
    function select(item){
        if (item != null){
            selector.gotoFolder(item.parentFolder);
            selector.selectedItem = item;
        }
    }
    
    function displayQObjectVector(vector, indexOffset, j){
        var start = Utils.clamp(Math.floor(scrollView.flickableItem.contentY / (itemHeight + itemVSpacing)) - indexOffset, 0, vector.size);
        var end = Utils.clamp(Math.ceil((scrollView.flickableItem.contentY + scrollView.flickableItem.height) / (itemHeight + itemVSpacing)) - indexOffset, 0, vector.size);
        
        var i;
        var item;
        
        for (i = start; i < end; i++){
            item = vector.at(i);
            
            //if (item == null) continue;
            
            if (j >= itemList.length){
                itemList.push(tableItem_comp.createObject(tableArea));
            }
            
            itemList[j].visible = itemList[j].enabled = true;
            itemList[j].y = (i + indexOffset) * (itemHeight + itemVSpacing);
            itemList[j].currentItem = item;
            
            j++;
        }
        
        return j;
    }
    
    function refreshDisplay() {
        var i, j = 0;
        
        for (i = 0; i < itemList.length; i++){
            itemList[i].visible = itemList[i].enabled = false;
        }
        
        var indexOffset = 1;
        j = displayQObjectVector(currentFolder.folders, indexOffset, j);
        indexOffset += currentFolder.folders.size + 1;
        j = displayQObjectVector(currentFolder.actions, indexOffset, j);
        indexOffset += currentFolder.actions.size + 1;
        j = displayQObjectVector(currentFolder.plans, indexOffset, j);
        
        //console.log(itemList.length)
    }
    
    RowLayout {
       
        Layout.fillWidth: true;
        
        SimpleButton {
            Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
            width: 100
            height: itemHeight
            clip: true
            text: "<- " + currentFolder.parentFolder.name
            
            enabled: visible
            visible: currentFolder.parentFolder != null
            
            Component.onCompleted: {
                borderColor = Qt.binding(function(){return currentFolder.parentFolder.color;});
            }
            
            onClicked: {
                var cur = currentFolder
                gotoFolder(currentFolder.parentFolder);
                selectedItem = cur;
            }
        }
        
        Rectangle {
            Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
            Layout.fillWidth: true;
            height: itemHeight
            
            Label {
                font.bold: true
                anchors.centerIn: parent
                text: currentFolder.name
            }
            
            color: "#fafafa";
            border.width: 2;
            border.color: currentFolder.color
        }
    }
    
    Item {
        id: buttons
        Layout.fillWidth: true;
        height: 25
        
        Button {
            id: newFolderBtn
            anchors.top: parent.top
            anchors.bottom: parent.bottom
            anchors.left: parent.left
            text: qsTr("New Folder")
            onClicked: {
                dialog_newFolder.show();
            }
        }
        
        Button {
            id: newActionBtn
            anchors.top: parent.top
            anchors.bottom: parent.bottom
            anchors.left: newFolderBtn.right
            anchors.leftMargin: 5
            text: qsTr("New Action")
            onClicked: {
                dialog_newAction.show();
            }
        }
        
        Button {
            id: newPlanBtn
            anchors.top: parent.top
            anchors.bottom: parent.bottom
            anchors.left: newActionBtn.right
            anchors.leftMargin: 5
            text: qsTr("New Mission")
            onClicked: {
                dialog_newPlan.show();
            }
        }
        
        Button {
            anchors.top: parent.top
            anchors.bottom: parent.bottom
            anchors.right: parent.right
            text: qsTr("Search")
            onClicked: {
                //#tba
                showFinder();
            }
        }
    }
    
    Rectangle {
        color: "white"
        border.width: 2
        border.color: currentFolder.color
        Layout.fillHeight: true
        Layout.fillWidth: true
        
        MouseArea {
            id: bgMouseArea
            anchors.fill: parent
            onClicked: {
                selectedItem = null;
            }
        }
        
        ScrollView {
            id: scrollView
            //anchors.fill: parent
            
            horizontalScrollBarPolicy: Qt.ScrollBarAlwaysOff
            verticalScrollBarPolicy: Qt.ScrollBarAlwaysOn
            
            anchors.fill:  parent
            
            //frameVisible: true;
            highlightOnFocus: true;
            
            flickableItem.onContentYChanged: {
                selector.refreshDisplay()
            }
            
            flickableItem.onHeightChanged: {
                selector.refreshDisplay()
            }
            
            Item {
                id: tableArea
                
                width: scrollView.flickableItem.width - rightMargin - leftMargin
                x: leftMargin
                height: (currentFolder.folders.size + currentFolder.actions.size + currentFolder.plans.size + 3) * (itemHeight + itemVSpacing);
                
                Item {
                    
                    anchors.left: parent.left
                    anchors.right: parent.right
                    
                    height: itemHeight
                    
                    y: 0
                    
                    Label {
                        id: subFoldersLabel
                        text: qsTr("--- Sub-Folders ---")
                        anchors.centerIn: parent
                    }
                }
                
                Item {
                    
                    anchors.left: parent.left
                    anchors.right: parent.right
                    
                    height: itemHeight
                    
                    y: (1 + currentFolder.folders.size) * (itemHeight + itemVSpacing)
                    
                    Label {
                        id: actionsLabel
                        text: qsTr("--- Actions ---")
                        anchors.centerIn: parent
                    }
                }
                
                Item {
                    
                    anchors.left: parent.left
                    anchors.right: parent.right
                    
                    height: itemHeight
                    
                    y: (1 + currentFolder.folders.size + 1 + currentFolder.actions.size) * (itemHeight + itemVSpacing)
                    
                    Label {
                        id: plansLabel
                        text: qsTr("--- Missions ---")
                        anchors.centerIn: parent
                    }
                }
            }
        }
    }
    
    function gotoFolder(folder){
        currentFolder = folder;
        scrollView.flickableItem.contentY = 0;
        selectedItem = null;
    }
}
