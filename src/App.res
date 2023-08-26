type step =
  | Create
  | Game(Puzzle.cards)

@react.component
let make = () => {
  let (step, setStep) = React.useState(() => Create)

  <div className="m-10 w-max max-w-screen">
    {switch step {
    | Create => <Create onCreate={cards => setStep(_ => Game(cards))} />
    | Game(cards) => <Game cards />
    }}
  </div>
}
