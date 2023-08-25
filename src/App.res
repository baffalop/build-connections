%%raw(`import './App.css'`)

@react.component
let make = () => {
  <div className="m-8 grid gap-4 grid-cols-4 max-w-lg">
    {Group.rainbow
    ->Belt.Array.flatMap(group => {
      Belt.Array.range(0, 3)->Belt.Array.map(i =>
        <CardInput group> {Belt.Int.toString(i + 1)} </CardInput>
      )
    })
    ->React.array}
  </div>
}
