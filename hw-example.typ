#import "hw-template.typ": hw, problem

// using hw template
#show: doc => hw(
  doc,
  number: 1,
  class: "Typst 101 Fall 2023",
  authors: (
    "Your Name (id 00001)",
  ),
  date: "August 30, 2023"
)

#problem()[
  #lorem(100)
]

// "break" starts the problem on the next page
#problem(break-strategy: "break")[
  #lorem(100)
]

// "no-break" starts the problem on the current page
#problem(break-strategy: "no-break")[
  #lorem(400)
]

// "fit" will only start the problem on the next page
// if it doesn't fit on the current page
#problem(break-strategy: "fit")[
  #set enum(numbering: "a)")
  + #lorem(10)

  + #lorem(10)

  + #lorem(10)
]

#problem(break-strategy: "fit")[
  #lorem(50)
]

#problem(break-strategy: "fit")[
  #lorem(200)
]

#problem(title: "Bonus", break-strategy: "break")[
  #lorem(300)
]
