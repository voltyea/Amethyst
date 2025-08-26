pragma Singleton

import Quickshell
import QtQuick

Singleton {

  readonly property string time: Qt.formatDateTime(clock.date, "ddd MMM dd  hh:mm:ss AP")

  readonly property string day: Qt.formatDateTime(clock.date, "dddd")

  SystemClock {
    id: clock
    precision: SystemClock.Seconds
  }
}
