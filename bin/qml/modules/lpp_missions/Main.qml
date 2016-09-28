import QtQuick 2.6
import QtQuick.Controls 1.4
import QtQuick.Layouts 1.3
import "components"

Item {
    id: root
    anchors.fill: parent
    
    
    //TODO:
    /*
        
        
      */
    
    property string title: qsTr("Missions")
    
    property alias selector: selector;
    property alias content: content;
    property alias finder: finder
    
    Component.onCompleted: {
        
    }
    
    signal enter();
    
    Finder {
        id: finder
        
    }
    
    RowLayout {
        id: rowLayout1
        anchors.fill: parent
        antialiasing: false
        spacing: 10
        
        GroupBox {
            title: qsTr("Library")
            
            Layout.maximumWidth: 420
            Layout.minimumWidth: 420
            Layout.minimumHeight: 320
            Layout.maximumHeight: 65535
            Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
            Layout.fillHeight: true
            
            Selector {
                id: selector
                anchors.fill: parent
            }
        }
        
        GroupBox {
            title: content.title;
            
            Layout.maximumWidth: 65535
            Layout.minimumWidth: 450
            Layout.minimumHeight: 320
            Layout.maximumHeight: 65535
            Layout.fillWidth: true
            Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
            Layout.fillHeight: true
            
            ContentBox {
                id: content
                anchors.fill: parent
            }
        }
        
    }
    
}
