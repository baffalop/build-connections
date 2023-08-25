%%raw(`import './App.css'`)

module Utils = {
  module Array = {
    let setAt = (ar, i, v) => {
      Belt.Array.concatMany([
        Belt.Array.slice(ar, ~offset=0, ~len=i),
        [v],
        Belt.Array.sliceToEnd(ar, i + 1),
      ])
    }

    let append = (ar, a) => Belt.Array.concat(ar, [a])
  }
}

@react.component
let make = () => {
  let (values, setValues) = React.useState(() =>
    Belt.Array.range(0, 3)->Belt.Array.map(_ => Belt.Array.make(4, ""))
  )

  let setValue = (row, col, value) => {
    setValues(values => {
      Utils.Array.setAt(values, row, Belt.Array.getExn(values, row)->Utils.Array.setAt(col, value))
    })
  }

  let clearRow = row => setValues(Utils.Array.setAt(_, row, Belt.Array.make(4, "")))

  <div className="m-8 grid gap-4 grid-cols-[1fr_1fr_1fr_1fr_auto] max-w-lg">
    {Belt.Array.zip(Group.rainbow, values)
    ->Belt.Array.mapWithIndex((row, (group, groupValues)) => {
      Belt.Array.mapWithIndex(groupValues, (col, value) => {
        let key = `${Group.name(group)}-${Belt.Int.toString(col)}`
        <CardInput key group value onInput={setValue(row, col, _)} />
      })->Utils.Array.append(
        <button
          type_="button"
          className="rounded-full px-1.5 text-white font-bold bg-neutral-400 hover:bg-neutral-500 self-center justify-self-center"
          onClick={_ => clearRow(row)}>
          {React.string("×")}
        </button>,
      )
    })
    ->Belt.Array.concatMany
    ->React.array}
  </div>
}
