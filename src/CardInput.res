@react.component
let make = (~group: Group.t, ~value: string, ~onInput: string => unit) => {
  let toBgClass = color => `bg-${color}-400 focus:bg-${color}-300`
  let color = switch group {
  | Yellow => toBgClass("yellow")
  | Green => toBgClass("green")
  | Blue => toBgClass("blue")
  | Purple => toBgClass("purple")
  }

  <input
    className={`p-6 rounded-lg font-bold flex justify-center ${color} appearance-none outline-none`}
    value
    onInput={e => ReactEvent.Form.currentTarget(e)["value"]->onInput}
  />
}
