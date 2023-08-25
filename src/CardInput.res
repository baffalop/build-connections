@react.component
let make = (~group: Group.t, ~value: string, ~onInput: string => unit) => {
  let toBg = color => `bg-${color}-400 focus-within:bg-${color}-300`
  let (bg, border) = switch group {
  | Yellow => (toBg("yellow"), "focus:border-yellow-600")
  | Green => (toBg("green"), "focus:border-green-600")
  | Blue => (toBg("blue"), "focus:border-blue-600")
  | Purple => (toBg("purple"), "focus:border-purple-600")
  }

  <div className={`p-2 rounded-lg ${bg}`}>
    <input
      type_="text"
      value
      onInput={e => ReactEvent.Form.currentTarget(e)["value"]->onInput}
      className={`p-4 rounded-md bg-transparent font-medium flex justify-center appearance-none outline-none uppercase
        border border-dashed border-transparent ${border}`}
    />
  </div>
}
