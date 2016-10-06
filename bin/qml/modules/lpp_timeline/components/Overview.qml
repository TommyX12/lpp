import QtQuick 2.0
import QtQuick.Controls 1.4
import QtQuick.Dialogs 1.2
import QtQuick.Layouts 1.1

import modules.lpp_utils 1.0
import modules.lpp_missions 1.0

Item {
    
    property string title: qsTr("Overview")
    
    anchors.fill: parent
    
    property int occItemHeight: 27
    
    //property var freeTime: [0,0,0]
    //property var freeTimePercentage: [0,0,0]
    
    property var freeTimeTxts: [freeTimeTxt1, freeTimeTxt2, freeTimeTxt3, freeTimeTxt4, freeTimeTxt5, freeTimeTxt6]
    
    Component {
        id: occItem_comp
        OccurrenceItem{
            
        }
    }
    
    Component.onCompleted: {
        mainWindow.enterSecond.connect(onEnterSecond);
        
        root.enter.connect(onEnter);
        
        timeline.timelineEdited.connect(onTimelineEdited);
        
        refreshAll();
    }
    
    function onEnter(){
        refreshAll();
    }
    
    function onEnterSecond(){
        refreshRealtime();
    }
    
    function onTimelineEdited(){
        refreshOnChange();
    }
    
    function refreshRealtime(){
        currentTimeTxt.text = Engine.timeToStringReadFull(Engine.currentTime());
    }
    
    function refreshOnChange(){
        var occurrences = Engine.occurrences;
        
        var now = Engine.limitTimePrecision(Engine.currentTime());
        
        var i, occurrence;
        
        pastList.clear();
        activeList.clear();
        upcomingList.clear();
        
        for (i = 0; i < occurrences.size; i++){
            occurrence = occurrences.at(i);
            
            if (occurrence.startTime >= Engine.autoplanMax) break;
            
            if (occurrence.endTime <= now){
                pastList.add(occurrence);
            }
            else if (occurrence.startTime > now){
                upcomingList.add(occurrence);
            }
            else {
                activeList.add(occurrence);
            }
        }
        
        pastList.refresh();
        activeList.refresh();
        upcomingList.refresh();
        
        for (i = 0; i < freeTimeTxts.length; ++i){
            var freeTime = Engine.getFreeTime(i);
            var freeTimePercentage = Engine.getFreeTimePercentage(i);
            
            freeTimeTxts[i].text = Engine.minutesToString(freeTime) + " (" + (freeTimePercentage*100).toFixed(1) + "%)"
            freeTimeTxts[i].color = getFreeTimeColor(freeTimePercentage)
        }
        
    }
    
    function getFreeTimeColor(percentage){
        if (percentage > 0.3){
            return "#33BB33";
        }
        else if (percentage > 0.15){
            return "#3333DD";
        }
        else if (percentage > 0.0){
            return "#e89600";
        }
        else {
            return "#DD3333";
        }
    }
    
    function refreshAll(){
        refreshRealtime();
        refreshOnChange();
    }
    
    ColumnLayout {
        
        anchors.fill: parent
        
        Rectangle {
            Layout.fillWidth: true
            color: "transparent"
            border.color: "black"
            border.width: 2
            height: 36
            Label {
                anchors.centerIn: parent;
                id: currentTimeTxt
                text: "";
                font.bold: true
                font.pointSize: 12
            }
        }
        
        /*
        Label {
            Layout.fillWidth: true
            horizontalAlignment: Text.AlignHCenter
            text: "-- " + qsTr("Active Action") + " --";
            font.bold: true
        }
        */
        
        RowLayout {
            Layout.fillWidth: true
            Layout.minimumWidth: 400
            Layout.maximumWidth: 65536
            Layout.minimumHeight: 300
            Layout.maximumHeight: 300
            
            GroupBox {
                title: qsTr("Past Missions")
                Layout.minimumWidth: 100
                Layout.fillWidth: true
                Layout.fillHeight: true
                Layout.minimumHeight: 100
                Layout.maximumHeight: 65536
                
                PooledList {
                    id: pastList
                    objItemComponent: occItem_comp
                    objItemHeight: occItemHeight
                    anchors.fill: parent
                }
            }
            GroupBox {
                title: qsTr("Active Missions")
                Layout.minimumWidth: 100
                Layout.fillWidth: true
                Layout.fillHeight: true
                Layout.minimumHeight: 100
                Layout.maximumHeight: 65536
                
                PooledList {
                    id: activeList
                    objItemComponent: occItem_comp
                    objItemHeight: occItemHeight
                    anchors.fill: parent
                }
            }
            GroupBox {
                title: qsTr("Upcoming Missions")
                Layout.minimumWidth: 100
                Layout.fillWidth: true
                Layout.fillHeight: true
                Layout.minimumHeight: 100
                Layout.maximumHeight: 65536
                
                PooledList {
                    id: upcomingList
                    objItemComponent: occItem_comp
                    objItemHeight: occItemHeight
                    anchors.fill: parent
                }
            }
        }
        
        GroupBox {
            title: qsTr("Maximum Free Time")
            Layout.minimumWidth: 100
            Layout.maximumWidth: 65536
            Layout.fillWidth: true
            width: 10
            height: 40
            clip: true
            GridLayout {
                layoutDirection: Qt.LeftToRight
                columnSpacing: 5
                rows: 2
                flow: GridLayout.LeftToRight
                columns: 6
                rowSpacing: 5
                anchors.centerIn: parent
                Label {
                    text: qsTr("In 1 Day:")
                }
                Label {
                    id: freeTimeTxt1
                    font.bold: true
                }
                Label {
                    text: qsTr("In 2 Days:")
                }
                Label {
                    id: freeTimeTxt2
                    font.bold: true
                }
                Label {
                    text: qsTr("In 7 Days:")
                }
                Label {
                    id: freeTimeTxt3
                    font.bold: true
                }
                Label {
                    text: qsTr("In 14 Days:")
                }
                Label {
                    id: freeTimeTxt4
                    font.bold: true
                }
                Label {
                    text: qsTr("In 30 Days:")
                }
                Label {
                    id: freeTimeTxt5
                    font.bold: true
                }
                Label {
                    text: qsTr("In 360 Days:")
                }
                Label {
                    id: freeTimeTxt6
                    font.bold: true
                }
            }
        }
        
        
        GridLayout {
            Layout.fillWidth: true
            Layout.fillHeight: true
            Layout.minimumWidth: 400
            Layout.minimumHeight: 200
            Layout.maximumWidth: 65536
            Layout.maximumHeight: 65536
        }
    }
}
