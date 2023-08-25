type t = Yellow | Green | Blue | Purple

let rainbow = [Yellow, Green, Blue, Purple]

let name = group =>
  switch group {
  | Yellow => "yellow"
  | Green => "green"
  | Blue => "blue"
  | Purple => "purple"
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
