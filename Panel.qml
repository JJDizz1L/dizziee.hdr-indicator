import QtQuick
import Quickshell
import Quickshell.Hyprland
import Quickshell.Io
import qs.Ui
import qs.Commons

BarWidget {
  id: root
  moduleName: "dizziee.hdr-indicator"

  // Monitors running an HDR color management preset, read from each monitor's
  // IPC object so presets like "wide" or "srgb" stay ignored.
  readonly property var hdrMonitors: {
    const found = []
    const mons = Hyprland.monitors.values
    for (let i = 0; i < mons.length; i++) {
      // A disabled output can retain its HDR preset but is not displaying it.
      if (mons[i].disabled === true) continue
      const ipc = mons[i].lastIpcObject
      const preset = ipc ? String(ipc.colorManagementPreset || "") : ""
      if (preset === "hdr" || preset === "hdredid") found.push(String(mons[i].name))
    }
    return found
  }
  readonly property bool hdr: hdrMonitors.length > 0

  function refresh() {
    Hyprland.refreshMonitors()
  }

  Component.onCompleted: root.refresh()

  Connections {
    target: Hyprland
    function onRawEvent(event) {
      if (!event || !event.name) return
      var name = String(event.name)
      // Monitor connect/disconnect and full reloads are announced; a runtime
      // cm change is not, so that path pokes us directly over IPC (see the
      // IpcHandler below) instead of being polled for.
      if (name.indexOf("monitor") === 0 || name === "configreloaded") root.refresh()
    }
  }

  // Direct poke entry point for the SUPER+ALT+B toggle (toggle-hdr.lua): the
  // SDR->HDR path re-asserts the monitor at runtime, which Hyprland does not
  // announce on socket2, so the toggle tells us the instant it flips instead
  // of us polling for it.
  IpcHandler {
    target: root.moduleName

    function refresh(): void { root.refresh() }
  }

  // Safety net only: catches cm changes made outside the toggle and the
  // socket events above (e.g. a raw `hyprctl keyword` flip). One cheap read
  // over the persistent IPC socket every two minutes — no hyprctl spawns.
  Timer {
    interval: 120000
    running: true
    repeat: true
    onTriggered: root.refresh()
  }

  visible: hdr

  implicitWidth: visible ? button.implicitWidth : 0
  implicitHeight: visible ? button.implicitHeight : 0

  WidgetButton {
    id: button
    anchors.fill: parent
    bar: root.bar
    text: "󱝁"
    fixedWidth: root.bar && root.bar.vertical ? -1 : Style.space(27)
    fixedHeight: root.bar && root.bar.vertical ? Style.space(26) : -1
    tooltipText: root.hdr ? "HDR enabled (" + root.hdrMonitors.join(", ") + ")" : "HDR disabled"
  }
}
