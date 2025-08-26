//@pragma UseQApplication

import Quickshell
import QtQuick
import Quickshell.Hyprland
import Quickshell.Wayland
import QtCharts
import Quickshell.Io
import Quickshell.Services.UPower
import QtQuick.Layouts
import QtQuick.Shapes
import QtQuick.Controls
import Qt.labs.folderlistmodel

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
        cache: false
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
        mask: Region {
          shape: RegionShape.Rect
          item: bar
          intersection: Intersection.Combine
        }

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
            anchors {
              right: parent.right
              verticalCenter: parent.verticalCenter
              rightMargin: 16
            }
            height: parent.height
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
              onClicked: powerButton.isVisible = !powerButton.isVisible
            }
          }






        }

        Rectangle {
          id: powerMenu
          anchors.right: bar.right
          anchors.top: bar.bottom
          height: 100
          width: 150
          visible: powerButton.isVisible
          color: "#24574b"
          radius: 10

          Column {
            anchors.fill: parent
            anchors.margins: 6
            spacing: 4
            visible: parent.opacity > 0

            Rectangle {
              height: 28; width: parent.width
              radius: 6
              color: hovered ? "#204c41" : "transparent"
              visible: parent.visible
              property bool hovered: false
              Text {
                renderType: Text.NativeRendering
                font.hintingPreference: Font.PreferFullHinting
                text: "Shutdown"
                anchors.verticalCenter: parent.verticalCenter
                anchors.left: parent.left
                anchors.leftMargin: 10
                color: "#e8dcbf"
                visible: parent.visible
                font.family: "Segoe UI Variable Static Display"
                font.bold: true
                font.pointSize: 10
              }
              MouseArea {
                anchors.fill: parent
                hoverEnabled: true
                visible: parent.visible
                onEntered: parent.hovered = true
                onExited: parent.hovered = false
                onClicked: Quickshell.execDetached(["bash", "-c", "poweroff"])
              }
            }

            Rectangle {
              height: 28; width: parent.width
              radius: 6
              visible: parent.visible
              color: hovered ? "#204c41" : "transparent"
              property bool hovered: false
              Text {
                renderType: Text.NativeRendering
                font.hintingPreference: Font.PreferFullHinting
                text: "Reboot"
                anchors.verticalCenter: parent.verticalCenter
                anchors.left: parent.left
                anchors.leftMargin: 10
                color: "#e8dcbf"
                visible: parent.visible
                font.family: "Segoe UI Variable Static Display"
                font.bold: true
                font.pointSize: 10
              }

              MouseArea {
                anchors.fill: parent
                hoverEnabled: true
                visible: parent.visible
                onEntered: parent.hovered = true
                onExited: parent.hovered = false
                onClicked: Quickshell.execDetached(["bash", "-c", "reboot"])

              }
            }

            Rectangle {
              height: 28; width: parent.width
              radius: 6
              visible: parent.visible
              color: hovered ? "#204c41" : "transparent"
              property bool hovered: false
              Text {
                renderType: Text.NativeRendering
                font.hintingPreference: Font.PreferFullHinting
                text: "Sleep"
                visible: parent.visible
                anchors.verticalCenter: parent.verticalCenter
                anchors.left: parent.left
                anchors.leftMargin: 10
                color: "#e8dcbf"
                font.family: "Segoe UI Variable Static Display"
                font.bold: true
                font.pointSize: 10
              }
              MouseArea {
                anchors.fill: parent
                hoverEnabled: true
                visible: parent.visible
                onEntered: parent.hovered = true
                onExited: parent.hovered = false
                onClicked: Quickshell.execDetached(["bash", "-c", "systemctl suspend"])
              }
            }
          }
        }





      }
    }
  }
}
