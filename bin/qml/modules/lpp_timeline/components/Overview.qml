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
        
        var i = 0, occurrence = null;
        
        pastList.list.clear();
        activeList.list.clear();
        upcomingList.list.clear();
        
        var alerts = [0,0,0,0,0,0,0,0,0];
        var canceled = [0,0,0];
        
        
        for (i = 0; i < occurrences.size; i++){
            occurrence = occurrences.at(i);
            
            if (occurrence.endTime <= now){
                if (occurrence.canceled) {
                    canceled[0]++;
                    if (showCanceledBox.checked) pastList.list.add(occurrence);
                    continue;
                }
                pastList.list.add(occurrence);
                if (occurrence.impossible) alerts[2]++;
                else if (occurrence.progress < 1.0) alerts[1]++;
                else alerts[0]++;
            }
            else if (occurrence.startTime > now){
                if (occurrence.canceled) {
                    canceled[2]++;
                    if (showCanceledBox.checked) upcomingList.list.add(occurrence);
                    continue;
                }
                if (occurrence.startTime < Engine.autoplanMax) {
                    upcomingList.list.add(occurrence);
                }
                if (occurrence.impossible) alerts[8]++;
                else if (occurrence.endTime <= Engine.autoplanMax && occurrence.progress < 1.0) alerts[7]++;
                else alerts[6]++;
            }
            else {
                if (occurrence.canceled) {
                    canceled[1]++;
                    if (showCanceledBox.checked) activeList.list.add(occurrence);
                    continue;
                }
                activeList.list.add(occurrence);
                if (occurrence.impossible) alerts[5]++;
                else if (occurrence.endTime <= Engine.autoplanMax && occurrence.progress < 1.0) alerts[4]++;
                else alerts[3]++;
            }
        }
        
        pastList.list.refresh();
        activeList.list.refresh();
        upcomingList.list.refresh();
        
        pastList.updateTxt(alerts[0], alerts[1], alerts[2], canceled[0]);
        activeList.updateTxt(alerts[3], alerts[4], alerts[5], canceled[1]);
        upcomingList.updateTxt(alerts[6], alerts[7], alerts[8], canceled[2]);
        
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
            return "#e8a200";
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
        
        CheckBox{
            id: showCanceledBox
            text: qsTr("Show Canceled Occurrences")
            checked: false
            onCheckedChanged: {
                refreshOnChange();
            }
        }
        
        RowLayout {
            Layout.fillWidth: true
            Layout.minimumWidth: 400
            Layout.maximumWidth: 65536
            Layout.minimumHeight: 300
            Layout.maximumHeight: 300
            
            GroupBox {
                title: qsTr("Past Missions")
                Layout.minimumWidth: 100
                Layout.maximumWidth: 65536
                Layout.fillWidth: true
                Layout.fillHeight: true
                Layout.minimumHeight: 100
                Layout.maximumHeight: 65536
                width: 10
                height: 10
                
                MissionList {
                    id: pastList
                    anchors.fill: parent
                    occItem_comp: occItem_comp
                    occItemHeight: occItemHeight
                }
            }
            GroupBox {
                title: qsTr("Active Missions")
                Layout.minimumWidth: 100
                Layout.maximumWidth: 65536
                Layout.fillWidth: true
                Layout.fillHeight: true
                Layout.minimumHeight: 100
                Layout.maximumHeight: 65536
                width: 10
                height: 10
                
                MissionList {
                    id: activeList
                    anchors.fill: parent
                    occItem_comp: occItem_comp
                    occItemHeight: occItemHeight
                }
            }
            GroupBox {
                title: qsTr("Upcoming Missions")
                Layout.minimumWidth: 100
                Layout.maximumWidth: 65536
                Layout.fillWidth: true
                Layout.fillHeight: true
                Layout.minimumHeight: 100
                Layout.maximumHeight: 65536
                
                MissionList {
                    id: upcomingList
                    anchors.fill: parent
                    occItem_comp: occItem_comp
                    occItemHeight: occItemHeight
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
