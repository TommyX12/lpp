import QtQuick 2.0
import QtQuick.Controls 1.4
import QtQuick.Layouts 1.1

import "utils/Utils.js" as Utils

Item {
    id: list
    
    property Component objItemComponent: null
    
    property real objItemHeight: 25;
    
    property real spacing: 5;
    property real sideSpacing: 5
    
    property var objItemPool: []
    
    property int numObjects: 0
    
    property alias objItemScroll: objItemScroll
    
    signal itemTriggered(var object, int index, var data);
    
    function clear(){
        var i = 0;
        
        for (i = 0; i < objItemPool.length; i++){
            objItemPool[i].visible = objItemPool[i].enabled = false;
        }
        
        numObjects = 0;
    }
    
    function add(object){
        var objItem;
        
        if (numObjects >= objItemPool.length){
            objItem = objItemComponent.createObject(objItemContainer);
            objItem.anchors.left = objItemContainer.left
            objItem.anchors.right = objItemContainer.right
            objItemPool.push(objItem);
            
            objItem.y = numObjects * (objItemHeight + spacing);
        }
        else objItem = objItemPool[numObjects];
        
        objItem.visible = objItem.enabled = true;
        objItem.object = object;
        objItem.index = numObjects;
        objItem.list = list
            
        numObjects++;
    }
    
    function refresh(){
        objItemContainerWrap.height = numObjects * (spacing + objItemHeight) + spacing;
        
        var i;
        
        for (i = 0; i < objItemPool.length; i++){
            objItemPool[i].refresh();
        }
    }
    
    ScrollView{
        id: objItemScroll
        anchors.fill: parent
        clip: true
        
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
