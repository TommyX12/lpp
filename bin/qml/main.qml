import QtQuick 2.6
import QtQuick.Controls 1.4
import QtQuick.Controls.Styles 1.4
import QtQuick.Dialogs 1.2
import QtQuick.Layouts 1.1
import "moduleList.js" as ModuleList
import "modules/lpp_missions"
import lpp 1.0
import modules.lpp_utils 1.0

ApplicationWindow {
    
    readonly property real innerMargin: 10
    
    property alias progressBar: progressBar
    property alias status: status;
    
    property alias messageBox_error: messageBox_error;
    
    property var modules;
    
    signal moduleChange(var event);
    signal allModulesLoaded();
    
    signal onReturnPressed();
    signal onEscapePressed();
    
    id: mainWindow 
    visible: true
    //flags: Qt.FramelessWindowHint | Qt.Window
    flags: Qt.Window | Qt.WindowTitleHint | Qt.WindowCloseButtonHint | Qt.WindowMinMaxButtonsHint | Qt.WindowSystemMenuHint
    width: 1024
    height: 768
    minimumWidth: 1024
    minimumHeight: 768
    color: "#FFFFFF" 
    title: qsTr("Life++")
    
    MouseArea {
        id: backMouseArea
        property int curX: 0;
        property int curY: 0;
        anchors.fill: parent
        hoverEnabled: true
        onPressed: function (event){
            curX = event.x;
            curY = event.y;
        }
        onPositionChanged: function (event){
            if (pressed && mainWindow.visibility == 2){ //visiblility 2 is windowed
                mainWindow.x += event.x - curX;
                mainWindow.y += event.y - curY;
            }
        }
    }
    
    Item {
        anchors.fill: parent
        
        focus: true
        
        Keys.onReturnPressed: {
            mainWindow.onReturnPressed();
        }
        
        Keys.onEscapePressed: {
            mainWindow.onEscapePressed();
        }
    
        Rectangle {
            id: background
            anchors.fill: parent
            color: "#ffffff"
        }
        
        ColumnLayout {
            anchors.fill:parent
            anchors.rightMargin: innerMargin
            anchors.leftMargin: innerMargin
            anchors.bottomMargin: innerMargin
            anchors.topMargin: innerMargin
            
            Rectangle {
                Layout.fillWidth: true
                height: 36;
                color: "#ffffff"
                border.color: "#aaaaaa"
                border.width: 1
                RowLayout {
                    
                    id: tabBar
                    spacing: 10
                    anchors.top: parent.top
                    anchors.topMargin: 5
                    anchors.bottom: parent.bottom
                    anchors.bottomMargin: 5
                    
                    x: 5
                    
                }
            }
            
            PageView {
                id: mainContainer
                Layout.fillHeight: true
                Layout.fillWidth: true
            }
        }
        
    }
    
    Component {
        id: tabBarButton
        
        SimpleButton {
            property var currentModule: null;
            property var selectedColor: "#e0e8ff"
            property var normalColor: "#eeeeee"
            width: label.contentWidth + 32
            buttonColor: currentModule.visible ? selectedColor : normalColor;
            idleBorderWidth: 2
            hoverBorderWidth: 2
            onClicked: {
                var event = {accepted: true};
                mainWindow.moduleChange(event);
                if (event.accepted) {
                    mainContainer.show(currentModule);
                    currentModule.enter();
                }
            }
        }
    }
    
    MessageDialog {
        id: messageBox_error
        title: ""
        text: ""
        icon: StandardIcon.Critical
        standardButtons: StandardButton.OK;
    }
    
    function showError(title, text){
        messageBox_error.title = title;
        messageBox_error.text = text;
        messageBox_error.open();
    }
    
    Component.onCompleted: function (){
        modules = {};
        
        for (var i = 0; i < ModuleList.list.length; i++){
            var moduleName = ModuleList.list[i];
            
            var component = Qt.createComponent("modules/" + moduleName);
            
            var item = component.createObject(mainContainer);
            item.visible = item.enabled = false;
            item.anchors.fill = undefined;
            
            modules[moduleName] = item
            
            var button = tabBarButton.createObject(tabBar, {currentModule:item, text: item.title});
            button.Layout.fillHeight = true;
            button.Layout.alignment = Qt.AlignCenter
            
            console.log("loading module: " + moduleName)
        }
        
        allModulesLoaded();
        
        showModule(ModuleList.list[0]);
        
        /*
        Engine.createPlan().test = 2
        Engine.createPlan().test = 4
        Engine.createPlan().test = 6
        var thing = Engine.getPlanByID(2)
        console.log(thing.test);
        
        console.log(Engine.timeOrigin);
        */
        
        console.log("standing by.")
    }
    
    function getModule(name){
        return modules[name];
    }
    
    function showModule(name){
        mainContainer.show(modules[name]);
        modules[name].enter();
    }
    
    function showModuleDirect(module){
        mainContainer.show(module);
        module.enter();
    }
    
    menuBar: MenuBar {       
        Menu {
            title: qsTr("Options")
            MenuItem {    
                text: qsTr("Save")
                onTriggered: Engine.save();
            } 
            MenuItem {
                text: qsTr("Save and Quit")
                onTriggered: mainWindow.close();
            }
        }
    }
    
    statusBar: StatusBar {
        Label {
            id: status
            text: qsTr("standing by.")
        }

        ProgressBar {
            id: progressBar
            anchors.top: parent.top
            anchors.bottom: parent.bottom
            anchors.left: parent.horizontalCenter
            anchors.right: parent.right
            value: 0.0
        }
    }
    
    onClosing: function (event){
        Engine.save();
        console.log("application closed.")
        //event.accepted = false;
    }
     
    
    Timer {
        id: timer
        interval: 1000
        repeat: true
        running: true
        
        onTriggered:{ 
            //mainWindow.alert(0);
            enterSecond();
        }
    }
    
    signal enterSecond;
    
    MessageDialog {
        id: messageDialog
        icon: StandardIcon.Information
        standardButtons: StandardButton.Ok
        text: qsTr("Open Action Triggered.")
        title: qsTr("Notification")
    }
}
