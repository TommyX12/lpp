import QtQuick 2.0
import QtQuick.Controls 1.4

Item {
    
    property int maxHistory: 50;
    
    property Item currentItem: null;
    property var history: [];
    
    id: container
    
    Component.onCompleted: function(){
        for (var i = 0; i < container.data.length; i++){
            container.data[i].visible = container.data[i].enabled = false;
            container.data[i].anchors.fill = undefined;
        }
    }
        
    function add(item) {
        data.push(item);
        item.visible = item.enabled = false;
    }
   
    function show(item) {
        if (currentItem != null){
            currentItem.visible = currentItem.enabled = false;
            currentItem.anchors.fill = undefined;
        }
        item.visible = item.enabled = true;
        item.anchors.fill = container;
        currentItem = item;
        
        history.push(currentItem);
        while (history.length > maxHistory) history.shift();
        
    }
    
    function back(){
        if (history.length > 0) {
            history.pop();
            show(history.pop());
        }
    }
    
}
