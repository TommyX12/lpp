import QtQuick 2.0

Rectangle {
    
    property real progress1: 0
    property real progress2: 0
    
    property alias color1: bar1.color
    property color color2: bar2.color
    
    color: "#CCCCCC"
    
    height: 5
    width: 100
    
    Rectangle{
        id: bar1
        height: parent.height
        width: parent.width * progress1
        color: "#6699EE"
    }
    
    Rectangle{
        id: bar2
        height: parent.height
        width: parent.width * progress2
        color: "#33DD44"
    }
    
}
