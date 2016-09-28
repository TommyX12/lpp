import QtQuick 2.0
import QtQuick.Controls 1.4
import QtQuick.Layouts 1.1

import "utils/Utils.js" as Utils

Item {
    id: list
    
    property var objItemPool: []
    
    property var objList: []
    
    property int numObjects: 0
    
    property Component objItemComponent: null
    
    property real objItemHeight: 25;
    
    property real spacing: 5;
    property real sideSpacing: 5
    
    signal itemTriggered(var object, int index, var data);
    
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
        
        var start = Utils.clamp(Math.floor((objItemScroll.flickableItem.contentY - spacing) / (objItemHeight + spacing)), 0, numObjects);
        var end = Utils.clamp(Math.ceil((objItemScroll.flickableItem.contentY + objItemScroll.flickableItem.height - spacing) / (objItemHeight + spacing)), 0, numObjects);
        
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
            objItem.y = i * (objItemHeight + spacing);
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
        
        objItemContainerWrap.height = numObjects * (spacing + objItemHeight) + spacing;
    }
    
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
