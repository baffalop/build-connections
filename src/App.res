type step =
  | Create
  | Game(Puzzle.connections)

@react.component
let make = () => {
  let (step, setStep) = React.useState(() => Create)

  <div className="p-3 w-screen max-w-screen-sm">
    {switch step {
    | Create => <Create onCreate={connections => setStep(_ => Game(connections))} />
    | Game(connections) => <Game connections />
    }}
  </div>
}
