QT += quick
QT += gui
QT += widgets
QT += concurrent

CONFIG += c++17

HEADERS += \
    include/PhotoProcessing/PhotoProcessing.h

SOURCES += \
        sources/PhotoProcessing/PhotoProcessing.cpp \
        sources/main.cpp

RESOURCES += ui/qml.qrc

# Default rules for deployment.
qnx: target.path = /tmp/$${TARGET}/bin
else: unix:!android: target.path = /opt/$${TARGET}/bin
!isEmpty(target.path): INSTALLS += target

unix {
    QMAKE_CXXFLAGS += "-fno-sized-deallocation"
}
