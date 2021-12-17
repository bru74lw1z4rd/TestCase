import QtQuick 2.12
import QtQuick.Controls 2.12
import QtQuick.Controls.Material 2.12
import Qt.labs.platform 1.1

import PhotoProcessing 1.0

import "qrc:/Elements/Images/"

ApplicationWindow {
    id: applicationWindow

    width: 640
    height: 480
    visible: true
    title: qsTr("НКБ ВС. Задание #7")
    color: "#333333"

    Material.theme: Material.Dark
    Material.accent: Material.Indigo

    property var imageOperationsHistory: []
    property int currentOperationInHistory: 0

    property var threadQueue: []

    Timer {
        id: threadQueueTimer

        interval: 450

        onTriggered: {
            let i = (threadQueue.length - 1 < 0) ? 0 : threadQueue.length - 1

            if (threadQueue[i][3] === 0) {
                photoProcessing.processHue(threadQueue[i][1], threadQueue[i][2])
            } else if (threadQueue[i][3] === 1) {
                photoProcessing.processBrightness(threadQueue[i][0], threadQueue[i][1], threadQueue[i][2])
            } else if (threadQueue[i][3] === 2) {
                photoProcessing.processContrast(threadQueue[i][0], threadQueue[i][1], threadQueue[i][2])
            }
        }
    }

    PhotoProcessing {
        id: photoProcessing

        property string sourceImage: ""
        property int sourceWidth: 0
        property int sourceHeight: 0

        property bool isHueProcessingStarted: false

        property bool isBrightnessProcessingStarted: false
        property string newBrightnessImage: ""

        property bool isContrastProcessingStarted: false
        property string newContrastImage: ""
    }

    /* Функция сбрасывает все значения UI страницы */
    function resetUi() {
        imageOperationsHistory = []
        imageOperationsHistory.push(photoProcessing.sourceImage)
        currentOperationInHistory = 0

        threadQueue = []

        photoProcessing.isHueProcessingStarted = false
        photoProcessing.isBrightnessProcessingStarted = false
        photoProcessing.isContrastProcessingStarted = false
        photoProcessing.newBrightnessImage = ""
        photoProcessing.newContrastImage = ""

        hueSlider.value = 0
        brightnessSlider.value = 1.0
        contrastSlider.value = 0
    }

    FileDialog {
        id: saveFileDialog

        acceptLabel: "Save"

        fileMode: FileDialog.SaveFile
        folder: StandardPaths.writableLocation(StandardPaths.DocumentsLocation)

        onAccepted: {
            photoProcessing.saveFile(image.source, saveFileDialog.file)
        }
    }

    FileDialog {
        id: openDialog

        folder: StandardPaths.writableLocation(StandardPaths.DocumentsLocation)

        nameFilters: [ "Image files (*.jpg *.png)" ]

        onAccepted: {
            if (photoProcessing.sourceImage !== "") {
                resetUi()
            }

            photoProcessing.sourceImage = openDialog.file
            image.source = openDialog.file

            photoProcessing.sourceWidth = photoProcessing.getSourceImageSize(openDialog.file)[0]
            photoProcessing.sourceHeight = photoProcessing.getSourceImageSize(openDialog.file)[1]

            imageOperationsHistory = []
            imageOperationsHistory.push(openDialog.file)
        }
    }

    Rectangle {
        id: mainMenu

        width: 50

        enabled: imageBusyIndicatorLoader.active === false

        color: "#4d4d4d"

        anchors {
            top: parent.top
            left: parent.left
            bottom: parent.bottom
        }

        Column {
            anchors {
                fill: parent
            }

            RoundButton {
                id: openFileButton

                height: width
                width: parent.width

                flat: true

                onClicked: {
                    openDialog.open()
                }

                SvgImage {
                    imageSource: "qrc:/mainMenu/open.svg"
                    imageColor: "white"

                    anchors {
                        fill: parent

                        margins: 10
                    }
                }
            }

            RoundButton {
                id: saveFileButton

                height: width
                width: parent.width

                enabled: (image.source == "") ? false : true

                flat: true

                onClicked: {
                    saveFileDialog.open()
                }

                SvgImage {
                    imageSource: "qrc:/mainMenu/save.svg"
                    imageColor: (parent.enabled === true) ? "white" : "gray"

                    anchors {
                        fill: parent

                        margins: 10
                    }
                }
            }

            RoundButton {
                id: rotateImageButton

                height: width
                width: parent.width

                enabled: (image.source == "") ? false : true

                flat: true

                onClicked: {
                    photoProcessing.processRotate(image.source)
                }

                SvgImage {
                    imageSource: "qrc:/mainMenu/rotateLeftVariant.svg"
                    imageColor: (parent.enabled === true) ? "white" : "gray"

                    anchors {
                        fill: parent

                        margins: 10
                    }
                }
            }

            RoundButton {
                id: increaseImageButton

                height: width
                width: parent.width

                enabled: (image.source == "") ? false : true

                flat: true

                onClicked: {
                    photoProcessing.processIncreaseScaling(image.source)
                }

                SvgImage {
                    imageSource: "qrc:/mainMenu/increaseScale.svg"
                    imageColor: (parent.enabled === true) ? "white" : "gray"

                    anchors {
                        fill: parent

                        margins: 10
                    }
                }
            }

            RoundButton {
                id: decreaseImageButton

                height: width
                width: parent.width

                enabled: (image.source == "") ? false : true

                flat: true

                onClicked: {
                    photoProcessing.processDecreaseScaling(image.source)
                }

                SvgImage {
                    imageSource: "qrc:/mainMenu/decreaseScale.svg"
                    imageColor: (parent.enabled === true) ? "white" : "gray"

                    anchors {
                        fill: parent

                        margins: 10
                    }
                }
            }

            RoundButton {
                id: redoButton

                height: width
                width: parent.width

                enabled: (currentOperationInHistory + 1 < imageOperationsHistory.length) ? true : false

                flat: true

                onClicked: {
                    if (currentOperationInHistory + 1 < imageOperationsHistory.length) {
                        currentOperationInHistory += 1

                        image.source = ""
                        image.source = imageOperationsHistory[currentOperationInHistory]
                    }
                }

                SvgImage {
                    imageSource: "qrc:/mainMenu/redo.svg"
                    imageColor: (parent.enabled === true) ? "white" : "gray"

                    anchors {
                        fill: parent

                        margins: 10
                    }
                }
            }

            RoundButton {
                id: undoButton

                height: width
                width: parent.width

                enabled: (currentOperationInHistory > 0) ? true : false

                flat: true

                onClicked: {
                    if (currentOperationInHistory !== 0) {
                        currentOperationInHistory -= 1

                        image.source = ""
                        image.source = imageOperationsHistory[currentOperationInHistory]
                    }
                }

                SvgImage {
                    imageSource: "qrc:/mainMenu/undo.svg"
                    imageColor: (parent.enabled === true) ? "white" : "gray"

                    anchors {
                        fill: parent

                        margins: 10
                    }
                }
            }

            RoundButton {
                id: restoreFileButton

                height: width
                width: parent.width

                flat: true

                onClicked: {
                    resetUi()

                    image.source = photoProcessing.sourceImage
                }

                SvgImage {
                    imageSource: "qrc:/mainMenu/restore.svg"
                    imageColor: "white"

                    anchors {
                        fill: parent

                        margins: 10
                    }
                }
            }
        }
    }

    Image {
        id: image

        cache: false

        fillMode: Image.PreserveAspectFit

        sourceSize.height: 350
        sourceSize.width: 350

        anchors {
            top: parent.top
            left: mainMenu.right
            right: rightMenuFlickable.left
            bottom: parent.bottom

            margins: 10
        }

        Rectangle {
            color: "#333333"

            opacity: 0.5

            visible: imageBusyIndicatorLoader.active

            anchors {
                fill: parent
            }
        }

        Loader {
            id: imageBusyIndicatorLoader

            height: 50
            width: height

            active: false

            anchors {
                centerIn: parent
            }

            sourceComponent: BusyIndicator { }
        }
    }

    Rectangle {
        id: rightMenuBackground

        color: "#4d4d4d"

        anchors {
            fill: rightMenuFlickable
        }
    }

    Flickable {
        id: rightMenuFlickable

        width: 250
        contentHeight: checkDelegatesColumn.implicitHeight + slidersDelegatesColumn.implicitHeight

        enabled: imageBusyIndicatorLoader.active === false

        boundsBehavior: Flickable.StopAtBounds

        anchors {
            top: parent.top
            right: parent.right
            bottom: parent.bottom
        }

        Column {
            id: checkDelegatesColumn

            spacing: 0

            enabled: image.source != ""

            anchors {
                top: parent.top
                left: parent.left
                right: parent.right
            }

            ItemDelegate {
                width: parent.width

                text: "Эффект сепии"

                onClicked: {
                    photoProcessing.processToSepia(image.source)
                }
            }

            ItemDelegate {
                width: parent.width

                text: "Эффект серого"

                onClicked: {
                    photoProcessing.processRgbToGray(image.source)
                }
            }

            ToolSeparator {
                width: parent.width

                orientation: "Horizontal"
            }
        }

        Column {
            id: slidersDelegatesColumn

            spacing: 12

            enabled: imageBusyIndicatorLoader.active === false

            anchors {
                top: checkDelegatesColumn.bottom
                left: parent.left
                right: parent.right
            }

            Row {
                height: children[1].height
                width: parent.width

                spacing: 10

                Text {
                    height: parent.height

                    text: qsTr("HUE")
                    color: "white"

                    font.pointSize: 11
                    verticalAlignment: Text.AlignVCenter

                    leftPadding: 16
                }

                Slider {
                    id: hueSlider

                    width: parent.width - parent.children[0].width - parent.children[0].leftPadding - parent.children[2].width - 10

                    from: 0
                    value: 0
                    to: 255

                    onMoved: {
                        if (photoProcessing.isHueProcessingStarted === false) {
                            photoProcessing.isHueProcessingStarted = true
                        }

                        if (photoProcessing.sourceWidth <= 800 || photoProcessing.sourceHeight <= 800) {
                            threadQueue.push(["", image.source, hueSlider.value, 0])
                            photoProcessing.processHue(image.source, hueSlider.value)
                        } else {
                            if (threadQueueTimer.running === false) {
                                threadQueue.push(["", image.source, hueSlider.value, 0])
                                threadQueueTimer.running = true
                            } else {
                                threadQueue.push(["", image.source, hueSlider.value, 0])
                            }
                        }
                    }
                }

                RoundButton {
                    width: parent.height
                    height: parent.height

                    enabled: photoProcessing.isHueProcessingStarted === true

                    flat: true

                    anchors {
                        verticalCenter: parent.verticalCenter
                    }

                    onClicked: {
                        photoProcessing.isHueProcessingStarted = false

                        imageOperationsHistory.push(image.source)
                        currentOperationInHistory = imageOperationsHistory.length - 1
                    }

                    SvgImage {
                        imageSource: "qrc:/mainMenu/tick.svg"
                        imageColor: (photoProcessing.isHueProcessingStarted === true) ? "white" : "gray"

                        anchors {
                            fill: parent

                            margins: 10
                        }
                    }
                }
            }

            Row {
                height: children[1].height
                width: parent.width

                spacing: 10

                Text {
                    height: parent.height

                    text: qsTr("Яркость")
                    color: "white"

                    font.pointSize: 10
                    verticalAlignment: Text.AlignVCenter

                    leftPadding: 16
                }

                Slider {
                    id: brightnessSlider

                    width: parent.width - parent.children[0].width - parent.children[0].leftPadding - parent.children[2].width - 10

                    enabled: photoProcessing.isContrastProcessingStarted === false

                    from: 0.0
                    value: 1.0
                    to: 2.0

                    onMoved: {
                        if (photoProcessing.isBrightnessProcessingStarted === false) {
                            photoProcessing.newBrightnessImage = photoProcessing.createTempImage(image.source)
                            photoProcessing.isBrightnessProcessingStarted = true
                        }

                        if (photoProcessing.sourceWidth <= 800 || photoProcessing.sourceHeight <= 800) {
                            threadQueue.push([photoProcessing.newBrightnessImage, image.source, brightnessSlider.value, 1])
                            photoProcessing.processBrightness(photoProcessing.newBrightnessImage, image.source, brightnessSlider.value)
                        } else {
                            if (threadQueueTimer.running === false) {
                                threadQueue.push([photoProcessing.newBrightnessImage, image.source, brightnessSlider.value, 1])
                                threadQueueTimer.running = true
                            } else {
                                threadQueue.push([photoProcessing.newBrightnessImage, image.source, brightnessSlider.value, 1])
                            }
                        }
                    }
                }

                RoundButton {
                    width: parent.height
                    height: parent.height

                    enabled: photoProcessing.isBrightnessProcessingStarted === true

                    flat: true

                    anchors {
                        verticalCenter: parent.verticalCenter
                    }

                    onClicked: {
                        threadQueue = []

                        photoProcessing.isBrightnessProcessingStarted = false

                        imageOperationsHistory.push(image.source)
                        currentOperationInHistory = imageOperationsHistory.length - 1
                    }

                    SvgImage {
                        imageSource: "qrc:/mainMenu/tick.svg"
                        imageColor: (photoProcessing.isBrightnessProcessingStarted === true) ? "white" : "gray"

                        anchors {
                            fill: parent

                            margins: 10
                        }
                    }
                }
            }

            Row {
                height: children[1].height
                width: parent.width

                spacing: 10

                Text {
                    height: parent.height

                    text: qsTr("Контраст")
                    color: "white"

                    font.pointSize: 10
                    verticalAlignment: Text.AlignVCenter

                    leftPadding: 16
                }

                Slider {
                    id: contrastSlider

                    width: parent.width - parent.children[0].width - parent.children[0].leftPadding - parent.children[2].width - 10

                    enabled: photoProcessing.isBrightnessProcessingStarted === false

                    from: -127
                    value: 0
                    to: 127

                    onMoved: {
                        if (photoProcessing.isContrastProcessingStarted === false) {
                            photoProcessing.newContrastImage = photoProcessing.createTempImage(image.source)
                            photoProcessing.isContrastProcessingStarted = true
                        }

                        if (photoProcessing.sourceWidth <= 800 || photoProcessing.sourceHeight <= 800) {
                            threadQueue.push([photoProcessing.newContrastImage, image.source, contrastSlider.value, 2])
                            photoProcessing.processContrast(photoProcessing.newContrastImage, image.source, contrastSlider.value)
                        } else {
                            if (threadQueueTimer.running === false) {
                                threadQueue.push([photoProcessing.newContrastImage, image.source, contrastSlider.value, 2])
                                threadQueueTimer.running = true
                            } else {
                                threadQueue.push([photoProcessing.newContrastImage, image.source, contrastSlider.value, 2])
                            }
                        }
                    }
                }

                RoundButton {
                    width: parent.height
                    height: parent.height

                    enabled: photoProcessing.isContrastProcessingStarted === true

                    flat: true

                    anchors {
                        verticalCenter: parent.verticalCenter
                    }

                    onClicked: {
                        photoProcessing.isContrastProcessingStarted = false

                        imageOperationsHistory.push(image.source)
                        currentOperationInHistory = imageOperationsHistory.length - 1
                    }

                    SvgImage {
                        imageSource: "qrc:/mainMenu/tick.svg"
                        imageColor: (photoProcessing.isContrastProcessingStarted === true) ? "white" : "gray"

                        anchors {
                            fill: parent

                            margins: 10
                        }
                    }
                }
            }

            ToolSeparator {
                width: parent.width

                orientation: "Horizontal"
            }

            Row {
                height: children[1].height
                width: parent.width

                spacing: 10

                Text {
                    height: parent.height

                    text: qsTr("Box Blur")
                    color: "white"

                    font.pointSize: 10
                    verticalAlignment: Text.AlignVCenter

                    leftPadding: 16
                }

                TextField {
                    id: boxBlurSamples

                    width: parent.width - parent.children[0].width - parent.children[0].leftPadding - parent.children[2].width - 10

                    text: "1"
                    placeholderText: "Количество"

                    selectByMouse: true

                    leftPadding: 4
                    rightPadding: 4
                }

                RoundButton {
                    width: parent.height
                    height: parent.height

                    enabled: (boxBlurSamples.displayText.length > 0 && image.source != "")

                    flat: true

                    anchors {
                        verticalCenter: parent.verticalCenter
                    }

                    onClicked: {
                        photoProcessing.processBoxBlur(image.source, boxBlurSamples.text)
                    }

                    SvgImage {
                        imageSource: "qrc:/mainMenu/tick.svg"
                        imageColor: (parent.enabled === true) ? "white" : "gray"

                        anchors {
                            fill: parent

                            margins: 10
                        }
                    }
                }
            }
        }
    }

    Connections {
        target: photoProcessing

        function onImageEditChanged(filePath) {
            imageBusyIndicatorLoader.active = false

            imageOperationsHistory.push(filePath)
            currentOperationInHistory = imageOperationsHistory.length - 1

            image.source = ""
            image.source = filePath
        }

        function onImageEditWithoutQueueChanged(filePath) {
            imageBusyIndicatorLoader.active = false

            image.source = ""
            image.source = filePath

            if (threadQueue.length > 0 && (photoProcessing.sourceWidth <= 800 || photoProcessing.sourceHeight <= 800)) {
                threadQueue.pop()

                if (threadQueue.length !== 0) {
                    let i = (threadQueue.length - 1 < 0) ? 0 : threadQueue.length - 1

                    if (threadQueue[i][3] === 0) {
                        photoProcessing.processHue(threadQueue[i][1], threadQueue[i][2])
                    } else if (threadQueue[i][3] === 1) {
                        photoProcessing.processBrightness(threadQueue[i][0], threadQueue[i][1], threadQueue[i][2])
                    } else if (threadQueue[i][3] === 2) {
                        photoProcessing.processContrast(threadQueue[i][0], threadQueue[i][1], threadQueue[i][2])
                    }
                }
            }
        }

        function onLoadingStartedChanged() {
            imageBusyIndicatorLoader.active = true
        }
    }
}
