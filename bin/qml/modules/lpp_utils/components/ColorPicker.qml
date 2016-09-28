import QtQuick 2.0
import QtQuick.Layouts 1.1
import QtQuick.Controls 1.4

import modules.lpp_utils 1.0

ApplicationWindow {
    id: subWindow
    property color currentColor: "black";
    property real internalMargin: 10;
    property int hslPrecision: 3;
    property var handlerFunction: null;
    
    visible: false
    minimumWidth: 550
    minimumHeight: 500
    title: qsTr("Select Color")
    flags: Qt.Dialog
    modality: Qt.WindowModal
    maximumHeight: minimumHeight
    maximumWidth: minimumWidth
    
    function load(color){
        currentColor = color;
        updateRGB();
        updateHSL();
    }
    
    function updateRGB(){
        sliderR.value = currentColor.r;
        sliderG.value = currentColor.g;
        sliderB.value = currentColor.b;
    }
    
    function updateHSL(){
        var hsl = Utils.hsl(currentColor.r, currentColor.g, currentColor.b)
        sliderH.value = hsl.h;
        sliderS.value = hsl.s;
        sliderL.value = hsl.l;
    }
    
    function colorFromRGB() {
        currentColor.r = sliderR.value
        currentColor.g = sliderG.value
        currentColor.b = sliderB.value
    }
    
    function colorFromHSL(){
        currentColor = Qt.hsla(sliderH.value, sliderS.value, sliderL.value, 1.0);
    }

    
    RowLayout {
        anchors.fill: parent
        anchors.bottomMargin: internalMargin
        anchors.topMargin: internalMargin
        anchors.leftMargin: internalMargin
        anchors.rightMargin: internalMargin
        
        ColumnLayout {
            Layout.fillWidth: true
            Layout.fillHeight: true
            
            GroupBox {
                Layout.fillWidth: true;
                Layout.fillHeight: true
                Layout.minimumHeight: 10
                title: qsTr("Preset Colors")
                Item{
                    anchors.fill: parent
                    property int columns: 8
                    property real columnSpacing: 10
                    property int rows: 2
                    property real rowSpacing: 10
                    
                    property var presetColors: ["#ff4444", "darkred", "green", "lightgreen", "#4466ff", "lightblue", "grey", "lightgrey", "orange", "purple", "#44ffff", "steelblue", "pink", "aquamarine", "gold", "silver"];
                    
                    Component.onCompleted: {
                        var i, child;
                        
                        for (i = 0; i < data.length; i++){
                            child = data[i];
                            
                            child.buttonColor = presetColors[i];
                            child.clicked.connect(function(button){
                                currentColor = button.buttonColor;
                                updateRGB();
                                updateHSL();
                            })
                        }
                    }
                    
                    function resize(){
                        var i, j, k = 0, child;
                        
                        var tileWidth = width / columns;
                        var tileHeight = height / rows;
                        
                        for (i = 0; i < rows; i++){
                            for (j = 0; j < columns; j++){
                                child = data[k];
                                child.width = tileWidth - columnSpacing;
                                child.height = tileHeight - rowSpacing;
                                
                                child.x = j * tileWidth + columnSpacing / 2;
                                child.y = i * tileHeight + rowSpacing / 2;
                                
                                k++;
                            }
                        }
                    }
                    
                    onWidthChanged: resize();
                    onHeightChanged: resize();
                    
                    SimpleButton {}
                    SimpleButton {}
                    SimpleButton {}
                    SimpleButton {}
                    SimpleButton {}
                    SimpleButton {}
                    SimpleButton {}
                    SimpleButton {}
                    SimpleButton {}
                    SimpleButton {}
                    SimpleButton {}
                    SimpleButton {}
                    SimpleButton {}
                    SimpleButton {}
                    SimpleButton {}
                    SimpleButton {}
                }
            }
            
            GroupBox {
                Layout.fillWidth: true;
                Layout.minimumHeight: 130
                Layout.maximumHeight: 130;
                title: qsTr("Random Colors")
                ColumnLayout {
                    anchors.fill: parent
                    
                    Button {
                        Layout.fillWidth: true;
                        text: qsTr("Refresh")
                        onClicked: {
                            randColorContainer.regen();
                        }
                    }

                    Item{
                        id: randColorContainer
                        
                        property int columns: 8
                        property real columnSpacing: 10
                        property int rows: 2
                        property real rowSpacing: 10
                        
                        Layout.fillHeight: true
                        Layout.fillWidth: true
                        
                        function regen(){
                            var i;
                            for (i = 0; i < data.length; i++){
                                data[i].buttonColor = Qt.rgba(Math.random(), Math.random(), Math.random(), 1.0);
                            }
                        }
                        
                        Component.onCompleted: {
                            var i, child;
                            
                            for (i = 0; i < data.length; i++){
                                child = data[i];
                                
                                child.clicked.connect(function(button){
                                    currentColor = button.buttonColor;
                                    updateRGB();
                                    updateHSL();
                                })
                            }
                            
                            regen();
                        }
                        
                        function resize(){
                            var i, j, k = 0, child;
                            
                            var tileWidth = width / columns;
                            var tileHeight = height / rows;
                            
                            for (i = 0; i < rows; i++){
                                for (j = 0; j < columns; j++){
                                    child = data[k];
                                    child.width = tileWidth - columnSpacing;
                                    child.height = tileHeight - rowSpacing;
                                    
                                    child.x = j * tileWidth + columnSpacing / 2;
                                    child.y = i * tileHeight + rowSpacing / 2;
                                    
                                    k++;
                                }
                            }
                        }
                        
                        onWidthChanged: resize();
                        onHeightChanged: resize();
                        
                        SimpleButton {}
                        SimpleButton {}
                        SimpleButton {}
                        SimpleButton {}
                        SimpleButton {}
                        SimpleButton {}
                        SimpleButton {}
                        SimpleButton {}
                        SimpleButton {}
                        SimpleButton {}
                        SimpleButton {}
                        SimpleButton {}
                        SimpleButton {}
                        SimpleButton {}
                        SimpleButton {}
                        SimpleButton {}
                    }
                }
            }
            
            GroupBox {
                Layout.fillWidth: true;
                title: qsTr("RGB")
                GridLayout{
                    anchors.fill: parent
                    layoutDirection: Qt.LeftToRight
                    columnSpacing: 10
                    rows: 3
                    flow: GridLayout.LeftToRight
                    columns: 3
                    rowSpacing: 10
                    
                    Label {
                        text: qsTr("Red:")
                    }
                    Slider {
                        id: sliderR
                        Layout.fillWidth: true
                        onValueChanged: {
                            if (pressed){
                                colorFromRGB();
                                updateHSL();
                            }
                        }
                    }
                    Label {
                        text: (sliderR.value * 255).toFixed(0)
                    }
                    Label {
                        text: qsTr("Green:")
                    }
                    Slider {
                        id: sliderG
                        Layout.fillWidth: true
                        onValueChanged: {
                            if (pressed){
                                colorFromRGB();
                                updateHSL();
                            }
                        }
                    }
                    Label {
                        text: (sliderG.value * 255).toFixed(0)
                    }
                    Label {
                        text: qsTr("Blue:")
                    }
                    Slider {
                        id: sliderB
                        Layout.fillWidth: true
                        onValueChanged: {
                            if (pressed){
                                colorFromRGB();
                                updateHSL();
                            }
                        }
                    }
                    Label {
                        text: (sliderB.value * 255).toFixed(0)
                    }
                }
            }
            
            GroupBox {
                Layout.fillWidth: true;
                title: qsTr("HSL")
                GridLayout{
                    anchors.fill: parent
                    layoutDirection: Qt.LeftToRight
                    columnSpacing: 10
                    rows: 3
                    flow: GridLayout.LeftToRight
                    columns: 3
                    rowSpacing: 10
                    
                    Label {
                        text: qsTr("Hue:")
                    }
                    Slider {
                        id: sliderH
                        Layout.fillWidth: true
                        onValueChanged: {
                            if (pressed){
                                colorFromHSL();
                                updateRGB();
                            }
                        }
                    }
                    Label {
                        text: sliderH.value.toFixed(hslPrecision)
                    }
                    Label {
                        text: qsTr("Saturation:")
                    }
                    Slider {
                        id: sliderS
                        Layout.fillWidth: true
                        onValueChanged: {
                            if (pressed){
                                colorFromHSL();
                                updateRGB();
                            }
                        }
                    }
                    Label {
                        text: sliderS.value.toFixed(hslPrecision)
                    }
                    Label {
                        text: qsTr("Lightness:")
                    }
                    Slider {
                        id: sliderL
                        Layout.fillWidth: true
                        onValueChanged: {
                            if (pressed){
                                colorFromHSL();
                                updateRGB();
                            }
                        }
                    }
                    Label {
                        text: sliderL.value.toFixed(hslPrecision)
                    }
                }
            }
        }
        
        ColumnLayout {
            Layout.minimumWidth: 100;
            Layout.maximumWidth: Layout.minimumWidth
            Layout.fillHeight: true
            
            GroupBox {
                title: qsTr("Current Color")
                Layout.fillHeight: true
                Layout.fillWidth: true
                Rectangle {
                    color: currentColor
                    anchors.fill: parent
                    //Behavior on color {ColorAnimation{duration: 60; easing.type: Easing.Linear}}
                }
            }
            
            Button {
                Layout.fillWidth: true
                text: qsTr("Select")
                onClicked: {
                    if (handlerFunction != null){
                        handlerFunction(currentColor);
                        handlerFunction = null;
                    }

                    subWindow.close();
                }
            }
            
            Button {
                Layout.fillWidth: true
                text: qsTr("Discard")
                onClicked: {
                    subWindow.close();
                }
            }
        }
    }
    
    onClosing: function (close){
        //close.accepted = false;
    }
}
