import QtQuick 2.0
import QtQuick.Controls 1.0
import QtQuick.Layouts 1.1
import QtQuick.Dialogs 1.2

import modules.lpp_utils 1.0
import modules.lpp_missions 1.0

Item {
    id: timeline
    anchors.fill: parent
    
    clip: true
    
    property real labelMargin: 2;
    property real leftMargin: 50;
    property real sideLineHSpace: 3;
    property real sideLineWidth: 2;
    property real rightMargin: 25;
    property real blockX: leftMargin + sideLineWidth + sideLineHSpace;
    property real hideDistance: 15;
    
    readonly property real dayLength: 86400000;
    readonly property real hourLength: 3600000;
    readonly property real minuteLength: 60000;
    
    property real maxViewRadius: dayLength * 2;
    property real marginBias: hourLength;
    property real loadedRadius: 8 * dayLength / 2;
    property real moveSpeedMul: 1;
    property real zoomSpeedMul: 4;
    
    property real maxSessionLength: dayLength / 2;
    
    property real lastDrawnTime;
    
    property real topTime;
    property real bottomTime;
    
    property real cameraTime;
    //property real cameraTimeDest;
    property real cameraZoom;
    //property real cameraZoomDest;
    property real cameraZoomDefault: 4;
    property real cameraZoomMin: 1;
    property real cameraZoomMax: 32;
    
    property real loadedRangeBegin: -1;
    property real loadedRangeEnd: -1;
    
    property real cameraLockRadius: hourLength;
    property real cameraLockBias;
    
    property var blockPool: [];
    property int numBlocks: 0;
    
    property var labelPool: [];
    property int numLabels: 0;
    
    property real animator: 0;
    
    property bool focusing: false;
    
    property var activeAction: null;
    
    property bool editing: false;
    property real editBegin;
    property real editEnd;
    property real oldBegin;
    property real oldEnd;
    property var editingAction: null;
    property bool editingAuto: false;
    
    property int editType: 0;
    
    property alias finder: finder;
    
    property bool snapNow: snapNowBox.checked
    property bool snapMarker: snapMarkerBox.checked
    property bool snapTime: snapTimeBox.checked
    property real snapNowRange: minuteLength * 60 / cameraZoom;
    property real snapMarkerRange: minuteLength * 80 / cameraZoom;
    property real snapTimeRange: minuteLength * 40 / cameraZoom;
    property real snapTimeInterval: minuteLength * 15;
    
    property real wheelStep: minuteLength * 6 / cameraZoom
    
    property var timeFrameLimit: dayLength * 3650; 
    
    property bool activeDrawEnabled: false;
    
    signal timelineEdited;
    signal timeChanged;
    
    property int planningDays: 0;
    
    Behavior on animator {
        id: animatorEase
        NumberAnimation{duration: 220; easing.type: Easing.Linear}
    }
    Behavior on topTime {
        id: cameraTimeEase
        NumberAnimation{duration: 200; easing.type: Easing.OutQuad}
    }
    Behavior on bottomTime {
        id: cameraZoomEase
        NumberAnimation{duration: 200; easing.type: Easing.OutQuad}
    }
    
    Component {
        id: block_comp
        SessionBlock {
            
        }
    }
    
    Component {
        id: editBlock_comp
        SessionBlock {
            visible: editing;
        }
    }
    
    Component {
        id: label_comp
        Label {
            property real time;
            property bool hidable;
            enabled: visible
            font.pointSize: 8
        }
    }
    
    property var editBlock;
    
    Component.onCompleted: {
        planningDays = Math.round((Engine.autoplanMax.getTime() - Engine.currentTime().getTime()) / dayLength);
        
        lastDrawnTime = limitTimePrecision(Engine.currentTime())
        
        animatorEase.enabled = false;
        cameraTimeEase.enabled = false;
        cameraZoomEase.enabled = false;
            resetCamera(true, true);
        animatorEase.enabled = Qt.binding(function(){return !topMouseArea.pressed;});
        cameraTimeEase.enabled = Qt.binding(function(){return !topMouseArea.pressed;});
        cameraZoomEase.enabled = Qt.binding(function(){return !topMouseArea.pressed;});
        
        root.enter.connect(onEnter);
        
        mainWindow.enterSecond.connect(onEnterSecond);
        
        editBlock = editBlock_comp.createObject(editBlockContainer);
        
        mainWindow.onReturnPressed.connect(onReturnPressed);
        mainWindow.onEscapePressed.connect(onEscapePressed);
    }
    
    onHeightChanged: reposition();
    
    function onEnter(){
        autoAutoPlan();
        Engine.save();
        timelineEdited();
        refresh();
        cameraControl();
    }
    
    function onEnterSecond(){
        var currentTime = limitTimePrecision(Engine.currentTime());
        if (currentTime > lastDrawnTime) {
            if (activeDrawEnabled) Engine.drawTimelineRange(activeAction, new Date(lastDrawnTime), new Date(currentTime));
            Engine.refresh();
            lastDrawnTime = currentTime;
            finishEdit();
        }
        if (Math.abs(cameraLockBias) < cameraLockRadius) {
            var timeDelta = cameraLockBias;
            setCamera(Engine.currentTime().getTime() + cameraLockBias, cameraZoom);
            cameraLockBias = timeDelta;
        }
        else cameraControl();
        timeChanged();
        //console.log(numBlocks, blockPool.length);
    }
    
    function limitTimePrecision(currentTime){
        return Date.UTC(currentTime.getUTCFullYear(), currentTime.getUTCMonth(), currentTime.getUTCDate(), currentTime.getUTCHours(), currentTime.getUTCMinutes(), 0);
        //console.log(lastDrawnTime);
    }
    
    function cameraControl(){
        cameraLockBias = cameraTime - Engine.currentTime().getTime();
        var viewRadius = maxViewRadius / cameraZoom;
        topTime = Math.max(Engine.timelineMin.getTime(), cameraTime - viewRadius);
        bottomTime = Math.min(Engine.timelineMax.getTime(), cameraTime + viewRadius);
        if (topTime < loadedRangeBegin || bottomTime > loadedRangeEnd) refresh();
        else reposition();
    }
    function setCamera(time, zoom){
        cameraTime = time;
        cameraZoom = zoom;
        startAnimation();
    }
    function moveCamera(timeDelta, zoomDelta){
        cameraTime += timeDelta;
        cameraZoom += zoomDelta;
        startAnimation();
    }
    function resetCamera(resetTime, resetZoom){
        if (resetTime) cameraTime = Engine.currentTime().getTime();
        if (resetZoom) cameraZoom = cameraZoomDefault;
        startAnimation();
    }
    
    function startAnimation(){
        cameraTime = Utils.clamp(cameraTime, Engine.timelineMin.getTime(), Engine.timelineMax.getTime());
        cameraZoom = Utils.clamp(cameraZoom, cameraZoomMin, cameraZoomMax);
        animator = animator < 0.5 ? 1.0 : 0.0;
    }
    onAnimatorChanged: {
        cameraControl();
    }
    /*
    onCameraTimeChanged: {
        cameraControl();
    }
    onCameraZoomChanged: {
        cameraControl();
    }
    */
    
    function refreshEditBlock(){
        if (editingAction == null){
            editBlock.sessionBlock.text = qsTr("(Erased)");
            editBlock.sessionBlock.buttonColor = "white";
        }
        else {
            editBlock.sessionBlock.text = editType == 2 ? qsTr("[Time Frame]") : editingAction.name;
            editBlock.sessionBlock.buttonColor = editingAction.parentFolder.color;
        }
        reposition();
    }
    onEditingActionChanged: refreshEditBlock();
    
    function autoPlan(){
        autoplanWindow.show();
        //finishEdit();
    }
    
    function startEdit(action, findAction){
        editing = true;
        editType = 0;
        
        editingAuto = false;
        
        snapNow = Qt.binding(function(){return snapNowBox.checked});
        snapMarker = Qt.binding(function(){return snapMarkerBox.checked});
        snapTime = Qt.binding(function(){return snapTimeBox.checked});
        
        editBlock.opacity = 0.0;
        editingAction = action;
        editEnd = editBegin = 0;
        refreshEditBlock();
        
        oldBegin = -1;
        
        editWindow.show();
        editWindow.begin = editWindow.end = "";
        if (findAction == true) editWindow.findAction();
    }
    /*
    function dateToString(date){
        return date.getUTCFullYear() + "-" + (date.getUTCMonth()+1) + "-" + date.getUTCDate() + " " + date.getUTCHours() + ":" + date.getUTCMinutes();
    }
    */
    function saveEdit(overLengthConfirmed){
        var editBeginTime = intvSelector.getBeginTime();
        var editEndTime = intvSelector.getEndTime();
        
        if (overLengthConfirmed != true && Math.abs(editBeginTime - editEndTime) > maxSessionLength) {
            messageBox_overLength.show(saveEdit);
            return;
        }
        
        var editBeginDate = new Date(Math.min(editBeginTime, editEndTime));
        var editEndDate = new Date(Math.max(editBeginTime, editEndTime));
        if (isNaN(editBeginDate.getTime()) || isNaN(editEndDate.getTime())){
            mainWindow.showError(qsTr("Error"), qsTr("Invalid session."));
            return;
        }
        
        editing = false;
        
        if (editBlock.opacity != 0.0) {
            if (oldBegin != -1) Engine.drawTimelineRange(null, new Date(oldBegin), new Date(oldEnd));
            Engine.drawTimelineRange(editingAction, editBeginDate, editEndDate);
        }
        finishEdit();
        
        editWindow.close();
    }
    function discardEdit(){
        editing = false;
        editWindow.close();
    }
    
    function startNewPlan(){
        finder.show(false, true, false, startNewPlanEdit, qsTr("Select Required Action"));
    }
    function startNewPlanEdit(item){
        if (item != null){
            editing = true;
            editType = 2;
            
            snapNow = false;
            snapMarker = false;
            snapTime = true;
            
            editBlock.opacity = 0.0;
            editingAction = item;
            editEnd = editBegin = 0;
            refreshEditBlock();
            
            planWindow.show();
            planWindow.begin = planWindow.end = "";
        }
    }

    /*
    function dateToString(date){
        return date.getUTCFullYear() + "-" + (date.getUTCMonth()+1) + "-" + date.getUTCDate() + " " + date.getUTCHours() + ":" + date.getUTCMinutes();
    }
    */
    function saveNewPlan(){
        
        //check for shit
        var editBeginTime = pintvSelector.getBeginTime();
        var editEndTime = pintvSelector.getEndTime();
        
        if (Math.abs(editBeginTime - editEndTime) > timeFrameLimit) {
            mainWindow.showError(qsTr("Error"), qsTr("Time frame size limit exceeded."));
            return;
        }
        
        var editBeginDate = new Date(Math.min(editBeginTime, editEndTime));
        var editEndDate = new Date(Math.max(editBeginTime, editEndTime));
        if (isNaN(editBeginDate.getTime()) || isNaN(editEndDate.getTime()) || editBeginTime == editEndTime){
            mainWindow.showError(qsTr("Error"), qsTr("Invalid session."));
            return;
        }
        
        editing = false;
        
        planWindow.close();
        //select action in library
        mainWindow.showModuleDirect(root.missionsModule);                        
        root.missionsModule.selector.select(timeline.editingAction);
        //launch editor
        root.missionsModule.content.editor.select(timeline.editingAction);
        //call editor's editAttachedPlan
        var aplan = root.missionsModule.content.editor.actionEditor.createAttachedPlan();
        //set shit
        var newInstance = aplan.instances.at(0);
        newInstance.startTime = editBeginDate;
        newInstance.endTime = editEndDate;
        
        root.missionsModule.content.editor.actionEditor.editAttachedPlan(aplan);
        
        root.missionsModule.content.editor.actionEditor.aplanWindow.lengthSelector.setMinutes(Math.round(Math.abs(editBeginTime - editEndTime) / minuteLength));
        
    }
    function discardNewPlan(){
        editing = false;
        planWindow.close();
    }
    
    function editSession(marker){
        if (marker == null) return;
        var nextMarker = Engine.getMarkerAfter(marker.time);
        if (nextMarker == null) return;
        
        startEdit(marker.action, false)
        
        editType = 1;
        editingAuto = marker.isAuto;
        
        editBegin = oldBegin = marker.time.getTime();
        editEnd = oldEnd = nextMarker.time.getTime();
        editWindow.begin = Engine.timeToString(new Date(editBegin));
        editWindow.end = Engine.timeToString(new Date(editEnd));
        
        editBlock.opacity = 1.0;
        refreshEditBlock();
    }
/*
    function saveSession(overLengthConfirmed){
        var editBeginTime = sintvSelector.getBeginTime();
        var editEndTime = sintvSelector.getEndTime();
        
        if (overLengthConfirmed != true && Math.abs(editBeginTime - editEndTime) > maxSessionLength) {
            messageBox_overLength.show(saveSession);
            return;
        }
        
        var editBeginDate = new Date(Math.min(editBeginTime, editEndTime));
        var editEndDate = new Date(Math.max(editBeginTime, editEndTime));
        if (isNaN(editBeginDate.getTime()) || isNaN(editEndDate.getTime())){
            mainWindow.showError(qsTr("Error"), qsTr("Invalid session."));
            return;
        }
        
        Engine.drawTimelineRange(null, new Date(editBegin), new Date(editEnd));
        Engine.drawTimelineRange(editingAction, editBeginDate, editEndDate);
        
        finishEdit();
        sessionWindow.close();
    }
    */
    Finder {
        id: finder
        visible: false
    }
    
    function onReturnPressed(){
        if (editing) timeline.saveEdit();
    }
    
    function onEscapePressed(){
        if (editing) timeline.discardEdit();
    }
    
    MessageDialog {
        id: messageBox_overLength
        title: qsTr("Warning")
        text: qsTr("Session length is longer than usual. Are you sure you want to save?")
        icon: StandardIcon.Warning
        standardButtons: StandardButton.Save | StandardButton.Cancel;
        
        onAccepted: {
            handlerFunc(true);
        }
        
        property var handlerFunc;
        
        function show(handler){
            handlerFunc = handler;
            visible = true;
        }
    }
    
    ApplicationWindow {
        visible: false
        id: editWindow
        minimumWidth: 400
        minimumHeight: 360
        title: editType == 0 ? qsTr("Draw Session") : qsTr("Edit Session")
        flags: Qt.Dialog;
        //modality: Qt.WindowModal
        maximumHeight: minimumHeight
        maximumWidth: minimumWidth
        
        property alias begin: intvSelector.begin;
        property alias end: intvSelector.end;
        
        function findAction(){
            timeline.finder.show(false, true, false, selectAction, qsTr("Select Action"));
        }
        
        function selectAction(item){
            if (item != null) timeline.editingAction = item;
            
        }
        
        onClosing: {
            timeline.discardEdit();
        }
        
        ColumnLayout {
            anchors.fill: parent;
            anchors.topMargin: 10
            anchors.leftMargin: 10
            anchors.rightMargin: 10
            anchors.bottomMargin: 10
            
            GroupBox {
                Layout.minimumHeight: 40
                Layout.maximumHeight: 65536
                Layout.minimumWidth: 40
                Layout.maximumWidth: 65536
                Layout.fillWidth: true
                title: qsTr("Help")
                Label {
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                    wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                    anchors.fill: parent
                    text: editType == 0 ? qsTr("Left click and drag on the timeline to draw a static session, then click 'Draw'.\nChoose 'None' to draw an empty session (erase).") :
                                          qsTr("Left click and drag on the timeline to set new range for the session.\nClick on the action name to locate it in library.")
                }
            }
        
            GroupBox {
                Layout.fillWidth: true
                Layout.fillHeight: true
                Layout.minimumHeight: 30
                Layout.maximumHeight: 65536
                title: qsTr("Action");
                RowLayout {
                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.verticalCenter: parent.verticalCenter
                    Button {
                        text: qsTr("None")
                        enabled: timeline.editingAction != null;
                        onClicked: {
                            timeline.editingAction = null;
                            if (editingAuto && Engine.globalSettings.autoAutoPlan){
                                mainWindow.showWarning(qsTr("Warning"), qsTr("Auto session generation is currently enabled. If a dynamic session is erased, it will be filled back in instantly to complete missions. Delete the mission instead."));
                            }
                        }
                    }
                    Button {
                        text: qsTr("Select")
                        onClicked: editWindow.findAction();
                    }
                    Rectangle {
                        Layout.fillWidth: true
                        height: 25
                        Layout.minimumWidth: 100
                        Layout.maximumWidth: 65536
                        border.color: "grey";
                        border.width: 1;
                        color: "transparent";
                        
                        SimpleButton {
                            anchors.fill: parent
                            enabled: visible
                            visible: timeline.editingAction != null;
                            text: timeline.editingAction.name;
                            buttonColor: timeline.editingAction.parentFolder.color;
                            
                            onClicked:{
                                timeline.discardEdit();
                                
                                mainWindow.showModuleDirect(root.missionsModule);                        
                                root.missionsModule.selector.select(timeline.editingAction);
                            }
                        }
                        
                        Label {
                            anchors.centerIn: parent
                            text: qsTr("(Erasing)");
                            visible: timeline.editingAction == null;
                        }
                    }
                }
            }
            
            GroupBox {
                Layout.fillWidth: true
                title: qsTr("Snap");
                RowLayout {
                    anchors.horizontalCenter: parent.horizontalCenter
                    CheckBox{
                        id: snapNowBox
                        checked: true;
                        text: qsTr("To now")
                    }
                    CheckBox{
                        id: snapMarkerBox
                        checked: true;
                        text: qsTr("To other sessions")
                    }
                    CheckBox{
                        id: snapTimeBox
                        checked:true;
                        text: qsTr("To every 15 minutes");
                    }
                }
            }
            
            GroupBox {
                Layout.fillWidth: true
                title: qsTr("Session");
                IntervalSelector{
                    id: intvSelector
                    anchors.fill: parent
                }
            }
            
            Button {
                text: editType == 0 ? qsTr("Draw") : ((editingAuto && editingAction != null) ? qsTr("Save as Static Session") : qsTr("Save"))
                Layout.fillWidth: true
                Layout.minimumWidth: 10
                Layout.maximumWidth: 65536
                onClicked: {
                    timeline.saveEdit();
                }
            }
            
            Button {
                text: qsTr("Close")
                Layout.fillWidth: true
                Layout.minimumWidth: 10
                Layout.maximumWidth: 65536
                onClicked: {
                    timeline.discardEdit();
                }
            }
        }
    }
    
    ApplicationWindow {
        visible: false
        id: planWindow
        minimumWidth: 400
        minimumHeight: 300
        title: qsTr("Create Attached Mission")
        flags: Qt.Dialog;
        //modality: Qt.WindowModal
        maximumHeight: minimumHeight
        maximumWidth: minimumWidth
        
        property alias begin: pintvSelector.begin;
        property alias end: pintvSelector.end;
        
        function findAction(){
            timeline.finder.show(false, true, false, selectAction, qsTr("Select Required Action"));
        }
        
        function selectAction(item){
            if (item != null) timeline.editingAction = item;
            
        }
        
        onClosing: {
            timeline.discardNewPlan();
        }
        
        ColumnLayout {
            anchors.fill: parent;
            anchors.topMargin: 10
            anchors.leftMargin: 10
            anchors.rightMargin: 10
            anchors.bottomMargin: 10
            
            GroupBox {
                Layout.minimumHeight: 40
                Layout.maximumHeight: 65536
                Layout.minimumWidth: 40
                Layout.maximumWidth: 65536
                Layout.fillWidth: true
                title: qsTr("Help")
                Label {
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                    wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                    anchors.fill: parent
                    text: qsTr("Left click and drag on the timeline to draw the time frame, then click 'Next' to create an attached mission for the action selected.");
                }
            }
            
            GroupBox {
                Layout.fillWidth: true
                Layout.fillHeight: true
                Layout.minimumHeight: 30
                Layout.maximumHeight: 65536
                title: qsTr("Required Action");
                RowLayout {
                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.verticalCenter: parent.verticalCenter
                    Button {
                        text: qsTr("Select")
                        onClicked: planWindow.findAction();
                    }
                    SimpleButton {
                        Layout.fillWidth: true
                        Layout.minimumWidth: 50
                        Layout.maximumWidth: 65536
                        text: timeline.editingAction != null ? timeline.editingAction.name : "";
                        buttonColor: timeline.editingAction != null ? timeline.editingAction.parentFolder.color : "";
                    }
                }
            }
            
            GroupBox {
                Layout.fillWidth: true
                title: qsTr("Time Frame");
                IntervalSelector{
                    id: pintvSelector
                    anchors.fill: parent
                }
            }
            
            Button {
                text: qsTr("Next")
                Layout.fillWidth: true
                Layout.minimumWidth: 10
                Layout.maximumWidth: 65536
                onClicked: {
                    timeline.saveNewPlan();
                }
            }
            
            Button {
                text: qsTr("Cancel")
                Layout.fillWidth: true
                Layout.minimumWidth: 10
                Layout.maximumWidth: 65536
                onClicked: {
                    timeline.discardNewPlan();
                }
            }
        }
    }
    /*
    ApplicationWindow {
        visible: false
        id: sessionWindow
        minimumWidth: 400
        minimumHeight: 300
        title: qsTr("Edit Session")
        flags: Qt.Dialog;
        modality: Qt.WindowModal
        maximumHeight: minimumHeight
        maximumWidth: minimumWidth
        
        property alias begin: sintvSelector.begin;
        property alias end: sintvSelector.end;
        
        function findAction(){
            timeline.finder.show(false, true, false, selectAction, qsTr("Select Action"));
        }
        
        function selectAction(item){
            if (item != null) timeline.editingAction = item;
        }
        
        ColumnLayout {
            anchors.fill: parent;
            anchors.topMargin: 10
            anchors.leftMargin: 10
            anchors.rightMargin: 10
            anchors.bottomMargin: 10
            
            GroupBox {
                Layout.minimumHeight: 40
                Layout.maximumHeight: 65536
                Layout.minimumWidth: 40
                Layout.maximumWidth: 65536
                Layout.fillWidth: true
                title: qsTr("Help")
                Label {
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                    wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                    anchors.fill: parent
                    text: qsTr("Click on the action name to locate it in library.");
                }
            }
        
            GroupBox {
                Layout.fillWidth: true
                Layout.fillHeight: true
                Layout.minimumHeight: 30
                Layout.maximumHeight: 65536
                title: qsTr("Action");
                RowLayout {
                    anchors.fill: parent
                    Button {
                        text: qsTr("Clear")
                        enabled: timeline.editingAction != null;
                        onClicked: timeline.editingAction = null;
                    }
                    Button {
                        text: qsTr("Set")
                        onClicked: editWindow.findAction();
                    }
                    Rectangle {
                        Layout.fillWidth: true
                        height: 25
                        Layout.minimumWidth: 100
                        Layout.maximumWidth: 65536
                        border.color: "grey";
                        border.width: 1;
                        color: "transparent";
                        
                        SimpleButton {
                            anchors.fill: parent
                            enabled: visible
                            visible: timeline.editingAction != null;
                            text: timeline.editingAction.name;
                            buttonColor: timeline.editingAction.parentFolder.color;
                            
                            onClicked: {
                                mainWindow.showModuleDirect(root.missionsModule);                        
                                root.missionsModule.selector.select(timeline.editingAction);
                                
                                sessionWindow.close();
                            }
                        }
                        
                        Label {
                            anchors.centerIn: parent
                            text: qsTr("(Do Nothing)");
                            visible: timeline.editingAction == null;
                        }
                    }
                }
            }
            
            GroupBox {
                Layout.fillWidth: true
                title: qsTr("Session");
                IntervalSelector{
                    id: sintvSelector
                    anchors.fill: parent
                }
            }
            
            Button {
                text: qsTr("Save as Normal Session")
                Layout.fillWidth: true
                Layout.minimumWidth: 10
                Layout.maximumWidth: 65536
                onClicked: {
                    timeline.saveSession();
                }
            }
            
            Button {
                text: qsTr("Discard")
                Layout.fillWidth: true
                Layout.minimumWidth: 10
                Layout.maximumWidth: 65536
                onClicked: {
                    sessionWindow.close();
                }
            }
        }
    }
    */
    
    ApplicationWindow {
        visible: false
        id: autoplanWindow
        minimumWidth: 360
        minimumHeight: 280
        title: qsTr("Generate Sessions")
        flags: Qt.Dialog;
        modality: Qt.WindowModal
        maximumHeight: minimumHeight
        maximumWidth: minimumWidth
        
        function show(){
            autoAutoPlanBox.checked = Engine.globalSettings.autoAutoPlan;
            visible = true;
        }
        
        ColumnLayout {
            anchors.fill: parent;
            anchors.topMargin: 10
            anchors.leftMargin: 10
            anchors.rightMargin: 10
            anchors.bottomMargin: 10
            
            GroupBox {
                Layout.minimumHeight: 40
                Layout.maximumHeight: 65536
                Layout.minimumWidth: 40
                Layout.maximumWidth: 65536
                Layout.fillWidth: true
                Layout.fillHeight: true
                title: qsTr("Help")
                Label {
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                    wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                    anchors.fill: parent
                    text: qsTr("This system will attempt to complete as many missions in the future as possible by drawing dynamic sessions around static sessions between now and %1 days in the future.\nExisting dynamic sessions will be modified while static sessions stay where they are.").arg(planningDays);
                }
            }
            
            GroupBox{
                title: qsTr("Operations")
                Layout.minimumHeight: 40
                Layout.maximumHeight: 65536
                Layout.minimumWidth: 40
                Layout.maximumWidth: 65536
                Layout.fillWidth: true
                ColumnLayout{
                    anchors.fill: parent
                    Layout.minimumHeight: 40
                    Layout.maximumHeight: 65536
                    Layout.fillWidth: true
                    
                    CheckBox{
                        id: autoAutoPlanBox
                        text: qsTr("Automatically generate after timeline / mission changes")
                        checked: Engine.globalSettings.autoAutoPlan;
                        onClicked: {
                            Engine.globalSettings.autoAutoPlan = checked;
                            if (checked){
                                Engine.autoPlan();
                                finishEdit();
                            }
                        }
                    }
                    
                    Button {
                        Layout.fillWidth: true
                        Layout.minimumWidth: 10
                        Layout.maximumWidth: 65536
                        
                        text: qsTr("Generate Dynamic Sessions")
                        
                        enabled: !Engine.globalSettings.autoAutoPlan
                        
                        onClicked: {
                            //Engine.drawTimelineRange(null, Engine.currentTime(), new Date(Engine.currentTime().getTime() + dayLength));
                            Engine.autoPlan();
                            finishEdit();
                            autoplanWindow.close();
                        }
                    }
                    Button {
                        Layout.fillWidth: true
                        Layout.minimumWidth: 10
                        Layout.maximumWidth: 65536
                        
                        text: qsTr("Fill Empty Sessions Only")
                        
                        enabled: !Engine.globalSettings.autoAutoPlan
                        
                        onClicked: {
                            Engine.autoPlan(true);
                            finishEdit();
                            autoplanWindow.close();
                        }
                    }
                    
                    Label {
                        text: "-"
                    }

                    Button {
                        Layout.fillWidth: true
                        Layout.minimumWidth: 10
                        Layout.maximumWidth: 65536
                        
                        text: qsTr("Erase Future Dynamic Sessions")
                        
                        enabled: !Engine.globalSettings.autoAutoPlan
                        
                        onClicked: {
                            Engine.eraseAutoPlan();
                            finishEdit();
                            autoplanWindow.close();
                        }
                    }
                }
            }
        }
    }
    
    
    
    function createBlock(i, marker){
        if (i >= blockPool.length){
            blockPool.push(block_comp.createObject(blockContainer));
        }
        
        var block = blockPool[i];
        
        if (marker == null) block.visible = false;
        else {
            block.marker = marker;
            block.time = Utils.clamp(marker.time.getTime(), loadedRangeBegin - marginBias, loadedRangeEnd + marginBias);
            block.visible = true;
            if (marker.action != null){
                block.sessionBlock.visible = true;
                block.sessionBlock.buttonColor = marker.action.parentFolder.color;
                /*
                var actionParent = marker.action.parentFolder;
                block.sessionBlock.text = actionParent == null ? marker.action.name : "[" + actionParent.name + "] " + marker.action.name;
                */
                block.sessionBlock.text = marker.action.name;
            }
            else {
                block.sessionBlock.visible = false;
            }
        }
    }
    
    function createLabel(i, time){
        
        if (i >= labelPool.length){
            labelPool.push(label_comp.createObject(timeline));
            labelPool[i].anchors.right = vLine.left
            labelPool[i].anchors.rightMargin = labelMargin
        }
        
        var label = labelPool[i];
        
        label.visible = true;
        
        label.time = time;
        
        var date = new Date(time);
        var year = date.getUTCFullYear();
        var month = date.getUTCMonth() + 1;
        var day = date.getUTCDate();
        var hour = date.getUTCHours();
        
        if (hour == 0) {
            if (month == 1 && day == 1) {
                label.text = "[" + year + "]-";
                label.font.bold = true;
                label.hidable = false;
            }
            else {
                label.text = month + "-" + day + " -";
                label.font.bold = true;
                label.hidable = false;
            }
        }
        else {
            label.text = hour + " -";
            label.font.bold = false;
            label.hidable = hour % 3 != 0;
        }
    }
    
    function finishEdit(){
        autoAutoPlan();
        Engine.save();
        refresh();
        timelineEdited();
    }
    
    function autoAutoPlan(){
        if (Engine.globalSettings.autoAutoPlan){
            Engine.autoPlan();
        }
    }
    
    function refresh(){
        var viewCenter = (topTime + bottomTime) / 2;
        loadedRangeBegin = viewCenter - loadedRadius;
        loadedRangeEnd = viewCenter + loadedRadius;
        
        var i, marker;
        
        for (i = 0; i < blockPool.length; i++){
            blockPool[i].visible = false;
        }
        
        numBlocks = 0;
        
        //console.log(loadedRangeBegin);
        
        marker = Engine.getMarker(new Date(loadedRangeBegin));
        
        //console.log(marker);
        createBlock(numBlocks, marker);
        numBlocks++;
        
        while (true){
            marker = Engine.getNextMarker();
            //console.log(marker);
            createBlock(numBlocks, marker);
            numBlocks++;
            if (marker == null || marker.time.getTime() > loadedRangeEnd) break;
        }
        
        blockPool[0].time = loadedRangeBegin - marginBias;
        blockPool[numBlocks-1].time = loadedRangeEnd + marginBias;
        blockPool[numBlocks-1].visible = false;
        
        for (i = 0; i < labelPool.length; i++){
            labelPool[i].visible = false;
        }
        
        numLabels = 0;
        var labelTime = Math.floor(loadedRangeBegin / hourLength) * hourLength;
        while (true){
            if (labelTime >= 0){
                createLabel(numLabels, labelTime);
                numLabels++;
            }
            if (labelTime > loadedRangeEnd) break;
            labelTime += hourLength;
        }
        
        reposition();
    }
    
    function reposition(){
        
        nowLine.y = Utils.map(Utils.clamp(Engine.currentTime().getTime(), topTime - marginBias, bottomTime + marginBias), topTime, bottomTime, 0, timeline.height);
        hLine.y = Utils.map(cameraTime, topTime, bottomTime, 0, timeline.height);
        
        var i;
        
        for (i = 0; i < numBlocks; i++){
            var block = blockPool[i];
            block.y = Utils.map(block.time, topTime, bottomTime, 0, timeline.height, true);
            if (i > 0){
                var prevBlock = blockPool[i-1];
                prevBlock.height = block.y - prevBlock.y;
                prevBlock.reposition();
            }
        }
        
        for (i = 0; i < numLabels; i++){
            var label = labelPool[i];
            label.y = Utils.map(label.time, topTime, bottomTime, 0, timeline.height) - label.contentHeight / 2;
            label.visible = true;
        }
        if (labelPool[1].y - labelPool[0].y < hideDistance) {
            for (i = 0; i < numLabels; i++){
                var label = labelPool[i];
                if (label.hidable) label.visible = false;
            }
        }
        
        if (editing){
            editBlock.y = Utils.map(Math.min(editBegin, editEnd), topTime, bottomTime, 0, timeline.height, true);
            editBlock.height = Utils.map(Math.max(editBegin, editEnd), topTime, bottomTime, 0, timeline.height, true) - editBlock.y;
            editBlock.reposition();
        }
    }
    
    Rectangle {
        id: background
        anchors.fill: parent
        color: "white"
    }
    
    Rectangle {
        id: vLine
        x: leftMargin;
        width: sideLineWidth
        anchors.bottom: parent.bottom;
        anchors.top: parent.top;
        
        gradient: Gradient {
            GradientStop{
                position: 0.0; color: "#00000000";
            }
            GradientStop{
                position: 0.5; color: "#aa000000";
            }
            GradientStop{
                position: 1.0; color: "#00000000";
            }
        }
    }
    
    Item {
        id: blockContainer
        x: blockX
        width: 1
        anchors.top: parent.top
        anchors.bottom: parent.bottom
    }
    
    Item {
        id: editBlockContainer
        x: blockX
        width: 1
        anchors.top: parent.top
        anchors.bottom: parent.bottom
        
        opacity: 0.75;
    }
    
    Rectangle {
        id: hLine
        anchors.left: parent.left
        anchors.right: parent.right
        
        height: 2
        
        color: "#44000000"
    }
    
    Rectangle {
        id: nowLine
        anchors.left: parent.left
        anchors.right: parent.right
        
        height: 3
        
        color: "#882266ff"
    }
    
    MouseArea {
        id: topMouseArea
        property int curX: 0;
        property int curY: 0;
        property int moveMode: 0;
        property real moveThreshold: 10;
        anchors.fill: parent
        //hoverEnabled: true
        propagateComposedEvents: true;
        acceptedButtons: Qt.RightButton;
        onPressed: function (event){
            curX = event.x;
            curY = event.y;
            moveMode = 0;
        }
        onPositionChanged: function (event){
            if (pressed){
                if (moveMode > 0){
                    if (moveMode == 1) moveCamera((-(event.y - curY) / timeline.height) * (bottomTime - topTime) * moveSpeedMul, 0);
                    else if (moveMode == 2) moveCamera(0, (event.x - curX) / timeline.width * zoomSpeedMul);
                    curX = event.x;
                    curY = event.y;
                }
                else {
                    if (Math.abs(event.y - curY) > moveThreshold) moveMode = 1;
                    else if (Math.abs(event.x - curX) > moveThreshold) moveMode = 2;
                }
            }
        }
        onWheel: function (event){
            moveCamera(- event.angleDelta.y * wheelStep, 0);
        }
    }
    
    function snap(time){
        if (snapNow){
            var dest = Engine.currentTime().getTime();
            if (Math.abs(dest - time) < snapNowRange) return dest;
        }
        if (snapMarker){
            var lowerMarker = Engine.getMarker(new Date(time));
            var upperMarker = Engine.getMarkerAfter(new Date(time));
            var dest = time - 100 * snapTimeRange;
            if (lowerMarker != null && upperMarker == null) dest = lowerMarker.time.getTime();
            if (upperMarker != null && lowerMarker == null) dest = upperMarker.time.getTime();
            if (lowerMarker != null && upperMarker != null){
                var lower = lowerMarker.time.getTime();
                var upper = upperMarker.time.getTime();
                dest = Math.abs(lower - time) < Math.abs(upper - time) ? lower : upper;
            }
            if (Math.abs(dest - time) < snapMarkerRange) return dest;
        }
        if (snapTime){
            var lower = Math.floor(time / snapTimeInterval) * snapTimeInterval;
            var upper = Math.ceil(time / snapTimeInterval) * snapTimeInterval;
            var dest = Math.abs(lower - time) < Math.abs(upper - time) ? lower : upper;
            if (Math.abs(dest - time) < snapTimeRange) return dest;
        }
        return time;
    }
    
    MouseArea {
        id: editMouseArea
        anchors.fill: parent
        acceptedButtons: Qt.LeftButton;
        enabled: editing
        onPressed: function (event){
            editBlock.opacity = 1.0;
            editBegin = snap(Utils.map(event.y, 0, timeline.height, topTime, bottomTime));
            editEnd = editBegin;
            
            reposition();
        }
        onPositionChanged: function (event){
            editEnd = snap(Utils.map(event.y, 0, timeline.height, topTime, bottomTime));
            
            var editBeginDate = new Date(Math.min(editBegin, editEnd));
            var editEndDate = new Date(Math.max(editBegin, editEnd));
            if (editType == 0 || editType == 1){
                editWindow.begin = Engine.timeToString(editBeginDate);
                editWindow.end = Engine.timeToString(editEndDate);
            }
            else if (editType == 2){
                planWindow.begin = Engine.timeToString(editBeginDate);
                planWindow.end = Engine.timeToString(editEndDate);
            }

            reposition();
        }
    }
}
