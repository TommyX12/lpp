import QtQuick 2.0
import QtQuick.Controls 1.4
import QtQuick.Layouts 1.1

import modules.lpp_utils 1.0

ColumnLayout {
    
    property alias list: list
    property Component occItem_comp: null
    property real occItemHeight: 25
    
    function updateTxt(numBlue, numYellow, numRed){
        txt1.text = numBlue
        
        if (numYellow > 0) {
            txt2.visible = true
            txt2.text = numYellow
        }
        else txt2.visible = false
        
        if (numRed > 0) {
            txt3.visible = true
            txt3.text = numRed
        }
        else txt3.visible = false
    }
    
    RowLayout {
        Layout.alignment: Qt.AlignCenter
        spacing: 15
        Label {
            id: txt1
            font.bold: true
            color: "#3333DD"
            visible: true
        }
        Label {
            id: txt2
            font.bold: true
            color: "#e8a500"
            visible: false
        }
        Label {
            id: txt3
            font.bold: true
            color: "#DD3333"
            visible: false
        }
    }
    
    PooledList {
        id: list
        objItemComponent: occItem_comp
        objItemHeight: occItemHeight
        Layout.fillHeight: true
        Layout.fillWidth: true
        Layout.minimumHeight: 100
        Layout.maximumHeight: 65536
        Layout.minimumWidth: 100
        Layout.maximumWidth: 65536
    }
}
