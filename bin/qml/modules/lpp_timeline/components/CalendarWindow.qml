import QtQuick 2.4
import QtQuick.Controls 1.4
import QtQuick.Layouts 1.1

ApplicationWindow {
    visible: false
    id: calendarWindow
    width: 480
    height: 320
    title: qsTr("Calendar")
    flags: Qt.Window
    modality: Qt.WindowModal
    Rectangle {
        id: bg
        color: "#ffffff"
        anchors.fill: parent
    }
    
    property var handler;
    
    property alias text: txt.text;
    
    function refreshTxt(){
        txt.text = calendar.selectedDate.getFullYear() + "-" + (calendar.selectedDate.getMonth()+1) + "-" + calendar.selectedDate.getDate() + " " + txt.text.split(" ")[1];
    }
    
    Component.onCompleted: {
        refreshTxt();
    }
    
    ColumnLayout {
        
        anchors.fill: parent
        anchors.topMargin: 10
        anchors.leftMargin: 10
        anchors.rightMargin: 10
        anchors.bottomMargin: 10
        
        Calendar {
            id: calendar
            Layout.fillWidth: true
            Layout.fillHeight: true
            selectedDate: null;
            onSelectedDateChanged: {
                refreshTxt();
            }
        }
        
        RowLayout {
            Layout.fillWidth: true
            Layout.alignment: Qt.AlignCenter
            height: 32;
            TextField {
                id: txt
                Layout.fillWidth: true
                Layout.alignment: Qt.AlignCenter
                inputMask: "0000-00-00 00:00"
                
                horizontalAlignment: Text.AlignHCenter
                
                Keys.onReturnPressed: {
                    selectDate();
                }
            }
            Button {
                text: qsTr("Select");
                onClicked: {
                    selectDate();
                }
            }
        }
    }
        
    function show(date, handler, text){
        calendarWindow.visible = true;
        calendar.selectedDate = date;
        calendarWindow.handler = handler;
        if (text != undefined) txt.text = text;
        txt.focus = true;
        txt.selectAll();
    }
    
    function selectDate(){
        var timeInfo = [];
        var defaultInfo = [2000, 1, 1, 12, 0, 0];
        var str = txt.text;
        var i;
        var buffer = "";
        for (i = 0; i <= str.length; i++){
            var c = str.charAt(i);
            if (c >= '0' && c <= '9') {
                buffer += c;
            } else {
                if (buffer.length > 0) timeInfo.push(parseInt(buffer));
                buffer = "";
            }
        }
        
        for (i = 0; i < 6; i++){
            if (timeInfo.length == i){
                timeInfo.push(defaultInfo[i]);
            }
        }
        
        var date = new Date(Date.UTC(timeInfo[0], timeInfo[1]-1, timeInfo[2], timeInfo[3], timeInfo[4], timeInfo[5]));

        if (!isNaN(date.getTime())) {
            handler(date);
            //console.log(date.toUTCString())
            calendarWindow.close();
        }
    }

    onClosing: function (close){
        //close.accepted = false;
    }
}
