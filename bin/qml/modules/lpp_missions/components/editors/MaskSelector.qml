import QtQuick 2.6
import QtQuick.Controls 1.4
import QtQuick.Layouts 1.3
import lpp 1.0
import QtQuick.Dialogs 1.2

import modules.lpp_utils 1.0
import ".."
    
    
ColumnLayout {
    property Instance instance;
    
    function loadFromInstance(_instance){
        instance = _instance;
        
        txt.editor.text = instance.getMask();
    }
    
    function saveToInstance(){
        if (!instance.setMask(txt.editor.text)) {
            mainWindow.showError(qsTr("Error"), qsTr("Invalid cancellation data."));
            return false;
        }
        
        return true;
    }
    
    Label {
        Layout.fillWidth: true
        Layout.minimumWidth: 50
        Layout.maximumWidth: 65536
        text: qsTr("All occurrences that start within the ranges below will be cancelled.\nAcceptable Formats (Separate Each by Line):\nYYYY/MM/DD    or    YYYY/MM/DD - YYYY/MM/DD.")
        horizontalAlignment: Text.AlignHCenter
    }
    
    TextEditor {
        id: txt
        Layout.fillWidth: true
        Layout.fillHeight: true
        Layout.minimumHeight: 50
        Layout.maximumHeight: 65536
        Layout.minimumWidth: 50
        Layout.maximumWidth: 65536
    }
}
