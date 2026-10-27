// Monitor names come from Hyprland IPC (local, but not ours to trust).
// Keep the tooltip list tiny and every name a plain bounded string.
var MAX_MONITORS = 16
var MAX_NAME_LEN = 64

function cleanMonitorName(value) {
  if (typeof value !== "string") return ""
  var name = value.trim()
  if (!name) return ""
  if (name.length > MAX_NAME_LEN) name = name.slice(0, MAX_NAME_LEN)
  return name
}

function cleanMonitorList(values) {
  var out = []
  var seen = {}
  var list = Array.isArray(values) ? values : []
  for (var i = 0; i < list.length && out.length < MAX_MONITORS; i++) {
    var name = cleanMonitorName(list[i])
    if (!name || seen[name]) continue
    seen[name] = true
    out.push(name)
  }
  return out
}

if (typeof module !== "undefined") {
  module.exports = {
    cleanMonitorName: cleanMonitorName,
    cleanMonitorList: cleanMonitorList,
    MAX_MONITORS: MAX_MONITORS,
    MAX_NAME_LEN: MAX_NAME_LEN
  }
}
