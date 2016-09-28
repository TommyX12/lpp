import QtQuick 2.6
import QtQuick.Controls 1.4

Item{
    property alias editor: textArea
    
    TextArea {
        property int tabSize: 6;
        property string tabChar: ' ';
        id: textArea
        text: ""
        tabChangesFocus: false
        readOnly: false
        font.pointSize: 10
        visible: true
        highlightOnFocus: true
        anchors.fill: parent
        Keys.onPressed: function(event){
            if (event.key == Qt.Key_Backspace){
                if (textArea.selectionStart == textArea.selectionEnd){
                    var str = textArea.text;
                    var ptr = textArea.cursorPosition;
                    if (ptr >= tabSize){
                        var found = false;
                        for (var i = 1; i <= tabSize; i++){
                            if (str.charAt(ptr - i) != tabChar){
                                found = true;
                                break;
                            }
                        }
                        if (!found){
                            textArea.remove(ptr - tabSize, ptr);
                            event.accepted = true;
                        }
                    }
                }
            }
            else if (event.key == Qt.Key_Tab){
                var word = "";
                for (var i = 0; i < tabSize; i++){
                    word += tabChar;
                }
                textArea.insert(textArea.cursorPosition, word);
                event.accepted = true;
            }
            else if (event.key == Qt.Key_Backtab){
                event.accepted = true;
            }
            else if (event.key == Qt.Key_Return){
                if (textArea.selectionStart != textArea.selectionEnd){
                    textArea.remove(textArea.selectionStart, textArea.selectionEnd);
                }
                var str = textArea.text;
                var ptr = textArea.cursorPosition;
                ptr = str.lastIndexOf("\n", ptr-1);
                ptr++;
                var word = "";
                while (str.charAt(ptr) == tabChar) {
                    word += tabChar
                    ptr++;
                }
                if (str.charAt(textArea.cursorPosition - 1) == ':'){
                    for (var i = 0; i < tabSize; i++){
                        word += tabChar;
                    }
                }
                textArea.insert(textArea.cursorPosition, "\n")
                textArea.insert(textArea.cursorPosition, word);
                event.accepted = true;
            }
        }
    }
}
