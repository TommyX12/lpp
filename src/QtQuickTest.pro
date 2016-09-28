TEMPLATE = app

QT += qml quick widgets

CONFIG += c++11

SOURCES += main.cpp \
    lpp/Action.cpp \
    lpp/Engine.cpp \
    lpp/Plan.cpp \
    lpp/Session.cpp \
    lpp/GlobalVars.cpp \
    lpp/utils/Types.cpp \
    lpp/utils/Utils.cpp \
    lpp/TimelineMarker.cpp \
    lpp/utils/QObjectVector.cpp \
    lpp/Folder.cpp \
    lpp/SearchInfo.cpp \
    lpp/SearchList.cpp \
    lpp/IQmlSearchable.cpp \
    lpp/ISavable.cpp \
    lpp/Instance.cpp \
    lpp/Objective.cpp \
    lpp/Occurrence.cpp \
    lpp/Settings.cpp \
    lpp/GlobalSettings.cpp

RESOURCES += qml.qrc

# Additional import path used to resolve QML modules in Qt Creator's code model
QML_IMPORT_PATH =

# Default rules for deployment.
include(deployment.pri)

HEADERS += \
    lpp/Action.h \
    lpp/Engine.h \
    lpp/Plan.h \
    lpp/Session.h \
    lpp/utils/Utils.h \
    lpp/GlobalVars.h \
    lpp/utils/Types.h \
    lpp/TimelineMarker.h \
    lpp/utils/QObjectVector.h \
    lpp/Folder.h \
    lpp/SearchInfo.h \
    lpp/SearchList.h \
    lpp/IQmlSearchable.h \
    lpp/ISavable.h \
    lpp/Instance.h \
    lpp/Objective.h \
    lpp/Occurrence.h \
    lpp/Settings.h \
    lpp/GlobalSettings.h

DISTFILES += \
    ../bin/qml/modules/lpp_utils/components/utils/Utils.js \
    ../bin/qml/moduleList.js \
    ../bin/qml/modules/lpp_timeline/qmldir \
    ../bin/qml/modules/lpp_utils/qmldir \
    ../bin/qml/modules/lpp_timeline/components/ActionEditor.qml \
    ../bin/qml/modules/lpp_timeline/components/Actions.qml \
    ../bin/qml/modules/lpp_timeline/components/ActionsOverview.qml \
    ../bin/qml/modules/lpp_timeline/components/CalendarWindow.qml \
    ../bin/qml/modules/lpp_timeline/components/ContentBox.qml \
    ../bin/qml/modules/lpp_timeline/components/Overview.qml \
    ../bin/qml/modules/lpp_timeline/components/TextEditor.qml \
    ../bin/qml/modules/lpp_timeline/components/Timeline.qml \
    ../bin/qml/modules/lpp_timeline/components/TimelineView.qml \
    ../bin/qml/modules/lpp_utils/components/PageView.qml \
    ../bin/qml/main.qml \
    ../bin/qml/modules/lpp_actions/qmldir \
    ../bin/qml/modules/lpp_actions/main.qml \
    ../bin/qml/modules/lpp_actions/components/ActionEditor.qml \
    ../bin/qml/modules/lpp_actions/components/Actions.qml \
    ../bin/qml/modules/lpp_actions/components/ActionsOverview.qml \
    ../bin/qml/modules/lpp_actions/components/ActionSelector.qml \
    ../bin/qml/modules/lpp_actions/components/TextEditor.qml \
    ../bin/qml/modules/lpp_actions/components/ActionTableItem.qml \
    ../bin/qml/modules/lpp_utils/components/SimpleButton.qml \
    ../bin/qml/modules/lpp_actions/components/Folder.qml \
    ../bin/qml/modules/lpp_actions/components/FolderEditor.qml \
    ../bin/qml/modules/lpp_actions/components/Editor.qml \
    ../bin/qml/modules/lpp_actions/components/ColorPicker.qml \
    ../bin/qml/modules/lpp_missions/qmldir \
    ../bin/qml/modules/lpp_missions/components/ActionEditor.qml \
    ../bin/qml/modules/lpp_missions/components/ColorPicker.qml \
    ../bin/qml/modules/lpp_missions/components/Editor.qml \
    ../bin/qml/modules/lpp_missions/components/FolderEditor.qml \
    ../bin/qml/modules/lpp_missions/components/TextEditor.qml \
    ../bin/qml/modules/lpp_missions/components/ContentBox.qml \
    ../bin/qml/modules/lpp_missions/components/Selector.qml \
    ../bin/qml/modules/lpp_missions/components/Overview.qml \
    ../bin/qml/modules/lpp_missions/components/editors/ActionEditor.qml \
    ../bin/qml/modules/lpp_missions/components/editors/FolderEditor.qml \
    ../bin/qml/modules/lpp_missions/components/editors/TextEditor.qml \
    ../bin/qml/modules/lpp_missions/components/editors/ColorPicker.qml \
    ../bin/qml/modules/lpp_missions/components/LibraryItem.qml \
    ../bin/qml/modules/lpp_missions/components/Finder.qml \
    ../bin/qml/modules/lpp_missions/components/NewFolderDialog.qml \
    ../bin/qml/modules/lpp_missions/components/NewActionDialog.qml \
    ../bin/qml/modules/lpp_missions/Main.qml \
    ../bin/qml/modules/lpp_timeline/Main.qml \
    ../bin/qml/modules/lpp_timeline/components/SessionBlock.qml \
    ../bin/qml/modules/lpp_utils/components/ColorPicker.qml \
    ../bin/qml/modules/lpp_missions/components/editors/PlanEditor.qml \
    ../bin/qml/modules/lpp_missions/components/NewPlanDialog.qml \
    ../bin/qml/modules/lpp_missions/components/editors/ObjectiveItem.qml \
    ../bin/qml/modules/lpp_missions/components/editors/ObjectiveWindow.qml \
    ../bin/qml/modules/lpp_utils/components/DurationSelector.qml \
    ../bin/qml/modules/lpp_missions/components/editors/InstanceItem.qml \
    ../bin/qml/modules/lpp_missions/components/editors/InstanceWindow.qml \
    ../bin/qml/modules/lpp_utils/components/IntervalSelector.qml \
    note.txt \
    ../bin/qml/modules/lpp_test/qmldir \
    ../bin/qml/modules/lpp_test/components/ContentBox.qml \
    ../bin/qml/modules/lpp_test/components/Overview.qml \
    ../bin/qml/modules/lpp_test/components/SessionBlock.qml \
    ../bin/qml/modules/lpp_test/components/TextEditor.qml \
    ../bin/qml/modules/lpp_test/components/Timeline.qml \
    ../bin/qml/modules/lpp_test/components/TimelineView.qml \
    ../bin/qml/modules/lpp_test/Main.qml \
    ../bin/qml/modules/lpp_timeline/components/OccurrenceItem.qml \
    ../bin/qml/modules/lpp_utils/components/SimpleList.qml \
    ../bin/qml/modules/lpp_utils/components/PooledList.qml \
    ../bin/qml/modules/lpp_timeline/components/DoubleProgressBar.qml \
    ../bin/qml/modules/lpp_timeline/components/OccurrenceWindow.qml \
    ../bin/qml/modules/lpp_missions/components/editors/InstanceWindow.qml \
    ../bin/qml/modules/lpp_timeline/components/ObjectiveItem.qml
