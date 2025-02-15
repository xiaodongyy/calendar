/*
 * SPDX-FileCopyrightText: 2021 Wang Rui <wangrui@jingos.com>
 *
 * SPDX-License-Identifier: GPL-3.0-or-later
 */
import QtQuick 2.0
import QtQuick.Layouts 1.3
import QtQuick.Controls 2.0 as Controls2
import org.kde.kirigami 2.3 as Kirigami
import QtGraphicalEffects 1.15

RowLayout {
    id: timeRow

    property alias hourNumber: hourWheelView.value
    property alias minutesNumber: timeWheelVIew.value
    property bool is24HourFormat
    property int hourFormatNumber: is24HourFormat ? 24 : 12
    property bool pmSelected
    property var pos1

    width: popup.width - popup.commMargin * 2

    spacing: 0

    Rectangle {
        id: hourRect

        width: popup.width / 5.18
        height: width
        color: "#1e767680"
        radius: 7

        WheelView {
            id: hourWheelView

            anchors.centerIn: parent
            anchors.fill: parent

            model: {
                var list = []
                for (var i = 0; i < hourFormatNumber; i++)
                    list.push({
                                  "display": (!is24HourFormat
                                              && i === 0 ? 12 + "" : i / 10 < 1 ? "0" + i : "" + i),
                                  "value": i
                              })
                return list
            }

            value: hourNumber

            pathItemCount: 1
            displayFontSize: 20

            onViewMove: {
                popup.isTimeDataChanged = true
                if (index !== hourNumber) {
                    popup.dateValueChanged("time", index)
                }
                hourNumber = index
                popup.startHour = hourNumber
            }
        }

        Item {
            anchors.top: parent.top
            anchors.horizontalCenter: parent.horizontalCenter

            width: hourRect.width / 3 * 2
            height: hourRect.height / 3

            MouseArea {
                anchors.fill: parent

                onClicked: {
                    popup.isTimeDataChanged = true
                    hourNumber++
                    if (hourNumber > (hourFormatNumber - 1)) {
                        hourNumber = 0
                    }
                    popup.startHour = hourNumber
                }
            }

            Image {
                anchors.horizontalCenter: parent.horizontalCenter

                sourceSize.width: hourRect.height / 3
                sourceSize.height: hourRect.height / 3

                source: "qrc:/assets/triangle_up.png"
            }
        }

        Item {
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.bottom: parent.bottom

            width: hourRect.width / 3 * 2
            height: hourRect.height / 3

            MouseArea {
                anchors.fill: parent
                
                onClicked: {
                    popup.isTimeDataChanged = true
                    hourNumber--
                    if (hourNumber < 0) {
                        hourNumber = (hourFormatNumber - 1)
                    }
                    popup.startHour = hourNumber
                }
            }

            Image {
                anchors.bottom: parent.bottom
                anchors.horizontalCenter: parent.horizontalCenter

                sourceSize.width: hourRect.height / 3
                sourceSize.height: hourRect.height / 3

                source: "qrc:/assets/triangle_down.png"
            }
        }

        MouseArea {
            property var contentY: 0
            property var pressedY: 0
            property bool isReduce: false

            anchors.fill: parent

            propagateComposedEvents: true
            hoverEnabled: true

            onEntered: {
                preventStealing = true
            }

            onExited: {
                preventStealing = false
            }

            onPressed: {
                popup.isCoverArea = true
                propagateComposedEvents = false
                pressedY = mouseY
                preventStealing = true
            }

            onReleased: {
                popup.isCoverArea = false
                propagateComposedEvents = true
                preventStealing = false
                var moveY = mouseY - pressedY
                var count = parseInt(moveY / 40)
                if (Math.abs(contentY) < 40 & Math.abs(contentY) > 10) {
                    count = 1
                }
                if (count >= 1) {
                    hourNumber = hourNumber - count
                    if (hourNumber < 0) {
                        hourNumber = (hourFormatNumber - 1)
                    }
                    popup.startHour = hourNumber
                } else if (count <= -1) {
                    hourNumber = hourNumber + Math.abs(count)
                    if (hourNumber > (hourFormatNumber - 1)) {
                        hourNumber = 0
                    }
                    popup.startHour = hourNumber
                }
            }

            onWheel: {
                popup.isTimeDataChanged = true
                var wY = wheel.angleDelta.y

                if (wY == 120) {
                    hourNumber = hourNumber - 1
                    if (hourNumber < 0) {
                        hourNumber = (hourFormatNumber - 1)
                    }
                    popup.startHour = hourNumber
                    return
                } else if (wY == -120) {
                    hourNumber = hourNumber + 1
                    if (hourNumber > (hourFormatNumber - 1)) {
                        hourNumber = 0
                    }
                    popup.startHour = hourNumber
                    return
                }

                if (wY != 0 & Math.abs(contentY) < Math.abs(wY)) {
                    contentY = wY
                } else if (wY != 0 & Math.abs(contentY) > Math.abs(wY)) {
                    isReduce = true
                }
                if (isReduce & wY == 0) {
                    if (contentY != 0) {
                        var count = parseInt(contentY / 250)
                        if (Math.abs(contentY) < 300) {
                            count = 1
                        }
                        isReduce = false
                        contentY = 0

                        if (count >= 1) {
                            hourNumber = hourNumber - count
                            if (hourNumber < 0) {
                                hourNumber = (hourFormatNumber - 1)
                            }
                            popup.startHour = hourNumber
                        } else if (count <= -1) {
                            hourNumber = hourNumber + Math.abs(count)
                            if (hourNumber > (hourFormatNumber - 1)) {
                                hourNumber = 0
                            }
                            popup.startHour = hourNumber
                        }
                    }
                }
            }
        }
    }

    Rectangle {
        id: symbol

        width: hourRect.width / 1.9
        height: hourRect.height

        Column {
            anchors.centerIn: symbol

            spacing: 5

            Rectangle {
                anchors.verticalCenter: parent.horizontalCenter

                width: 5
                height: width

                radius: width / 2
                color: "black"
            }

            Rectangle {
                anchors.verticalCenter: parent.horizontalCenter

                width: 5
                height: width

                radius: width / 2
                color: "black"
            }
        }
    }

    Rectangle {
        id: minuteRect

        width: popup.width / 5.18
        height: width

        color: "#1e767680"
        radius: 7

        WheelView {
            id: timeWheelVIew

            anchors.centerIn: parent
            anchors.fill: parent

            model: {
                var list = []
                for (var i = 0; i < 60; i++)
                    list.push({
                                  "display": (i / 10 < 1 ? "0" + i : "" + i),
                                  "value": i
                              })
                return list
            }

            value: minutesNumber
            pathItemCount: 1
            displayFontSize: 20

            onViewMove: {
                popup.isTimeDataChanged = true
                if (index !== minutesNumber) {
                    popup.dateValueChanged("time", index)
                }
                minutesNumber = index
                popup.startMinute = minutesNumber
            }
        }

        Item {
            anchors.top: parent.top
            anchors.horizontalCenter: parent.horizontalCenter

            width: hourRect.width / 3 * 2
            height: hourRect.height / 3

            MouseArea {
                anchors.fill: parent

                onClicked: {
                    popup.isTimeDataChanged = true
                    minutesNumber++
                    if (minutesNumber > 59) {
                        minutesNumber = 0
                    }
                    popup.startMinute = minutesNumber
                }
            }

            Image {
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.top: parent.top

                sourceSize.width: hourRect.height / 3
                sourceSize.height: hourRect.height / 3

                source: "qrc:/assets/triangle_up.png"
            }
        }

        Item {
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.bottom: parent.bottom

            width: hourRect.width / 3 * 2
            height: hourRect.height / 3

            MouseArea {
                anchors.fill: parent

                onClicked: {
                    popup.isTimeDataChanged = true
                    minutesNumber--
                    if (minutesNumber < 0) {
                        minutesNumber = 59
                    }
                    popup.startMinute = minutesNumber
                }
            }

            Image {
                anchors.bottom: parent.bottom
                anchors.horizontalCenter: parent.horizontalCenter

                sourceSize.width: hourRect.height / 3
                sourceSize.height: hourRect.height / 3

                source: "qrc:/assets/triangle_down.png"
            }
        }

        MouseArea {
            property var contentY: 0
            property var pressedY: 0
            property bool isReduce: false

            anchors.fill: parent

            propagateComposedEvents: true
            hoverEnabled: true

            onEntered: {
                preventStealing = true
            }

            onExited: {
                preventStealing = false
            }

            onPressed: {
                popup.isCoverArea = true
                propagateComposedEvents = false
                pressedY = mouseY
                preventStealing = true
            }

            onReleased: {
                popup.isCoverArea = false
                propagateComposedEvents = true
                // preventStealing = false
                var moveY = mouseY - pressedY
                var count = parseInt(moveY / 40)
                if (Math.abs(contentY) < 40 & Math.abs(contentY) > 10) {
                    count = 1
                }
                if (count >= 1) {
                    minutesNumber = minutesNumber - count
                    if (minutesNumber < 0) {
                        minutesNumber = 59
                    }
                    popup.startMinute = minutesNumber
                } else if (count <= -1) {
                    minutesNumber = minutesNumber + Math.abs(count)
                    if (minutesNumber > 59) {
                        minutesNumber = 0
                    }
                    popup.startMinute = minutesNumber
                }
            }

            onWheel: {
                popup.isTimeDataChanged = true
                var wY = wheel.angleDelta.y
                if (wY == 120) {
                    minutesNumber = minutesNumber - 1
                    if (minutesNumber < 0) {
                        minutesNumber = 59
                    }
                    popup.startMinute = minutesNumber
                    return
                } else if (wY == -120) {
                    minutesNumber = minutesNumber + 1
                    if (minutesNumber > 59) {
                        minutesNumber = 0
                    }
                    popup.startMinute = minutesNumber
                    return
                }

                if (wY != 0 & Math.abs(contentY) < Math.abs(wY)) {
                    contentY = wY
                } else if (wY != 0 & Math.abs(contentY) > Math.abs(wY)) {
                    isReduce = true
                }
                if (isReduce & wY == 0) {
                    if (contentY != 0) {
                        var count = parseInt(contentY / 250)
                        if (Math.abs(contentY) < 300) {
                            count = 1
                        }
                        isReduce = false
                        contentY = 0
                        if (count >= 1) {
                            minutesNumber = minutesNumber - count
                            if (minutesNumber < 0) {
                                minutesNumber = 59
                            }
                            popup.startMinute = minutesNumber
                        } else if (count <= -1) {
                            minutesNumber = minutesNumber + Math.abs(count)
                            if (minutesNumber > 59) {
                                minutesNumber = 0
                            }
                            popup.startMinute = minutesNumber
                        }
                    }
                }
            }
        }
    }

    Item {
        width: hourRect.width / 6.25
        height: hourRect.height

        visible: !is24HourFormat
    }

    Rectangle {
        anchors.left: minuteRect.right

        width: timeRow.width - hourRect.width - symbol.width - minuteRect.width
        height: minuteRect.height

        visible: is24HourFormat

        Kirigami.Label {
            anchors.centerIn: parent

            text: "24 Hours"
            color: "#FFA6A6A7"
            font.pixelSize: 14
        }
    }

    Rectangle {

        anchors.left: minuteRect.right
        anchors.leftMargin: 12

        width: timeRow.width - hourRect.width - symbol.width - minuteRect.width - 12
        height: minuteRect.height

        visible: !is24HourFormat

        color: "#1e767680"
        radius: 7

        Item {
            id: amRect

            anchors.left: parent.left

            width: parent.width / 2
            height: parent.height

            Kirigami.Label {
                anchors.centerIn: parent

                text: "AM"
                color: "#FF000000"
                opacity: pmSelected ? 0.3 : 1
                font.pixelSize: 14

                MouseArea {
                    anchors.fill: parent
                    onClicked: {
                        pmSelected = false
                        popup.pmSelectorChanged(pmSelected)
                    }
                }
            }
        }

        Item {
            anchors.left: amRect.right

            width: parent.width / 2
            height: parent.height

            Kirigami.Separator {
                anchors.left: parent.left
                anchors.verticalCenter: parent.verticalCenter

                implicitWidth: 1
                implicitHeight: parent.height / 3

                color: "#FFC6C6C8"
            }

            Kirigami.Label {
                anchors.centerIn: parent

                text: "PM"
                opacity: pmSelected ? 1 : 0.3
                color: "#FF000000"
                font.pixelSize: 14

                MouseArea {
                    anchors.fill: parent
                    onClicked: {
                        popup.dateValueChanged("pm", pmSelected ? 1 : 0)
                        pmSelected = true
                        popup.pmSelectorChanged(pmSelected)
                    }
                }
            }
        }
    }
}
