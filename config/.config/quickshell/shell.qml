//@pragma UseQApplication

import Quickshell
import QtQuick
import Quickshell.Hyprland
import Quickshell.Wayland
import QtCharts
import QtQml
import QtQuick.Effects
import Qt5Compat.GraphicalEffects
import Quickshell.Io
import Quickshell.Services.UPower
import QtQuick.Layouts
import QtQuick.Shapes
import QtQuick.Controls
import Qt.labs.folderlistmodel
import Quickshell.Bluetooth

Variants {
  model: Quickshell.screens
  delegate: Component {
    PanelWindow {
      id: root
      required property var modelData
      screen: modelData
      anchors {
        top: true
        bottom: true
        right: true
        left: true
      }
      margins {
        top: 0
        bottom: 0
        right: 0
        left: 0
      }
      focusable: false
      exclusionMode: ExclusionMode.Ignore
      aboveWindows: false
      color: "transparent"
      Image {
        asynchronous: true
        source: `file://${Quickshell.env("HOME")}/.current_wallpaper`
        fillMode: Image.PreserveAspectCrop
        anchors.fill: parent
        smooth: true
        cache: true
      }
      Text {
        antialiasing: true
        anchors {
          horizontalCenter: parent.horizontalCenter
          top: parent.top
          topMargin: 100
        }
        renderType: Text.NativeRendering
        font.hintingPreference: Font.PreferFullHinting
        font.family: "Windey Signature personal use"
        font.pointSize: 100
        color: "#3e9f85"
        text: Time.day
      }
      PanelWindow {
        id: exclusiveZone
        implicitHeight: 30
        color: "transparent"
        focusable: false
        exclusionMode: ExclusionMode.Auto
        aboveWindows: false
        anchors {
          top: true
          left: true
          right: true
        }
        margins {
          top: 7
          left: 0
          right: 0
          bottom: 0
        }
      }
      PanelWindow {
        id: topLayer
        property bool isOpen: false
        signal isOpenFalse()
        onIsOpenChanged: {
          if (!isOpen)
          topLayer.isOpenFalse()
        }
        MouseArea {
          anchors.fill: parent
          onClicked: topLayer.isOpen = false
        }
        anchors {
          top: true
          bottom: true
          right: true
          left: true
        }
        margins {
          top: 0
          bottom: 0
          right: 0
          left: 0
        }
        focusable: false
        exclusionMode: ExclusionMode.Ignore
        aboveWindows: true
        color: "transparent"
        Region {
          id: mainRegion
          shape: RegionShape.Rect
          item: bar
          intersection: Intersection.Combine
        }
        mask: !topLayer.isOpen ? mainRegion : null
        Rectangle {
          id: bar
          anchors.top: parent.top
          anchors.topMargin: 7
          height: exclusiveZone.height
          width: exclusiveZone.width
          color: "transparent"
          Rectangle {
            id: logo
            anchors {
              left: parent.left
              verticalCenter: parent.verticalCenter
              leftMargin: 16
            }
            height: parent.height
            width: height
            radius: height / 2
            color: "#3e9f85"
            Text {
              renderType: Text.NativeRendering
              font.hintingPreference: Font.PreferFullHinting
              text: ""
              anchors.centerIn: parent
              font.family: "Elements"
              font.pointSize: 16.5
              color: "#e8dcbf"
            }
          }
          Rectangle {
            id: workspaces
            anchors {
              left: logo.right
              verticalCenter: parent.verticalCenter
              leftMargin: 16
            }
            height: parent.height
            width: childrenRect.width + 20.6
            radius: height / 2
            color: "#3e9f85"
            Row {
              anchors {
                left: parent.left
                verticalCenter: parent.verticalCenter
                leftMargin: 10
              }
              spacing: 8
              Repeater {
                model: {
                  let wsList = (Hyprland && Hyprland.workspaces) ? Hyprland.workspaces.values : [];
                  let maxId = wsList.length > 0 ? Math.max(...wsList.map(w => w.id)) : 0;
                  return Math.max(5, maxId);
                }
                Rectangle {
                  height: 16
                  width: height
                  radius: height / 2
                  property bool hoverOver: false
                  property var wsList: (Hyprland && Hyprland.workspaces) ? Hyprland.workspaces.values : []
                  property bool isActive: wsList.some(w => w.id === index + 1 && w.active)
                  color: isActive ? "#24574b" : hoverOver ? "#c4b9a1" : "#e8dcbf"
                  MouseArea {
                    anchors.fill: parent
                    hoverEnabled: true
                    onEntered: hoverOver = true
                    onExited: hoverOver = false
                    onClicked: Hyprland.dispatch("workspace " + (index + 1))
                  }
                }
              }
            }
          }
          Rectangle {
            id: powerButton
            property bool beingHover: false
            property bool isVisible: false
            signal isVisibleFalse()
            onIsVisibleChanged: {
              if (!isVisible)
              powerButton.isVisibleFalse()
            }
            anchors {
              right: bar.right
              verticalCenter: bar.verticalCenter
              rightMargin: 16
            }
            height: bar.height
            width: height
            radius: height / 2
            color: beingHover ? "#34876f" : "#3e9f85"
            Text {
              renderType: Text.NativeRendering
              font.hintingPreference: Font.PreferFullHinting
              text: "⏻"
              anchors.centerIn: parent
              font.family: "Segoe UI Variable Static Display"
              font.pointSize: 25
              color: parent.beingHover ? "#d1c5ab" : "#e8dcbf"
            }
            MouseArea {
              anchors.fill: parent
              hoverEnabled: true
              onEntered: parent.beingHover = true
              onExited: parent.beingHover = false
              onClicked: powerButton.isVisible = !powerButton.isVisible, topLayer.isOpen = true
            }
            Connections {
              target: topLayer
              function onIsOpenFalse() {
                powerButton.isVisible = false
              }
            }
            Connections {
              target: powerButton
              function onIsVisibleFalse() {
                Qt.callLater(function() {topLayer.isOpen = false})
              }
            }
          }
          Rectangle {
            id: powerMenu
            anchors.right: powerButton.right
            anchors.top: powerButton.bottom
            anchors.rightMargin: -3
            anchors.topMargin: 10
            height: 0
            width: 150
            color: "#24574b"
            visible: true
            opacity: 0
            radius: 10
            states: [
              State {
                name: "expanded"
                when: powerButton.isVisible && topLayer.isOpen
                PropertyChanges {
                  target: powerMenu
                  height: 100
                  opacity: 1
                }
              },
              State {
                name: "collapsed"
                when: !(powerButton.isVisible && topLayer.isOpen)
                PropertyChanges {
                  target: powerMenu
                  height: 0
                  opacity: 0
                }
              }
            ]
            transitions: [
              Transition {
                from: "collapsed"
                to: "expanded"
                reversible: true
                ParallelAnimation {
                  NumberAnimation { properties: "height"; duration: 250; easing.type: Easing.Linear }
                  NumberAnimation { properties: "opacity"; duration: 150 }
                }
              }
            ]
            Column {
              visible: powerMenu.height > 0 ? true : false
              anchors.fill: parent
              anchors.margins: 6
              spacing: 4
              Rectangle {
                visible: powerMenu.height > 0 ? true : false
                height: 28; width: parent.width
                radius: 6
                color: hovered ? "#1b473c" : "transparent"
                property bool hovered: false
                Text {
                  visible: powerMenu.height > 10 ? true : false
                  renderType: Text.NativeRendering
                  font.hintingPreference: Font.PreferFullHinting
                  text: "Shutdown"
                  anchors.verticalCenter: parent.verticalCenter
                  anchors.left: parent.left
                  anchors.leftMargin: 10
                  opacity: powerMenu.opacity
                  color: "#e8dcbf"
                  font.family: "Segoe UI Variable Static Display"
                  font.bold: true
                  font.pointSize: 10
                }
                MouseArea {
                  visible: powerMenu.height > 0 ? true : false
                  anchors.fill: parent
                  hoverEnabled: true
                  onEntered: parent.hovered = true
                  onExited: parent.hovered = false
                  onClicked: Quickshell.execDetached(["bash", "-c", "poweroff"])
                }
              }
              Rectangle {
                visible: powerMenu.height > 0 ? true : false
                height: 28; width: parent.width
                radius: 6
                color: hovered ? "#1b473c" : "transparent"
                property bool hovered: false
                Text {
                  visible: powerMenu.height > 49 ? true : false
                  renderType: Text.NativeRendering
                  font.hintingPreference: Font.PreferFullHinting
                  text: "Reboot"
                  anchors.verticalCenter: parent.verticalCenter
                  anchors.left: parent.left
                  anchors.leftMargin: 10
                  opacity: powerMenu.opacity
                  color: "#e8dcbf"
                  font.family: "Segoe UI Variable Static Display"
                  font.bold: true
                  font.pointSize: 10
                }
                MouseArea {
                  visible: powerMenu.height > 0 ? true : false
                  anchors.fill: parent
                  hoverEnabled: true
                  onEntered: parent.hovered = true
                  onExited: parent.hovered = false
                  onClicked: Quickshell.execDetached(["bash", "-c", "reboot"])

                }
              }
              Rectangle {
                visible: powerMenu.height > 0 ? true : false
                height: 28; width: parent.width
                radius: 6
                color: hovered ? "#1b473c" : "transparent"
                property bool hovered: false
                Text {
                  visible: powerMenu.height > 89 ? true : false
                  renderType: Text.NativeRendering
                  font.hintingPreference: Font.PreferFullHinting
                  text: "Sleep"
                  anchors.verticalCenter: parent.verticalCenter
                  anchors.left: parent.left
                  anchors.leftMargin: 10
                  opacity: powerMenu.opacity
                  color: "#e8dcbf"
                  font.family: "Segoe UI Variable Static Display"
                  font.bold: true
                  font.pointSize: 10
                }
                MouseArea {
                  visible: powerMenu.height > 0 ? true : false
                  anchors.fill: parent
                  hoverEnabled: true
                  onEntered: parent.hovered = true
                  onExited: parent.hovered = false
                  onClicked: Quickshell.execDetached(["bash", "-c", "systemctl suspend"])
                }
              }
            }
          }
          Rectangle {
            id: clock
            anchors {
              right: powerButton.left
              verticalCenter: bar.verticalCenter
              rightMargin: 16
            }
            height: bar.height
            width: 187
            radius: height / 2
            color: "#3e9f85"
            Row {
              anchors.horizontalCenter: parent.horizontalCenter
              spacing: 6
              Text {
                renderType: Text.NativeRendering
                font.hintingPreference: Font.PreferFullHinting
                anchors.verticalCenter: parent.verticalCenter
                font.family: "Segoe UI Variable Static Display"
                font.pointSize: 13.5
                color: "#e8dcbf"
                text: "󰸗"
              }
              Text {
                renderType: Text.NativeRendering
                font.hintingPreference: Font.PreferFullHinting
                anchors.verticalCenter: parent.verticalCenter
                font.family: "Segoe UI Variable Static Display"
                font.bold: true
                font.pointSize: 10.2
                color: "#e8dcbf"
                text: Time.time

              }
            }
          }
          Loader {
            id: batteryLoader
            sourceComponent: battery
            asynchronous: true
            active: UPower.displayDevice.isPresent
            anchors {
              right: clock.left
              verticalCenter: bar.verticalCenter
              rightMargin: 16
            }
          }
          Loader {
            id: batteryMenuLoader
            sourceComponent: batteryMenu
            asynchronous: true
            anchors.right: batteryLoader.right
            anchors.top: batteryLoader.bottom
            anchors.rightMargin: -50
            anchors.topMargin: 10
            active: UPower.displayDevice.isPresent
          }
          Component {
            id: battery
            Rectangle {
              property bool beingHover: false
              property bool isVisible: false
              signal isVisibleFalse()
              onIsVisibleChanged: {
                if (!isVisible)
                isVisibleFalse()
              }
              visible: true
              height: bar.height
              width: 57
              radius: height / 2
              color: beingHover ? "#34876f" : "#3e9f85"
              Row {
                anchors.centerIn: parent
                spacing: 1.5
                Text {
                  renderType: Text.NativeRendering
                  font.hintingPreference: Font.PreferFullHinting
                  //discharging
                  text: UPower.displayDevice.percentage >= 0.00 && UPower.displayDevice.percentage < 0.10 && UPower.displayDevice.state === 2 ? "󰂃" :
                  UPower.displayDevice.percentage >= 0.10 && UPower.displayDevice.percentage < 0.20 && UPower.displayDevice.state === 2 ? "󰁺" :
                  UPower.displayDevice.percentage >= 0.20 && UPower.displayDevice.percentage < 0.30 && UPower.displayDevice.state === 2 ? "󰁻" :
                  UPower.displayDevice.percentage >= 0.30 && UPower.displayDevice.percentage < 0.40 && UPower.displayDevice.state === 2 ? "󰁼" :
                  UPower.displayDevice.percentage >= 0.40 && UPower.displayDevice.percentage < 0.50 && UPower.displayDevice.state === 2 ? "󰁽" :
                  UPower.displayDevice.percentage >= 0.50 && UPower.displayDevice.percentage < 0.60 && UPower.displayDevice.state === 2 ? "󰁾" :
                  UPower.displayDevice.percentage >= 0.60 && UPower.displayDevice.percentage < 0.70 && UPower.displayDevice.state === 2 ? "󰁿" :
                  UPower.displayDevice.percentage >= 0.70 && UPower.displayDevice.percentage < 0.80 && UPower.displayDevice.state === 2 ? "󰂀" :
                  UPower.displayDevice.percentage >= 0.80 && UPower.displayDevice.percentage < 0.90 && UPower.displayDevice.state === 2 ? "󰂁" :
                  UPower.displayDevice.percentage >= 0.90 && UPower.displayDevice.percentage < 1.00 && UPower.displayDevice.state === 2 ? "󰂂" :
                  UPower.displayDevice.percentage >= 1.00 && UPower.displayDevice.state === 2 ? "󰁹" :
                  //Charging
                  UPower.displayDevice.percentage >= 0.00 && UPower.displayDevice.percentage < 0.10 && UPower.displayDevice.state === 1 ? "󰢟" :
                  UPower.displayDevice.percentage >= 0.10 && UPower.displayDevice.percentage < 0.20 && UPower.displayDevice.state === 1 ? "󰢜" :
                  UPower.displayDevice.percentage >= 0.20 && UPower.displayDevice.percentage < 0.30 && UPower.displayDevice.state === 1 ? "󰂆" :
                  UPower.displayDevice.percentage >= 0.30 && UPower.displayDevice.percentage < 0.40 && UPower.displayDevice.state === 1 ? "󰂇" :
                  UPower.displayDevice.percentage >= 0.40 && UPower.displayDevice.percentage < 0.50 && UPower.displayDevice.state === 1 ? "󰂈" :
                  UPower.displayDevice.percentage >= 0.50 && UPower.displayDevice.percentage < 0.60 && UPower.displayDevice.state === 1 ? "󰢝" :
                  UPower.displayDevice.percentage >= 0.60 && UPower.displayDevice.percentage < 0.70 && UPower.displayDevice.state === 1 ? "󰂉" :
                  UPower.displayDevice.percentage >= 0.70 && UPower.displayDevice.percentage < 0.80 && UPower.displayDevice.state === 1 ? "󰢞" :
                  UPower.displayDevice.percentage >= 0.80 && UPower.displayDevice.percentage < 0.90 && UPower.displayDevice.state === 1 ? "󰂊" :
                  UPower.displayDevice.percentage >= 0.90 && UPower.displayDevice.percentage < 1.00 && UPower.displayDevice.state === 1 ? "󰂋" :
                  UPower.displayDevice.percentage >= 1.00 && UPower.displayDevice.state === 1 ? "󰂅" : ""

                  font.family: "Segoe UI Variable Static Display"
                  font.pointSize: 13
                  color: battery.beingHover ? "#d1c5ab" : "#e8dcbf"
                }
                Text {
                  renderType: Text.NativeRendering
                  font.hintingPreference: Font.PreferFullHinting
                  text: (UPower.displayDevice.percentage * 100).toFixed(0) + "%"
                  font.family: "Segoe UI Variable Static Display"
                  font.bold: true
                  font.pointSize: 11
                  color: battery.beingHover ? "#d1c5ab" : "#e8dcbf"
                }
              }
              MouseArea {
                anchors.fill: parent
                hoverEnabled: true
                onEntered: parent.beingHover = true
                onExited: parent.beingHover = false
                onClicked: parent.isVisible = !parent.isVisible, topLayer.isOpen = true
              }
              Connections {
                target: topLayer
                function onIsOpenFalse() {
                  isVisible = false
                }
              }
              Connections {
                function onIsVisibleFalse() {
                  Qt.callLater(function() {topLayer.isOpen = false})
                }
              }
            }
          }
          Component {
            id: batteryMenu
            Rectangle {
              height: 0
              width: 150
              color: "#24574b"
              visible: true
              radius: 10
              opacity: 0
              states: [
                State {
                  name: "expanded"
                  when: batteryLoader.item.isVisible && topLayer.isOpen
                  PropertyChanges {
                    target: batteryMenuLoader.item
                    height: PowerProfiles.hasPerformanceProfile ? 100 : 75
                    opacity: 1
                  }
                },
                State {
                  name: "collapsed"
                  when: !(batteryLoader.item.isVisible && topLayer.isOpen)
                  PropertyChanges {
                    target: batteryMenuLoader
                    height: 0
                    opacity: 0
                  }
                }
              ]
              transitions: [
                Transition {
                  from: "collapsed"
                  to: "expanded"
                  reversible: true
                  ParallelAnimation {
                    NumberAnimation { properties: "height"; duration: 250; easing.type: Easing.Linear }
                    NumberAnimation { properties: "opacity"; duration: 150 }
                  }
                }
              ]
              Column {
                visible: batteryMenuLoader.item.height > 0 ? true : false
                anchors.fill: parent
                anchors.margins: 6
                spacing: 4
                Rectangle {
                  id: performanceProfile
                  visible: PowerProfiles.hasPerformanceProfile && batteryMenuLoader.item.height > 0 ? true : false
                  height: 28
                  width: parent.width
                  radius: 6
                  color: hovered ? "#1b473c" : "transparent"
                  property bool hovered: false
                  Text {
                    visible: batteryMenuLoader.item.height > 10 ? true : false
                    renderType: Text.NativeRendering
                    font.hintingPreference: Font.PreferFullHinting
                    text: "    Performance"
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.left: parent.left
                    anchors.leftMargin: 10
                    opacity: batteryMenuLoader.item.opacity
                    color: PowerProfiles.profile === PowerProfile.Performance ? "#3e9f85" : "#e8dcbf"
                    font.family: "Segoe UI Variable Static Display"
                    font.bold: true
                    font.pointSize: 10
                  }
                  MouseArea {
                    visible: batteryMenuLoader.item.height > 0 ? true : false
                    anchors.fill: parent
                    hoverEnabled: true
                    onEntered: parent.hovered = true
                    onExited: parent.hovered = false
                    onClicked: PowerProfiles.profile = PowerProfile.Performance
                  }
                }
                Rectangle {
                  visible: batteryMenuLoader.item.height > 0 ? true : false
                  height: 28
                  width: parent.width
                  radius: 6
                  color: hovered ? "#1b473c" : "transparent"
                  property bool hovered: false
                  Text {
                    visible: batteryMenuLoader.item.height > 49 ? true : false
                    renderType: Text.NativeRendering
                    font.hintingPreference: Font.PreferFullHinting
                    text: "    Balanced"
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.left: parent.left
                    anchors.leftMargin: 10
                    opacity: batteryMenuLoader.item.opacity
                    color: PowerProfiles.profile === PowerProfile.Balanced ? "#3e9f85" : "#e8dcbf"
                    font.family: "Segoe UI Variable Static Display"
                    font.bold: true
                    font.pointSize: 10
                  }
                  MouseArea {
                    visible: batteryMenuLoader.item.height > 0 ? true : false
                    anchors.fill: parent
                    hoverEnabled: true
                    onEntered: parent.hovered = true
                    onExited: parent.hovered = false
                    onClicked: PowerProfiles.profile = PowerProfile.Balanced

                  }
                }
                Rectangle {
                  visible: batteryMenuLoader.item.height > 0 ? true : false
                  height: 28; width: parent.width
                  radius: 6
                  color: hovered ? "#1b473c" : "transparent"
                  property bool hovered: false
                  Text {
                    visible: batteryMenuLoader.item.height > 89 ? true : false
                    renderType: Text.NativeRendering
                    font.hintingPreference: Font.PreferFullHinting
                    text: "󰌪   Power Saver"
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.left: parent.left
                    anchors.leftMargin: 10
                    opacity: batteryMenuLoader.item.opacity
                    color: PowerProfiles.profile === PowerProfile.PowerSaver ? "#3e9f85" : "#e8dcbf"
                    font.family: "Segoe UI Variable Static Display"
                    font.bold: true
                    font.pointSize: 10
                  }
                  MouseArea {
                    visible: batteryMenuLoader.item.height > 0 ? true : false
                    anchors.fill: parent
                    hoverEnabled: true
                    onEntered: parent.hovered = true
                    onExited: parent.hovered = false
                    onClicked: PowerProfiles.profile = PowerProfile.PowerSaver
                  }
                }
              }
            }
          }
          Rectangle {
            id: bluetooth
            property bool beingHover: false
            property bool isVisible: false
            anchors {
              right: batteryLoader.active ? batteryLoader.left : clock.left
              verticalCenter: bar.verticalCenter
              rightMargin: 16
            }
            height: bar.height
            width: height
            radius: height / 2
            color: beingHover ? "#34876f" : "#3e9f85"
            Text {
              renderType: Text.NativeRendering
              font.hintingPreference: Font.PreferFullHinting
              text: "󰂯"
              anchors.centerIn: parent
              font.family: "Segoe UI Variable Static Display"
              font.pointSize: 16.5
              color: parent.beingHover ? "#d1c5ab" : "#e8dcbf"
            }
            MouseArea {
              anchors.fill: parent
              hoverEnabled: true
              onEntered: parent.beingHover = true
              onExited: parent.beingHover = false
              onClicked: bluetoothMenu.visible = !bluetoothMenu.visible, topLayer.isOpen = true
            }
          }
          Rectangle {
            id: bluetoothMenu
            visible: false
            anchors.top: bluetooth.bottom
            anchors.right: bluetooth.right
            anchors.topMargin: 10
            anchors.rightMargin: -50
            color: "#24574b"
            height: 400
            width: 300
            radius: 10
            Rectangle {
              anchors.right: parent.right
              anchors.top: parent.top
              height: 15
              width: 35
              radius: height / 2
            }
          }
        }
      }
    }
  }
}
