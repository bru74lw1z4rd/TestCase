import QtQuick 2.12
import QtQuick.Controls 2.12
import QtQuick.Controls.Material 2.12

import Qt.labs.platform 1.1

import PhotoProcessing 1.0

ApplicationWindow {
    id: applicationWindow

    width: 640
    height: 480
    visible: true
    title: qsTr("НКБ ВС. Задание #7")
    color: "#333333"

    Material.theme: Material.Dark
    Material.accent: Material.Indigo

    PhotoProcessing {
        id: photoProcessing

        property string sourceImage: ""

        property bool isBrightnessProcessingStarted: false
        property string newBrightnessImage: ""

        property bool isContrastProcessingStarted: false
        property string newContrastImage: ""
    }

    /* Функция сбрасывает все значения UI страницы */
    function resetUi() {
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
        id: fileDialog

        folder: StandardPaths.writableLocation(StandardPaths.DocumentsLocation)

        nameFilters: [ "Image files (*.jpg *.png)" ]

        onAccepted: {
            resetUi()

            photoProcessing.sourceImage = fileDialog.file
            image.source = fileDialog.file
        }
    }

    Rectangle {
        id: mainMenuBackground

        color: "#4d4d4d"

        anchors {
            fill: mainMenu
        }
    }

    Rectangle {
        id: rightMenuBackground

        width: rightMenuFlickable.width

        color: "#4d4d4d"

        anchors {
            top: parent.top
            right: parent.right
            bottom: parent.bottom
        }
    }

    Column {
        id: mainMenu

        enabled: imageBusyIndicatorLoader.active === false

        width: 200        

        anchors {
            top: parent.top
            left: parent.left
            bottom: parent.bottom
        }

        ItemDelegate {
            width: parent.width

            text: "Выбрать изображение"

            highlighted: true

            onClicked: {
                fileDialog.open()
            }
        }

        ItemDelegate {
            width: parent.width

            text: "Сохранить изображение"

            enabled: (image.source == "") ? false : true

            highlighted: true

            onClicked:  {
                saveFileDialog.open()
            }
        }

        ItemDelegate {
            width: parent.width

            text: "Восстановить изображение"

            highlighted: true

            onClicked: {
                resetUi()

                image.source = photoProcessing.sourceImage
            }
        }
    }

    Image {
        id: image

        cache: false

        fillMode: Image.PreserveAspectFit

        sourceSize.height: 500
        sourceSize.width: 500

        anchors {
            top: parent.top
            left: mainMenu.right
            right: rightMenuFlickable.left
            bottom: parent.bottom
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

    Flickable {
        id: rightMenuFlickable

        width: 200

        contentHeight: rightMenu.height

        boundsBehavior: Flickable.StopAtBounds

        anchors {
            top: parent.top
            right: parent.right
            bottom: parent.bottom

            topMargin: 15
            bottomMargin: 15
        }

        Column {
            id: rightMenu

            spacing: 12

            enabled: imageBusyIndicatorLoader.active === false

            anchors {
                fill: parent
            }

            Column {
                height: hueHeading.implicitHeight + hueSlider.implicitHeight + contrastHeading.implicitHeight + hueSeperator.implicitHeight + brightnessApplyButton.implicitHeight
                        + brightnessSeperator.implicitHeight + contrastSlider.implicitHeight + brightnessHeading.implicitHeight + brightnessSlider.implicitHeight + slidersApplyButton.implicitHeight
                width: parent.width

                Text {
                    id: hueHeading

                    width: parent.width

                    text: qsTr("HUE")
                    color: "white"

                    font.pointSize: 16
                    horizontalAlignment: Text.AlignHCenter
                }

                Slider {
                    id: hueSlider

                    from: 0
                    value: 0
                    to: 255

                    onMoved: {
                        photoProcessing.processHue(image.source, hueSlider.value)
                    }
                }

                ToolSeparator {
                    id: hueSeperator

                    width: parent.width

                    orientation: "Horizontal"
                }

                Text {
                    id: brightnessHeading

                    enabled: photoProcessing.isContrastProcessingStarted === false

                    width: parent.width

                    text: qsTr("Яркость")
                    color: "white"

                    font.pointSize: 16
                    horizontalAlignment: Text.AlignHCenter
                }

                Slider {
                    id: brightnessSlider

                    enabled: photoProcessing.isContrastProcessingStarted === false

                    from: 0.0
                    value: 1.0
                    to: 2.0

                    onMoved: {
                        if (photoProcessing.isBrightnessProcessingStarted === false) {
                            photoProcessing.newBrightnessImage = photoProcessing.createTempImage(image.source)
                            photoProcessing.isBrightnessProcessingStarted = true
                        }

                        photoProcessing.processBrightness(photoProcessing.newBrightnessImage, image.source, brightnessSlider.value)
                    }
                }

                ItemDelegate {
                    id: brightnessApplyButton

                    enabled: photoProcessing.isContrastProcessingStarted === false

                    width: parent.width

                    text: "Применить"

                    highlighted: true

                    onClicked: {
                        photoProcessing.isBrightnessProcessingStarted = false
                    }
                }

                ToolSeparator {
                    id: brightnessSeperator

                    width: parent.width

                    orientation: "Horizontal"
                }

                Text {
                    id: contrastHeading

                    enabled: photoProcessing.isBrightnessProcessingStarted === false

                    width: parent.width

                    text: qsTr("Контрастность")
                    color: "white"

                    font.pointSize: 16
                    horizontalAlignment: Text.AlignHCenter
                }

                Slider {
                    id: contrastSlider

                    enabled: photoProcessing.isBrightnessProcessingStarted === false

                    from: -127
                    value: 0
                    to: 127

                    onMoved: {
                        if (photoProcessing.isContrastProcessingStarted === false) {
                            photoProcessing.newContrastImage = photoProcessing.createTempImage(image.source)
                            photoProcessing.isContrastProcessingStarted = true
                        }

                        photoProcessing.processContrast(photoProcessing.newContrastImage, image.source, contrastSlider.value)
                    }
                }

                ItemDelegate {
                    id: slidersApplyButton

                    enabled: photoProcessing.isBrightnessProcessingStarted === false

                    width: parent.width

                    text: "Применить"

                    highlighted: true

                    onClicked: {
                        photoProcessing.isContrastProcessingStarted = false
                    }
                }
            }

            ToolSeparator {
                width: parent.width

                orientation: "Horizontal"
            }

            ItemDelegate {
                width: parent.width

                text: "Повернуть"

                highlighted: true

                onClicked: {
                    photoProcessing.processRotate(image.source)
                }
            }

            ItemDelegate {
                width: parent.width

                text: "RGB в серый"

                highlighted: true

                onClicked: {
                    photoProcessing.processRgbToGray(image.source)
                }
            }

            Text {
                width: parent.width

                text: qsTr("Box Blur")
                color: "white"

                font.pointSize: 16
                horizontalAlignment: Text.AlignHCenter
            }

            TextField {
                id: boxBlurSamples

                width: parent.width

                text: "1"

                placeholderText: "1"

                selectByMouse: true

                leftPadding: 4
                rightPadding: 4
            }

            ItemDelegate {
                width: parent.width

                text: "Применить"

                highlighted: true

                onClicked: {
                    photoProcessing.processBoxBlur(image.source, boxBlurSamples.text)
                }
            }

            ToolSeparator {
                width: parent.width

                orientation: "Horizontal"
            }

            Row {
                width: parent.width

                spacing: 5

                ItemDelegate {
                    width: parent.width / 2

                    text: "+"

                    highlighted: true

                    onClicked: {
                        photoProcessing.processIncreaseScaling(image.source)
                    }
                }

                ItemDelegate {
                    width: parent.width / 2

                    text: "-"

                    highlighted: true

                    onClicked: {
                        photoProcessing.processDecreaseScaling(image.source)
                    }
                }
            }
        }
    }

    Connections {
        target: photoProcessing

        function onImageEditChanged(filePath) {
            imageBusyIndicatorLoader.active = false

            image.source = ""
            image.source = filePath
        }

        function onLoadingStartedChanged() {
            imageBusyIndicatorLoader.active = true
        }
    }
}
