import QtQuick 2.6
import QtQuick.Controls 1.4
import QtQuick.Layouts 1.3
import lpp 1.0
import QtQuick.Dialogs 1.2

import lpp 1.0
import modules.lpp_utils 1.0

RowLayout {
    
    property Instance instance: null;
    
    property alias button: button
    
    property var editFunc: null;
    property var deleteFunc: null;

    SimpleButton {
        
        clip: true
        
        Layout.fillWidth: true;
        
        id: button
        
        height: 30
        
        RowLayout {
            
            anchors.verticalCenter: button.verticalCenter
            anchors.left: button.left
            anchors.leftMargin: 10
            
            spacing: 5
            
            Label {
                
                //font.bold: true
                
                color: button.label.color
                
                text: instance == null ? "" : ("[" + Engine.timeSpanToString(instance.startTime, instance.endTime) + "]");
            }
            
            Label {
                id: repeatTxt
                
                font.bold: true
                
                color: button.label.color
                
                text: ""
            }
        }
        
        buttonColor: "#dddddd"
        
        text: instance != null ? "" : qsTr("+ Add")
        
        onClicked: {
            if (instance != null) editFunc(instance);
        }
    }
    
    SimpleButton {
        visible: instance != null
        height: button.height
        width: 70
        text: qsTr("Delete");
        onClicked: {
            deleteFunc(instance);
        }
    }
    
    function refresh(){
        repeatTxt.text = Utils.getRepeatTxt(instance);
    }
}
