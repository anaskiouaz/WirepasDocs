
#let article(
  // The date, displayed to the right.
  date: none,
  // The subject line.
  subject: none,
  // The name with which the letter closes.
  name: none,
  // The title of the letter.
  title: none,
  // The body of the letter.
  doc,
) = {
  set page(
    paper: "a4",
    header: [#name
      #h(1fr)
      #date],
    numbering: "1",
    margin: 10mm,
  )

  set text(
    lang: "fr",
    font: "Cambria",
    size: 11pt,
  )

  set quote(block: true)
  show quote: set pad(x: 2em)

  set par(
    leading: 0.78em,
    first-line-indent: 12pt,
    justify: true,
  )

  set heading(numbering: "I.1.a")
  set list(marker: "–")

  align(center, text(17pt)[
    *#title*
  ])

  v(2em)

  doc
}
