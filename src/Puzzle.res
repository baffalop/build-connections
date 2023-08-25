type cardId = CardId(Group.t, int)

type card = {group: Group.t, id: cardId, value: string}
type cards = array<card>

let makeCards = (values: array<array<string>>): cards => {
  Belt.Array.zip(Group.rainbow, values)->Belt.Array.flatMap(((group, row)) =>
    row->Belt.Array.mapWithIndex((i, value) => {
      group,
      id: CardId(group, i),
      value: Js.String.trim(value),
    })
  )
}

let cardKey = id =>
  switch id {
  | CardId(group, i) => `${Group.name(group)}-${Belt.Int.toString(i)}`
  }
