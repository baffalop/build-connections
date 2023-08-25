type t = Yellow | Green | Blue | Purple

let rainbow = [Yellow, Green, Blue, Purple]

let name = g =>
  switch g {
  | Yellow => "yellow"
  | Green => "green"
  | Blue => "blue"
  | Purple => "purple"
  }
