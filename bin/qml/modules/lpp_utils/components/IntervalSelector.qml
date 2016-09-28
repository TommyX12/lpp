import QtQuick 2.0
import QtQuick.Controls 1.4
import QtQuick.Layouts 1.1

import "utils/Utils.js" as Utils

GridLayout {
    layoutDirection: Qt.LeftToRight
    columnSpacing: 10
    rows: 3
    flow: GridLayout.LeftToRight
    columns: 3
    rowSpacing: 5
    
    property alias begin: beginTxt.text;
    property alias end: endTxt.text;
    
    function getBeginTime(){
        return Utils.parseDate(begin);
    }
    
    function getEndTime(){
        return Utils.parseDate(end);
    }
    
    Label{
        text: qsTr("Begin:")
    }
    
    TextField{
        id: beginTxt
        inputMask: "0000-00-00 00:00"
        Layout.fillWidth: true
        
        horizontalAlignment: Text.AlignHCenter
    }
    
    Button{
        text: qsTr("Now")
        onClicked: {
            beginTxt.text = Engine.timeToString(Engine.currentTime());
        }
    }
    
    Label{
        text: qsTr("End:")
    }
    
    TextField{
        id: endTxt
        inputMask: "0000-00-00 00:00"
        Layout.fillWidth: true
        
        horizontalAlignment: Text.AlignHCenter
    }
    
    Button{
        text: qsTr("Now")
        onClicked: {
            endTxt.text = Engine.timeToString(Engine.currentTime());
        }
    }
    
    Label{
        text: qsTr("Duration:")
    }
    
    Label{
        text: {
            var time1 = Utils.parseDate(beginTxt.text);
            var time2 = Utils.parseDate(endTxt.text);
            if (isNaN(time1) || isNaN(time2)) return qsTr("invalid");
            return Engine.minutesToString(Math.floor(Math.abs(time1 - time2) / minuteLength));
        }
    }
}
