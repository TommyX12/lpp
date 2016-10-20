import QtQuick 2.0
import QtQuick.Controls 1.4
import QtQuick.Layouts 1.1
import QtQuick.Dialogs 1.2

import lpp 1.0
import modules.lpp_utils 1.0

ApplicationWindow {
    id: finderWindow
    visible: false
    width: 350
    height: 550
    title: qsTr("Search")
    flags: Qt.Window
    modality: Qt.WindowModal
    
    property var handlerFunc;
    
    ColumnLayout {
        id: finder
        
        anchors.fill: parent
        anchors.topMargin: 10
        anchors.bottomMargin: 10
        anchors.leftMargin: 10
        anchors.rightMargin: 10
        
        //TODO:
        /*
            
          */
        spacing: 10
        
        property real itemHeight: 25;
        property real itemVSpacing: 0;
        
        property real internalLeftMargin: 10;
        
        property alias textField: textField
        
        property var itemList: [];
        
        property var selectedItem: null;
        property var selectedIndex: 0;
        
        property var searchList: null;
        
        property bool caseSensitive: caseSensitiveBox.checked;
        
        property alias scrollView: scrollView
        property alias tableArea: tableArea
        
        onCaseSensitiveChanged: {
            finder.search();
        }
        
        //property real maxWidth: 0;
        
        Component {
            id: tableItem_comp
            //#tba
            Rectangle {
                id: tableItem
                height: finder.itemHeight;
                anchors.left: parent.left
                
                width: finder.tableArea.width
                
                property var currentItem: null;
                property var currentIndex: 0;
                property bool selected: finder.selectedItem == currentItem;
                property alias text: label.text
                property alias label: label
                
                color: selected ? "#aaccff" : "#ffffff"
                
                MouseArea {
                    anchors.fill: parent
                    onClicked: {
                        //if (selected) selectedItem = null;
                        //else {
                            finder.selectedItem = currentItem;
                            finder.selectedIndex = currentIndex;
                        //}
                    }
                }
                
                Label {
                    id: label
                    text: "[" + qsTr(currentItem.typeName) + "] " + currentItem.fullPath;
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.left: parent.left
                    anchors.leftMargin: finder.internalLeftMargin
                    anchors.right: parent.right
                    elide: Text.ElideMiddle
                }
                
            }
        }
        
        function show(searchFolders, searchActions, searchPlans){
            allowFoldersBtn.enabled = allowFoldersBtn.checked = searchFolders
            allowActionsBtn.enabled = allowActionsBtn.checked = searchActions
            allowPlansBtn.enabled = allowPlansBtn.checked = searchPlans
            textField.focus = true;
            textField.selectAll()
            finder.search(true);
        }
        
        function search(requestList){
            if (requestList == true) searchList = Engine.requestSearchList(allowFoldersBtn.checked, allowActionsBtn.checked, allowPlansBtn.checked);
            searchList.refresh(textField.text, caseSensitive)
            selectedItem = searchList.size > 0 ? searchList.at(0).object : null;
            selectedIndex = 0;
            scrollView.flickableItem.contentY = 0;
            refreshDisplay();
        }
        
        Component.onCompleted: {
            
        }
        
        MessageDialog {
            id: messageBox_error
            title: qsTr("Error")
            text: ""
            icon: StandardIcon.Critical
            standardButtons: StandardButton.Ok;
        }
        
        function refreshDisplay() {
            /*
              #tba
            
            
            var indexOffset = 1;
            j = displayQObjectVector(currentFolder.folders, "folder", indexOffset, j);
            indexOffset += currentFolder.folders.size + 1;
            j = displayQObjectVector(currentFolder.actions, "action", indexOffset, j);
            indexOffset += currentFolder.actions.size + 1;
            j = displayQObjectVector(currentFolder.plans, "plan", indexOffset, j);
            
            //console.log(itemList.length)
            */
            
            tableArea.height = searchList.size * (itemHeight + itemVSpacing);
            
            var i, j = 0;
            
            for (i = 0; i < itemList.length; i++){
                itemList[i].visible = itemList[i].enabled = false;
            }
            
            var start = Utils.clamp(Math.floor(scrollView.flickableItem.contentY / (itemHeight + itemVSpacing)), 0, searchList.size);
            var end = Utils.clamp(Math.ceil((scrollView.flickableItem.contentY + scrollView.flickableItem.height) / (itemHeight + itemVSpacing)), 0, searchList.size);
            
            var item;
            
            //maxWidth = 0;
            
            for (i = start; i < end; i++){
                item = searchList.at(i);
                
                //if (item == null) continue;
                
                if (j >= itemList.length){
                    itemList.push(tableItem_comp.createObject(tableArea));
                }
                
                itemList[j].visible = itemList[j].enabled = true;
                itemList[j].y = (i) * (itemHeight + itemVSpacing);
                itemList[j].currentItem = item.object;
                //console.log(item.object, itemList[j], itemList, itemList[j].currentItem)
                itemList[j].currentIndex = i;
                
                //maxWidth = Math.max(maxWidth, itemList[j].label.contentWidth)
                
                j++;
            }
            
            //maxWidth += 2 * internalLeftMargin;
        }
        
        
        TextField {
            id: textField
            Layout.fillWidth: true
            focus: true
            onTextChanged: {
                finder.search();
            }
        }
        
        //*
        RowLayout {
            id: buttons
            Layout.fillWidth: true;
            
            Label {
                text: qsTr("Filter: ")
            }
            
            Button{
                id: allowFoldersBtn
                checkable: true
                text: qsTr("Folders")
                onClicked: {
                    finder.search(true)
                }
            }
            Button{
                id: allowActionsBtn
                checkable: true
                text: qsTr("Actions")
                onClicked: {
                    finder.search(true)
                }
            }
            Button{
                id: allowPlansBtn
                checkable: true
                text: qsTr("Missions")
                onClicked: {
                    finder.search(true)
                }
            }
        }
        //*/
        
        RowLayout {
            CheckBox {
                id: caseSensitiveBox
                text: qsTr("Case Sensitive")
            }
        }
        
        Item {
            Layout.fillHeight: true
            Layout.fillWidth: true
            
            Rectangle {
                id: tableView
                color: "white"
                anchors.fill: parent
                
                ScrollView {
                    id: scrollView
                    
                    horizontalScrollBarPolicy: Qt.ScrollBarAsNeeded
                    verticalScrollBarPolicy: Qt.ScrollBarAsNeeded
                    
                    anchors.fill:  parent
                    
                    //frameVisible: true;
                    highlightOnFocus: true;
                    
                    flickableItem.onContentYChanged: {
                        finder.refreshDisplay()
                    }
                    
                    flickableItem.onHeightChanged: {
                        finder.refreshDisplay()
                    }
                    
                    Item {
                        id: tableArea
                        width: finder.scrollView.flickableItem.width
                    }
                }
            }
            
            Rectangle {
                color: "transparent"
                border.width: 1
                border.color: "black"
                anchors.fill: parent
            }
        }
        
        Button {
            text: qsTr("Select")
            Layout.fillWidth: true
            onClicked: {
                finderWindow.onSelected(finder.selectedItem);
            }
        }
        
        Keys.onUpPressed: {
            if (searchList.size > 0){
                selectedIndex = Utils.clamp(selectedIndex - 1, 0, searchList.size - 1);
                selectedItem = searchList.at(selectedIndex).object;
            }
        }
        
        Keys.onDownPressed: {
            if (searchList.size > 0){
                selectedIndex = Utils.clamp(selectedIndex + 1, 0, searchList.size - 1);
                selectedItem = searchList.at(selectedIndex).object;
            }
        }
        
        Keys.onReturnPressed: {
            finderWindow.onSelected(selectedItem);
        }
        
        Keys.onEscapePressed: {
            finderWindow.onSelected(null);
        }
    }
    
    function show(searchFolders, searchActions, searchPlans, handler, title){
        if (title != undefined) finderWindow.title = title;
        else finderWindow.title = qsTr("Search");
        visible = true;
        handlerFunc = handler;
        finder.show(searchFolders, searchActions, searchPlans);
    }
    
    function onSelected(item){
        close();
        if (handlerFunc != null) handlerFunc(item);
    }
}


