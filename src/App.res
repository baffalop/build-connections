%%raw(`import './App.css'`)

let arraySetAt = (ar, i, v) => {
  Belt.Array.concatMany([
    Belt.Array.slice(ar, ~offset=0, ~len=i),
    [v],
    Belt.Array.sliceToEnd(ar, i + 1),
  ])
}

@react.component
let make = () => {
  let (values, setValues) = React.useState(() =>
    Belt.Array.range(0, 3)->Belt.Array.map(_ => Belt.Array.make(4, ""))
  )

  let setValue = (row, col, value) => {
    setValues(values => {
      arraySetAt(values, row, Belt.Array.getExn(values, row)->arraySetAt(col, value))
    })
  }

  <div className="m-8 grid gap-4 grid-cols-4 max-w-lg">
    {Belt.Array.zip(Group.rainbow, values)
    ->Belt.Array.mapWithIndex((row, (group, groupValues)) => {
      Belt.Array.mapWithIndex(groupValues, (col, value) => {
        let key = `${Group.name(group)}-${Belt.Int.toString(col)}`
        <CardInput key group value onInput={setValue(row, col, _)} />
      })
    })
    ->Belt.Array.concatMany
    ->React.array}
  </div>
}
