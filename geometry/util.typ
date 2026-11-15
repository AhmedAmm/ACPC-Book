// Shared helpers for the geometry chapter.

// Math operators used in the formulas.
#let orient = math.op("orient")
#let side = math.op("side")
#let dist = math.op("dist")
#let proj = math.op("proj")
#let refl = math.op("refl")
#let rot = math.op("rot")
#let pw = math.op("pow")
#let cis = math.op("cis")
#let atan2 = math.op("atan2")
#let cline = math.op(raw("line"))

// Code listing from geometry/code/.
#let code(name) = raw(read("code/" + name), lang: "cpp", block: true)

// Formula table: `title` is the header row, then cells row by row.
// Default is two columns: what | formula.
#let ftable(title: none, columns: (31%, 1fr), ..cells) = {
  set text(size: 0.9em)
  set table.cell(breakable: false)
  show math.equation.where(block: true): set align(left)
  show math.equation.where(block: true): set block(spacing: 0.55em)
  table(
    columns: columns,
    stroke: 0.4pt + luma(150),
    inset: (x: 4pt, y: 4pt),
    align: left + horizon,
    ..if title != none {
      (table.header(table.cell(colspan: columns.len(), fill: luma(228), strong(title))),)
    },
    ..cells.pos(),
  )
}

// Same, with the first column sized to its content (function names).
#let ntable = ftable.with(columns: (auto, 1fr))
