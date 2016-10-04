import QtQuick 2.6
import QtQuick.Controls 1.4
import QtQuick.Layouts 1.3
import lpp 1.0
import QtQuick.Dialogs 1.2

import lpp 1.0
import modules.lpp_utils 1.0

RowLayout {
    
    property Objective objective: null;
    
    property alias button: button
    
    property var editFunc: null;
    property var deleteFunc: null;
    property var moveFunc: null;
    
    Item {
        Layout.alignment: Qt.AlignCenter
        
        visible: objective != null
        
        width: 30
        height: 30
        
        SimpleButton{
            height: 15
            width: 30
            
            Image{
                source: "qrc:/images/grey_triangle.png"
                width: 10
                height: 10                
                anchors.centerIn: parent
                fillMode: Image.PreserveAspectFit
            }
            
            onClicked: {
                moveFunc(objective, -1)
            }
        }
        
        SimpleButton{
            height: 15
            width: 30
            y: 15
            
            Image{
                source: "qrc:/images/grey_triangle.png"
                width: 10
                height: 10
                rotation: 180
                anchors.centerIn: parent
                fillMode: Image.PreserveAspectFit
            }
            
            onClicked: {
                moveFunc(objective, 1)
            }
        }
    }

    SimpleButton {
        
        clip: true
        
        Layout.fillWidth: true;
        
        id: button
        
        height: 30
        
        RowLayout {
            
            anchors.verticalCenter: button.verticalCenter
            anchors.left: button.left
            anchors.leftMargin: 10
            
            spacing: 10
            
            Label {
                
                font.bold: true
                color: button.label.color
                
                text: objective == null ? "" : Engine.minutesToString(objective.length)
            }
            
            Label {
                
                color: button.label.color
                
                text: objective == null ? "" : objective.action.name
            }
        }
        
        buttonColor: objective == null ? "#eeeeee" : objective.action.parentFolder.color
        
        text: objective != null ? "" : qsTr("+ Add")
        
        onClicked: {
            if (objective != null) editFunc(objective);
        }
    }
    
    SimpleButton {
        visible: objective != null
        height: button.height
        width: 50
        text: qsTr("Delete");
        onClicked: {
            deleteFunc(objective);
        }
    }
}
