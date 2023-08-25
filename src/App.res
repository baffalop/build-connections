%%raw(`import './App.css'`)

@react.component
let make = () => {
  let (values, setValues) = React.useState(() =>
    Belt.Array.range(0, 3)->Belt.Array.map(_ => Belt.Array.make(4, ""))
  )

  let setValue = (row, col, value) => {
    setValues(values => {
      let rowValue = Belt.Array.getExn(values, row)
      Belt.Array.concatMany([
        Belt.Array.slice(values, ~offset=0, ~len=row),
        [
          Belt.Array.concatMany([
            Belt.Array.slice(rowValue, ~offset=0, ~len=col),
            [value],
            Belt.Array.sliceToEnd(rowValue, col + 1),
          ]),
        ],
        Belt.Array.sliceToEnd(values, row + 1),
      ])
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
