import QtQuick 2.0
import QtQuick.Controls 1.4
import QtQuick.Layouts 1.1

import modules.lpp_utils 1.0
import lpp 1.0

RowLayout {
    
    property var currentItem: null;
    
    anchors.left: parent.left
    anchors.right: parent.right
    
    property color normalColor: {
        if (currentItem.type == "folder") return currentItem.color;//Qt.tint(currentItem.color, "#77ffffff")
        else if (currentItem.type == "action") return currentItem.parentFolder.color;
        else if (currentItem.type == "plan") return "#e0e0e0";
    }
    
    property bool selected: selector.selectedItem == currentItem;
    property bool cut: selector.cutItem == currentItem;
    
    property real itemHeight: selector.itemHeight;
    
    Rectangle{
        Layout.alignment: Qt.AlignRight | Qt.AlignVCenter
        Layout.fillHeight: true
        width: 10
        color: "#a0c8ff";
        opacity: selected ? 1.0 : 0.0;
        //Behavior on opacity {NumberAnimation{duration: 60; easing.type: Easing.Linear}}
    }
    
    Rectangle{
        Layout.alignment: Qt.AlignRight | Qt.AlignVCenter
        Layout.fillHeight: true
        width: 10
        color: "#ffc8a0";
        visible: cut;
    }
    
    SimpleButton {
        id: button
        Layout.alignment: Qt.AlignRight | Qt.AlignVCenter
        Layout.fillWidth: true
        height: selector.itemHeight
        Component.onCompleted: {
            //borderColor = Qt.binding(function(){return selector.currentFolder.color;});
            //console.log(Engine.rootFolder.color);
        }
        text: currentItem.name;
        buttonColor: normalColor
        clip: true
        onClicked: {
            if (selected){
                selector.selectedItem = null;
            }
            else {
                selector.selectedItem = currentItem;
            }
        }
        
        Rectangle {
            anchors.left: parent.left
            anchors.leftMargin: 5
            anchors.top: parent.top
            anchors.topMargin: 5
            anchors.bottom: parent.bottom
            anchors.bottomMargin: 5
            width: 20
            color: currentItem.type == "folder" ? "#aaaaaa" : currentItem.parentFolder.color
            visible: currentItem.type == "plan" || currentItem.type == "folder"
            border.color: "grey"
        }
        /*
        Rectangle {
            anchors.fill: parent
            border.color: currentItem.type == "folder" ? currentItem.color : "#000000"
            border.width: 2
            color: "transparent"
            visible: currentItem.type == "folder"
        }*/
    }
    
    SimpleButton {
        id: editButton
        Layout.alignment: Qt.AlignRight | Qt.AlignVCenter
        width: 60;
        height: itemHeight
        text: qsTr("Enter");
        visible: currentItem.type == "folder"
        enabled: visible;
        onClicked: {
            selector.gotoFolder(currentItem);
        }
    }
}   
