#import "@preview/summy:0.1.0": *
#import "@preview/codly:2.0.0" as codly
#import "@preview/codly-languages:0.1.10": *
#show: codly.set_(number-enabled: false)
#show: codly.lang-set_(display-name: false)
// #show: codly.line-set_(fill: none)
// #show: codly.line-set_(fill: (luma(248), white))

#show raw.where(block: true): codly.new


#set text(font: "Libertinus Serif")
// #show raw: set text(font: "JetBrainsMono NF") 

#set page(numbering: "1", number-align: right)
#show: cheatsheet.with(
  title: "Cheatsheet Title",
  authors: "Authors",
  write-title: false,
  font-size: 13.0pt,
  line-skip: 5.5pt,
  x-margin: 10pt,
  y-margin: 20pt,
  num-columns: 2,
  column-gutter: 4pt,
  numbered-units: false,
)

#heading(outlined: false)[Table of Contents]
#outline()

#colbreak()
#colbreak()
#include "math/math.typ"


