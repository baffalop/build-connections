%%raw(`import './App.css'`)

@react.component
let make = () => {
  <div className="m-8 grid gap-6 grid-cols-4 max-w-lg">
    {Belt.Array.range(0, 15)
    ->Belt.Array.map(i =>
      <div className="p-6 bg-white border border-neutral-300 rounded-lg"> {React.int(i + 1)} </div>
    )
    ->React.array}
  </div>
}
