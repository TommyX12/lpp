import QtQuick 2.0
import QtQuick.Controls 1.4
import QtQuick.Layouts 1.1

RowLayout {
    TextField {
        id: daysTxt
        Layout.fillWidth: true
        Layout.minimumWidth: 50
        Layout.maximumWidth: 65536
        
        horizontalAlignment: Text.AlignHCenter
        
        text: "0"
        
        validator: IntValidator{
            bottom: 0
            top: 9999
        }
    }
    
    Label {
        text: qsTr("Days")
    }
    
    TextField {
        id: hoursTxt
        Layout.fillWidth: true
        Layout.minimumWidth: 50
        Layout.maximumWidth: 65536
        
        horizontalAlignment: Text.AlignHCenter
        
        text: "0"
        
        validator: IntValidator{
            bottom: 0
            top: 9999
        }
    }
    
    Label {
        text: qsTr("Hours")
    }
    
    TextField {
        id: minutesTxt
        Layout.fillWidth: true
        Layout.minimumWidth: 50
        Layout.maximumWidth: 65536
        
        horizontalAlignment: Text.AlignHCenter
        
        text: "0"
        
        validator: IntValidator{
            bottom: 0
            top: 9999
        }
    }
    
    Label {
        text: qsTr("Minutes")
    }
    
    function getMinutes(){
        if (!daysTxt.acceptableInput || !hoursTxt.acceptableInput || !minutesTxt.acceptableInput) return -1;
        return parseInt(daysTxt.text) * 1440 + parseInt(hoursTxt.text) * 60 + parseInt(minutesTxt.text);
    }
    
    function setMinutes(minutes){
        var days = Math.floor(minutes / 1440);
        minutes -= days * 1440;
        var hours = Math.floor(minutes / 60);
        minutes -= hours * 60;
        daysTxt.text = days;
        hoursTxt.text = hours;
        minutesTxt.text = minutes;
    }
}
