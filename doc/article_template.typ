
#let article(
  // The date, displayed to the right.
  date: none,
  // The subject line.
  subject: none,
  // The name with which the letter closes.
  name: none,
  // The title of the letter.
  title: none,
  // Optional abstracts for the 4th cover page
  abstract_fr: none,
  abstract_en: none,
  keywords_fr: none,
  keywords_en: none,
  doc,
) = {
  // Page setup: Only number pages after the first page
  set page(
    paper: "a4",
    margin: (x: 2.5cm, top: 3cm, bottom: 2.5cm),
    header: locate(loc => {
      // No header on the first page
      if loc.page() > 1 {
        [#name #h(1fr) #date]
      }
    }),
    footer: locate(loc => {
      // No numbering on the first page
      if loc.page() > 1 {
        align(center, text(10pt)[#loc.page()])
      }
    })
  )

  set text(
    lang: "fr",
    font: "Cambria",
    size: 11pt,
  )

  set quote(block: true)
  show quote: set pad(x: 2em)

  // Consignes de mise en forme: justifié, interligne simple, espace de 10 pt après
  set par(
    leading: 0.65em,
    justify: true,
  )
  show par: set block(spacing: 10pt)

  set heading(numbering: "I.1.a")
  set list(marker: "–")

  align(center, text(17pt)[
    *#title*
  ])

  v(2em)

  doc

  // Optional 4th cover page
  if abstract_fr != none or abstract_en != none {
    pagebreak()
    set page(header: none, footer: none)
    align(center + horizon)[
      #if abstract_fr != none [
        #block(width: 90%, stroke: 0.5pt, inset: 1.5em, radius: 4pt)[
          #align(left)[
            #text(12pt, weight: "bold")[Résumé] \
            #v(0.5em)
            #text(10pt)[#abstract_fr]
            #if keywords_fr != none [
              #v(0.5em)
              #text(10pt)[*Mots-clés :* #keywords_fr]
            ]
          ]
        ]
      ]
      #v(2em)
      #if abstract_en != none [
        #block(width: 90%, stroke: 0.5pt, inset: 1.5em, radius: 4pt)[
          #align(left)[
            #text(12pt, weight: "bold")[Abstract] \
            #v(0.5em)
            #text(10pt)[#abstract_en]
            #if keywords_en != none [
              #v(0.5em)
              #text(10pt)[*Keywords:* #keywords_en]
            ]
          ]
        ]
      ]
    ]
  }
}
