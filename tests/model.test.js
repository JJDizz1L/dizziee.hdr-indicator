// Run with: node --test tests/
const test = require("node:test")
const assert = require("node:assert/strict")
const Model = require("../Model.js")

test("cleanMonitorName bounds and rejects bad values", () => {
  assert.equal(Model.cleanMonitorName("DP-1"), "DP-1")
  assert.equal(Model.cleanMonitorName("  HDMI-A-1  "), "HDMI-A-1")
  assert.equal(Model.cleanMonitorName(""), "")
  assert.equal(Model.cleanMonitorName(null), "")
  assert.equal(Model.cleanMonitorName("x".repeat(100)).length, Model.MAX_NAME_LEN)
})

test("markup-shaped monitor names stay inert text", () => {
  const evil = '<img src="https://example.invalid/tracker">'
  assert.equal(Model.cleanMonitorName(evil), evil)
  // PlainText tooltip sink renders this literally; never executed.
  assert.match(Model.cleanMonitorName(evil), /<img/)
})

test("cleanMonitorList dedups and caps", () => {
  const many = Array.from({ length: 20 }, (_, i) => "MON-" + (i % 5))
  const cleaned = Model.cleanMonitorList(many)
  assert.equal(cleaned.length, 5)
  assert.deepEqual(cleaned, ["MON-0", "MON-1", "MON-2", "MON-3", "MON-4"])
})
