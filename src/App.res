type step =
  | Create
  | Game(Puzzle.connections)

@react.component
let make = () => {
  open RescriptReactRouterDom.ReactRouterDOM

  let (step, setStep) = React.useState(() => Create)

  <div
    className="p-3 min-h-screen w-screen max-w-screen-sm mx-auto flex flex-col items-stretch justify-center">
    {switch step {
    | Create => <Create onCreate={connections => setStep(_ => Game(connections))} />
    | Game(connections) => <Game connections />
    }}
  </div>
}
