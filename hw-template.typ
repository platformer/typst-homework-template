// counter to track the total number of problems,
//   regardless of problem titles
#let _problem-count-ckey = "_problem-count"

// counter to track problem number
#let _problem-number-ckey = "_problem-number"

// state value to store height of content area
#let _content-area-size = state("_hw-content-area-size", none)

// Creates a problem header with automatic numbering.
//
// Parameters:
//   body: Text to place in header.
//     Defaults to "{supplement} {problem number}".
//   supplement: Content to precede the problem number.
//     Defaults to "Problem".
//   inset: Inner padding.
//   fill: Fill color.
//   stroke: Border stroke.
//   header-margin-bottom: Space below header.
#let problem-header(
  body: none,
  supplement: "Problem",
  inset: 12pt,
  fill: none,
  stroke: 2pt + black,
  header-margin-bottom: 20pt,
) = {
  counter(_problem-count-ckey).step()

  if body == none {
    counter(_problem-number-ckey).step()
  }

  rect(
    width: 100%,
    height: auto,
    inset: inset,
    outset: 0pt,
    fill: fill,
    stroke: stroke
  )[
    #text(weight: 700, size: 1.5em)[
      #if body != none {
        body
      } else {
        [#supplement #counter(_problem-number-ckey).display()]
      }
    ]
  ]

  v(weak: true, header-margin-bottom)
}


// Combines a problem-header with a body for the problem resopnse.
//
// Parameters:
//   body: Problem response.
//   title: Title of the problem.
//     Defaults to "{supplement} {problem number}".
//   supplement: Content to precede the problem number.
//     Defaults to "Problem".
//   break-strategy: Pagebreak strategy. Ignored for first problem.
//     "break":     insert pagebreak before problem
//     "no-break":  place problem directly after preceding content
//     "fit":       pagebreak only if problem cannot fit on the page
//   header-margin-bottom: Space below problem header.
//   problem-margin-bottom: Space below problem response.
#let problem(
  body,
  title: none,
  supplement: "Problem",
  break-strategy: "break",
  header-margin-bottom: 20pt,
  problem-margin-bottom: 30pt,
) = {
  assert(
    (
      break-strategy == "break"
      or break-strategy == "no-break"
      or break-strategy == "fit"
    ),
    message: "break-strategy must be \"break\" or \"no-break\" or \"fit\""
  )

  // combine problem header and response
  let problem-content = [
    #if title != none {
      problem-header(
        body: title,
        supplement: supplement,
        header-margin-bottom: header-margin-bottom,
      )
    } else {
      problem-header(
        supplement: supplement,
        header-margin-bottom: header-margin-bottom,
      )
    }

    #body
  ]

  // place problem-content based on page break strategy
  counter(_problem-count-ckey).display(prob-num => {
    if prob-num == 0 or break-strategy == "no-break" {
      problem-content
    } else if break-strategy == "break" {
      pagebreak(weak: true)
      problem-content
    } else if break-strategy == "fit" {
      _content-area-size.display(size => style(styles => {
        let content-height = measure(
          block(width: size.width, problem-content),
          styles
        ).height

        if content-height > size.height {
          pagebreak(weak: true)
          problem-content
        } else {
          block(breakable: false)[#problem-content]
        }
      }))
    }

    v(weak: true, problem-margin-bottom)
  })
}


// Homework document template.
//
// Parameters:
//   doc: Document content.
//   title: Document Title.
//   number: Homework number.
//   class: Class name.
//   authors: List of author names.
//   date: Date string.
#let hw(
  doc,
  title: "Homework",
  number: none,
  class: none,
  authors: (),
  date: none
) = {
  // PLEASE CHANGE PAGE DIMENSIONS HERE
  // DON'T SET paper PARAMETER IN page
  let paper-width = 8.5in
  let paper-height = 11in
  let margin = (x: 1.25in, y: 1in)

  let real_title = title + " " + str(number)

  set document(
    author: authors,
    title: real_title
  )

  set page(
    "us-letter",
    width: paper-width,
    height: paper-height,
    margin: margin,
    numbering: "1",
    header: locate(loc =>
      if loc.page() != 1 {
        align(right)[#text(size: 10pt)[
          #class\
          #real_title\
          #authors.fold("", (acc, author) => acc + h(1em) + author)
        ]]
      }
    )
  )

  set par(
    first-line-indent: 0in,
    justify: true,
  )

  set text(
    size: 12pt,
  )

  set heading(
    numbering: none,
  )

  _content-area-size.update((
    width: paper-width - margin.at("x") * 2,
    height: paper-height - margin.at("y") * 2
  ))

  // title
  align(center)[
    #block(text(weight: 700, 1.75em, real_title))
  ]

  // class info
  align(center)[
    #class
  ]

  // date
  align(center)[
    #date
  ]

  // Author information.
  pad(
    top: 0.5em,
    bottom: 0.5em,
    grid(
      columns: (1fr,) * calc.min(3, authors.len()),
      gutter: 1em,
      ..authors.map(author => align(center, strong(author))),
    ),
  )

  doc
}
