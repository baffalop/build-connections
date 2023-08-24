@react.component
let make = (~group: Group.t, ~children) => {
  let toBgClass = color => `bg-${color}-400`
  let color = switch group {
  | Yellow => toBgClass("yellow")
  | Green => toBgClass("green")
  | Blue => toBgClass("blue")
  | Purple => toBgClass("purple")
  }

  <div className={`p-6 rounded-lg font-bold flex justify-center ${color}`}> {children} </div>
}
