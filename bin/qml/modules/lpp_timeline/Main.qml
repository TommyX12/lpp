import QtQuick 2.6
import QtQuick.Controls 1.4
import QtQuick.Layouts 1.3
import "components"

Item {
    id: root
    anchors.fill: parent
    
    /*
      overview shows current action, upcoming/active missions, current buffs etc.
      another page display necessary tools for editing timeline, such as active draw, and manual draw
      
      */
    
    property string title: qsTr("Timeline")
    
    property alias timeline: timelineView.timeline;
    
    property alias occurrenceWindow: occurrenceWindow
    
    signal enter();
    
    property var missionsModule;
    
    Component.onCompleted: {
        mainWindow.allModulesLoaded.connect(onAllModulesLoaded);
    }
    
    function onAllModulesLoaded(){
        missionsModule = mainWindow.getModule("lpp_missions/Main.qml");
    }
    
    RowLayout {
        id: rowLayout1
        anchors.fill: parent
        spacing: 10
        
        GroupBox {
            Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
            Layout.maximumWidth: 420
            Layout.minimumHeight: 600
            Layout.minimumWidth: 420
            Layout.fillHeight: true
            Layout.fillWidth: false
            flat: false
            checkable: false
            checked: true
            title: qsTr("Timeline")
            
            TimelineView {
                id: timelineView
            }
        }
        /*
        TabBar {
            id: tabBar
            
            Layout.maximumWidth: 100
            Layout.minimumWidth: 100
            Layout.minimumHeight: 320
            Layout.fillWidth: false
            Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
            Layout.fillHeight: true
        }
        */
        GroupBox {
            title: content.title
            
            Layout.maximumWidth: 65535
            Layout.minimumWidth: 250
            Layout.minimumHeight: 320
            Layout.fillWidth: true
            Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
            Layout.fillHeight: true
            
            ContentBox {
                id: content
                
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.top: parent.top
                anchors.topMargin: 5
                anchors.bottom: parent.bottom
            }
        }
        
    }
    
    OccurrenceWindow {
        id: occurrenceWindow
    }
    
}
