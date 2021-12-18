import QtQuick 2.15
import QtQuick.Controls 2.15
import QtGraphicalEffects 1.15

Item {
    property string imageColor: ""
    property string imageSource: ""

    property bool imageAsynchronous: true

    Image {
        id: image

        anchors.fill: parent

        source: imageSource

        sourceSize.height: parent.height
        sourceSize.width: parent.width

        fillMode: Image.PreserveAspectFit

        asynchronous: imageAsynchronous
        smooth: true
        mipmap: true
    }

    Loader {
        active: (imageColor === "") ? false : true

        asynchronous: true

        anchors.fill: image

        sourceComponent: ColorOverlay {
            source: image
            color: imageColor
        }
    }
}
