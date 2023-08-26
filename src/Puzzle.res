type cardId = CardId(Group.t, int)

type card = {group: Group.t, id: cardId, value: string}
type cards = array<card>

type solved = {group: Group.t, cards: array<string>}

let makeCards = (values: array<array<string>>): cards => {
  Belt.Array.zip(Group.rainbow, values)->Belt.Array.flatMap(((group, row)) =>
    row->Belt.Array.mapWithIndex((i, value) => {
      group,
      id: CardId(group, i),
      value: Js.String.trim(value),
    })
  )
}

let cardKey = (CardId(group, i)) => `${Group.name(group)}-${Belt.Int.toString(i)}`

let matchingGroup = (cards: cards): option<Group.t> => {
  let match = cards->Belt.Array.reduce(#unknown, (match, {group}) =>
    switch match {
    | #unknown => #match(group)
    | #noMatch => #noMatch
    | #match(matched) => matched == group ? match : #noMatch
    }
  )
  switch match {
  | #match(group) => Some(group)
  | _ => None
  }
}
