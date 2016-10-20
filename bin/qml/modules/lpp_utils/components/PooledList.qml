import QtQuick 2.0
import QtQuick.Controls 1.4
import QtQuick.Layouts 1.1

import "utils/Utils.js" as Utils

ColumnLayout{
    
    id: list
    
    property var objItemPool: []
    
    property var objList: []
    
    property int numObjects: 0
    
    property Component objItemComponent: null
    
    property real objItemHeight: 25;
    
    property real spacing: 5;
    property real sideSpacing: 5
    
    property int pageIndex: 1
    
    property int pageTotal: 1
    
    property int maxItemPerPage: 100
    
    function clear(){
        objList = [];
        
        numObjects = 0;
    }
    
    function add(object){
        objList.push(object);
        
        numObjects++;
    }
    
    function refresh(){
        var i, j = 0;
        
        for (i = 0; i < objItemPool.length; i++){
            objItemPool[i].visible = objItemPool[i].enabled = false;
        }
        
        pageTotal = Math.ceil(numObjects / maxItemPerPage)
        if (pageTotal == 0) pageTotal = 1;
        pageIndex = Utils.clamp(pageIndex, 1, pageTotal)
        
        var pageItemOffset = (maxItemPerPage * (pageIndex - 1));
        
        var start = Math.floor((objItemScroll.flickableItem.contentY - spacing) / (objItemHeight + spacing));
        var end = Math.ceil((objItemScroll.flickableItem.contentY + objItemScroll.flickableItem.height - spacing) / (objItemHeight + spacing));
        
        start = Utils.clamp(start + pageItemOffset, pageItemOffset, numObjects);
        end = Utils.clamp(end + pageItemOffset, pageItemOffset, Math.min(numObjects, start + maxItemPerPage));
        
        var obj, objItem;
        
        for (i = start; i < end; i++){
            if (j >= objItemPool.length){
                objItem = objItemComponent.createObject(objItemContainer);
                objItem.anchors.left = objItemContainer.left
                objItem.anchors.right = objItemContainer.right
                objItemPool.push(objItem);
            }
            else objItem = objItemPool[j];
            
            objItem.visible = objItem.enabled = true;
            objItem.y = (i - pageItemOffset) * (objItemHeight + spacing);
            objItem.object = objList[i];
            objItem.index = i;
            objItem.list = list;
            
            objItem.refresh();
            
            j++;
        }
        
        /*
        var objItem;
        
        if (numObjects >= objItemPool.length){
            objItem = objItemComponent.createObject(objItemContainer);
            objItem.Layout.fillWidth = true;
            objItemPool.push(objItem);
        }
        else {
            objItem = objItemPool[numObjects];
        }
        
        objItem.visible = true;
        objItem.object = object;
        */
        
        objItemContainerWrap.height = Math.min(numObjects - pageItemOffset, maxItemPerPage) * (spacing + objItemHeight) + spacing;
    }
    
    signal itemTriggered(var object, int index, var data);
    
    Item {
        
        Layout.fillHeight: true
        Layout.fillWidth: true
        Layout.minimumWidth: 50
        Layout.minimumHeight: 50
        Layout.maximumWidth: 65536
        Layout.maximumHeight: 65536
        
        ScrollView{
            id: objItemScroll
            anchors.fill: parent
            clip: true
            
            flickableItem.onContentYChanged: refresh();
            flickableItem.onHeightChanged: refresh();
            
            Item {
                id: objItemContainerWrap
                
                width: objItemScroll.flickableItem.width
                height: 1
                
                Item{
                    
                    id: objItemContainer
                    
                    anchors.top: parent.top
                    anchors.topMargin: spacing
                    anchors.left: parent.left
                    anchors.leftMargin: sideSpacing
                    anchors.right: parent.right
                    anchors.rightMargin: sideSpacing
                }
            }
        }
        
        Rectangle {
            anchors.fill:parent
            
            color: "transparent"
            
            border.color: "black"
            border.width: 1
        }
    }
    
    RowLayout {
        Layout.fillWidth: true
        Layout.minimumWidth: 50
        Layout.maximumWidth: 65536
        
        visible: maxItemPerPage != 0
        
        SimpleButton {
            width: 50
            Layout.alignment: Qt.AlignLeft
            text: "<-"
            enabled: pageIndex > 1
            onClicked: {
                pageIndex--;
                refresh();
            }
        }
        
        Label {
            Layout.fillWidth: true
            Layout.minimumWidth: 30
            Layout.maximumWidth: 65536
            Layout.alignment: Qt.AlignHCenter
            text: pageIndex + '/' + pageTotal
            horizontalAlignment: Text.AlignHCenter
        }
        
        SimpleButton {
            width: 50
            Layout.alignment: Qt.AlignRight
            text: "->"
            enabled: pageIndex < pageTotal
            onClicked: {
                pageIndex++;
                refresh();
            }
        }
    }
}
