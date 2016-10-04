#include <QApplication>
#include <QQmlApplicationEngine>
#include <QQmlContext>
#include <QtGui>
#include <QString>
#include "lpp/Engine.h"
#include "lpp/Action.h"
#include "lpp/utils/Types.h"
//#include "lpp/GlobalVars.h"

/*

  #TBA:

Use QTabWidget to make multi tab window.

using tab view:
add a tab by right clicking on tab view. need to link to a qml file.

when things don't fucking work for no fucking reason:
    delete the makefiles in release bin folder, and also the o and cpp file in bin folder if:
        add, modified, renamed, or removed resources caused problem or not updated correctly. also manually update project.pro if necessary
        macro related problems (make-no-fucking-sense errors)
    to make layout resize work correctly, all minimum and maximum size must be specified even if they are 0 or 65536:
        also, children width and height should also be explicitly set.
    to make groupbox item anchor, a width and height must be given.
        same goes for application window. 
        setting min max width height DOES NOT count as setting width and height.
    MouseArea will prevent lower MouseAreas from receiving event
    Keys.onReturnPressed is main enter, Keys.onEnterPressed is keypad enter
    QObject derived class cannot be copied by value (no copy constructor or =operator)
    if a c++ class A has Q_PROPERTY with some other class B pointer as type, must include B header in A header.
        the same goes if A has a Q_INVOKABLE method taking B pointer as parameter.
    when a c++ QObject is created without parent, or not explicitly set ownership to c++, 
        if this object is returned in a method to QML, it MAY be transferred to QML ownership and get garbage collected.
        to solve this problem, write "QQmlEngine::setObjectOwnership(object, QQmlEngine::CppOwnership);" when object is created.
    sort compare function cannot take non-static function (member functions)
    a const pointer / reference cannot have its methods called, since that might change the content.
    If you are using multiple inheritance, moc assumes that the first inherited class is a subclass of QObject. 
        Also, be sure that only the first inherited class is a QObject.

to deploy qt quick:
    cd navigate to Qt\5.6\mingw49_32\bin, run windeployqt.exe --qmldir [path to source qml files] [binary exe path]
    copy some missing dlls from Qt\Tools\mingw492_32\bin
    delete some extra [resources files, make files, generated files, debug folder] in directory


tr() gives translated string. for use with diff languages. qsTr() in qml. click on the "tr" button in designer.
    example of arguments: text: qsTr("File %1 of %2").arg(counter).arg(total)
use anchors.fill = parent, for most class definition
use states and transitions for a qml object
the "enabled" property of any object can be used to make an item unusable
simply set both "visible" and "enabled" true and false to toggle loaded objects
use timer for game loop.
use window.alert to flash taskbar
normal closing (by title bar or taskbar) can be intercepted and rejected in onClosing handler by setting param "close"'s close.accepted to false
other event handler also have accepted parameter.
making transparent: http://stackoverflow.com/questions/7613125/how-to-make-a-transparent-window-with-qt-quick
Component.onCompleted: handler that calls when all property of component are initialized. this function is not overloaded if bound again in subclass: both base class and subclass method will be called
a instance of class "Connections", set property "target", then it will be able to receive any event of target
dynamic object creation:
    component = Qt.createComponent("TestSprite.qml"); OR, define a Component{} object, set its id: component, make 1 child item to be TestSprite{}.
    sprite = component.createObject(mainWindow, {x: 0, y: 0});
let subwindow block input to parent window: set modality property using Qt.WindowModal flag or Qt.ApplicationModal(block everything else)
set clipping of an object to mask all children to bounding rect
use Canvas type for rendertexture
use MouseArea drag API for dragging
setting an application window visibility is similar to closing and opening. close() is the same as visible = false, except the animation is played correctly.
item.grabToImage to get screenshot
set width and height = parent width and height for similar effect as anchors.fill: parent, but with more flexibilities ex. translation transitions.
set minimum and maximum width and height on window to control/disable resizing
there are color dialog and font dialog and file dialog in QtQuick.Dialogs
convention: unless in getter setter, do not use m_prop. use the getter and setter.
specify truncate when opening a file for writing will delete old content and overwrite new one.
QString mid function is equivalent to substring. that class can also replace, split etc. useful.
using QDateTime:
    setting timeSpec to UTC will keep ymdhms, and no longer account for DST. 
    both qt and javascript does not count leap seconds. 
    javascript month is 0 based while qt is 1 based.
    QDateTime addMonths or year will clamp to current month or year if date does not exist, such as from 3/31 to 4/30
set anchors.fill to undefined to release anchor and prevent item from receiving resize events.
use validator mask and input mask of textfield etc.
set tooltip on buttons
cpp QObject can dynamically get/set property by name string (even dynamic ones). also able to get property name list (static: via QObject's metaobject, dynamic: via QObject's get dynamic property method etc)
use .destroy() to kill qml object.

see main.cpp for example for c++ qml communication
    c++ accessing qml:
        to find child object, make a objectName proeprty in qml, then use findChild in c++
    qml accessing c++:
        http://doc.qt.io/qt-5/qtqml-cppintegration-exposecppattributes.html
        http://doc.qt.io/qt-5/qtqml-cppintegration-definetypes.html
        a class must be marked in Qt meta system.
            make this class be derived from QObject class.
                also add Q_OBJECT macro right on first line of class declaration block (even if this class is not *directly* inheriting QObject).
            create qt property (see example). (this does not generate member variable. to do that, specify MEMBER flag.)
                to make a object type property, use object pointer as type. that class must be registered first (see below), and header included.
                    also, that class's header must be included in current class header (not forward declaration)
                a nullptr will be null in qml
                remember to emit signal in the setter function after changing the m_property
            mark methods by adding Q_INVOKABLE prefix
                to return a object pointer, use QObject* as return type
                if the returned object has not been set ownership to cpp, qml will take over.
                if parameter is a registered qml class, must include header.
        registering:
            to make the class into a static global, do:
                put in main: engine.rootContext()->setContextProperty("Object", &object);
                in qml, access like static object: Object.prop...
            to make the class into a instantiable object, do:
                put in main: qmlRegisterType<Action> ("namespace", 1, 0, "Object");
                in qml, import namespace, then use Object like normal.
            to register a typedef, do:
                qRegisterMetaType<Int>("Int");
        

QML concepts:
    OOP structure: each file define a class of same name as file. in file, the first and only root obj is the extended super class, not a child.
    import a folder to use all qml files inside. syntax: import "[relative path]". qml file under same directory is auto imported. "../" for parent folder.
    import a package by its package name just like flash, but need a version number after it.
    make custom package:
        #tba, qmldir file, addImportPath etc
        to make some qml file available as package, say, "com.sucker" with some modules like Foo.qml, Bar.qml, crap/Lol.js inside: 
        find a folder that the application knows
        add this folder into import path (qmlengine.addImportPath(...))
        in this folder, make com/sucker directory
        in com/sucker, add a file named "qmldir", write:
            module com.sucker
            Foo 1.0 Foo.qml
            Bar 1.0 Bar.qml
            Lol 1.0 crap/Lol.js
        see http://doc.qt.io/qt-5/qtqml-modules-qmldir.html for other info
        now in any other qml file of this app, write: import com.sucker 1.0, then use Foo Bar and Lol.
    "this" refers to current instance / class (closest component scope)
    declaring object instance using "[ObjType] {properties}"
    QtObject is the most basic class. inherit this one for abstract class (non-visual). Item is the most basic visual class.
    id are private property (of current component scope, meaning can be accessed if obj is defined under same scope) that are reference to obj, while property are public
    object declared on the bottom will be drawn later (on top)
    signals are event on obj, defined as: signal [name]([handler params(syntax: [type] [name])]).
        catch property change with on[Property]Changed. catch signal with on[Signal]
        to dispatch event, call signal as their own name
        write signal.connect(func) in Component.onCompleted to add additional listener/handler of signal. 
        use disconnect for remove listener. by using connect(signal), signal will be dispatched as handler
    set behaviour on property for smooth animation. ([modifier] on [property] {}, ex Behavior on groupBox1.opacity {NumberAnimation{duration: 150; easing.type: Easing.InOutExpo}}
    An object can be referred to by its id from anywhere within the component scope in which it is declared. Therefore, an id value must always be unique within its component scope, or simply, within one qml file.
    any property or method of class / instance can be reset
    creating property syntax: "[flag] property [type] [name]: value". ": value" can be omitted. 
        use "readonly" as flag to make const.
        use "var" as any type, including list of primitive types.
        can also use Class type, like Rectangle. 
        type list<T> works as vector (only store obj. if want to store other thing, use var type), use [Obj1, Obj2, Obj3] to assign value.
        use "alias" as reference type, assign id or property of obj. use this to make private obj public.
    creating method: "function [name]([params(syntax: [name])])", all params untyped (type "var")
    {} blocks can be omitted if everything is inlined with ";"
    setting value of created property / function: simply "property: value". setting function can omit the "function(param)" part, and param will be auto created.
    declaring (most) object without assigning to property will actually append into "data" array property (default) which is a children array.
    can assign func (DO NOT put "function(){}". just put "{}") that return matching type to bind a property, which will constantly update if anything in func is changed. the "{return ...}" can be simplified to ...
        to do that from an actual js func, use e.x. "height = Qt.binding(function() { return width * 3 })"
    attached properties: when an object is under some special context (eg. child of layout), some extra properties are attached to the object under some specific name:
        for example, child of layout have an Layout object as property, which contains other properties such as Layout.fillWidth.
        to access these property outside of object, call it as if they are actual property of object, ex. object.Layout.fillWidth.
    instance can have context-specific properties (e.x. Component.onComplete or ListView.isCurrentItem) that are made when this instance is child of some specific item. This is made from c++.
    The UI designer can modify a qml file. usually make a XXXForm.ui.qml for that, then a XXX.qml extending that class. to export public alias property, click on the shitty box icon in the item list in designer.


write javascript for UI-side logics. 
    http://doc.qt.io/qt-5/qtqml-javascript-topic.html
    http://doc.qt.io/qt-5/qtqml-javascript-dynamicobjectcreation.html
    http://doc.qt.io/qt-5/qtqml-javascript-imports.html
use C++ for application logic.
    http://doc.qt.io/qt-5/qtqml-cppintegration-interactqmlfromcpp.html
    http://doc.qt.io/qt-5/qtqml-cppintegration-topic.html


http://doc.qt.io/qt-5/windows-deployment.html    use windows / mac deployment tool, then copy from compiler
http://doc.qt.io/qtcreator/creator-writing-program.html
http://doc.qt.io/qt-5/qtabwidget.html#details
http://doc.qt.io/qt-5/gettingstartedqt.html
http://doc.qt.io/qt-5/qtgui-openglwindow-example.html
http://doc.qt.io/qt-5/examples-widgets-opengl.html
http://doc.qt.io/qt-5/i18n-source-translation.html
http://doc.qt.io/qt-5/stylesheet-examples.html

http://doc.qt.io/qt-5/qtexamplesandtutorials.html

http://doc.qt.io/qt-5/ios-support.html

http://doc.qt.io/qt-5/deployment.html
http://doc.qt.io/qt-5/androidgs.html - reinstall qt w/ android package
http://doc.qt.io/qt-5/gettingstarted.html
http://doc.qt.io/qt-5/overviews-main.html
http://doc.qt.io/qt-5/qtexamplesandtutorials.html
http://doc.qt.io/qt-5/animation-overview.html
http://doc.qt.io/qt-5/qtqml-cppintegration-topic.html - maybe write ui in qt quick and framework in c++
http://doc.qt.io/qt-5/index.html
http://doc.qt.io/qt-5/qml-tutorial.html

http://doc.qt.io/qt-5/qtquickcontrolsstyles-index.html
http://doc.qt.io/qt-5/qtquick-scenegraph-openglunderqml-example.html

http://doc.qt.io/qt-5/qtquick-statesanimations-animations.html
http://doc.qt.io/qt-5/qtwinextras-overview.html

http://doc.qt.io/qt-5/qtqml-syntax-propertybinding.html － describe how to pass by reference / value

http://doc.qt.io/qtcreator/creator-quick-ui-forms.html
http://doc.qt.io/qt-5/qtqml-javascript-dynamicobjectcreation.html
http://doc.qt.io/qt-5/qtqml-index.html
http://doc.qt.io/qtcreator/quick-screens.html
http://doc.qt.io/qtcreator/index.html
http://doc.qt.io/qt-5/qmlreference.html

http://doc.qt.io/qt-5/gettingstartedqml.html

http://doc.qt.io/qt-5/qtquickcontrolsstyles-index.html
http://doc.qt.io/qt-5/qtquick-statesanimations-states.html

http://doc.qt.io/qt-5/qtquick-internationalization.html

http://doc.qt.io/qt-5/qtquick-performance.html

http://doc.qt.io/qt-5/qtquickcontrols-index.html
http://doc.qt.io/qt-5/qtquickcontrols2-index.html

http://doc.qt.io/qt-5/qtquickcontrols2-differences.html

http://doc.qt.io/qt-5/qtquick-performance.html
 
*/

class ApplicationEngine : public QQmlApplicationEngine
{
    
};

int main(int argc, char *argv[])
{
    QApplication app(argc, argv);

    ApplicationEngine engine;
    LPP::registerQtTypes();
    LPP::registerQtClasses();
    LPP::Engine _engine;
    
    _engine.initialize(app, engine);

    return app.exec();
}
