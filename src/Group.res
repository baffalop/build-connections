type t =
  | @as("yellow") Yellow
  | @as("green") Green
  | @as("blue") Blue
  | @as("purple") Purple

let rainbow = list{Yellow, Green, Blue, Purple}

let name = group =>
  switch group {
  | Yellow => "yellow"
  | Green => "green"
  | Blue => "blue"
  | Purple => "purple"
  }

let shortName = group => group->name->String.charAt(0)

let fromShortName = group =>
  switch group {
  | "y" => Some(Yellow)
  | "g" => Some(Green)
  | "b" => Some(Blue)
  | "p" => Some(Purple)
  | _ => None
  }

let swatch = group =>
  switch group {
  | Yellow => "🟨"
  | Green => "🟩"
  | Blue => "🟦"
  | Purple => "🟪"
  }

let bgColor = group => {
  let toBg = color => `bg-${color}-400`

  switch group {
  | Yellow => toBg("yellow")
  | Green => toBg("green")
  | Blue => toBg("blue")
  | Purple => toBg("purple")
  }
}

let bgColorLight = group => {
  let toBg = color => `bg-${color}-300`

  switch group {
  | Yellow => toBg("yellow")
  | Green => toBg("green")
  | Blue => toBg("blue")
  | Purple => toBg("purple")
  }
}

let bgColorDark = group => {
  let toBg = color => `bg-${color}-600`

  switch group {
  | Yellow => toBg("yellow")
  | Green => toBg("green")
  | Blue => toBg("blue")
  | Purple => toBg("purple")
  }
}

let iconColorDark = group => {
  let toColor = color => `text-${color}-600 hover:text-${color}-700`

  switch group {
  | Yellow => toColor("yellow")
  | Green => toColor("green")
  | Blue => toColor("blue")
  | Purple => toColor("purple")
  }
}

let index = group =>
  switch group {
  | Yellow => 0
  | Green => 1
  | Blue => 2
  | Purple => 3
  }
