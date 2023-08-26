type row = {title: string, values: array<string>}
type rows = list<(Group.t, row)>

let blankRow = {title: "", values: Belt.Array.make(4, "")}
let blankRows = Group.rainbow->List.fromArray->List.map(group => (group, blankRow))

let eq = (a, b) => a == b
let getRow = (rows: rows, group: Group.t): row => List.getAssoc(rows, group, eq)->Option.getExn
let setRow = (rows: rows, group: Group.t, row: row): rows => List.setAssoc(rows, group, row, eq)
let mapRow = (rows: rows, group: Group.t, f: row => row) =>
  setRow(rows, group, getRow(rows, group)->f)

let setValue = (rows: rows, group: Group.t, col: int, value: string) =>
  mapRow(rows, group, row => {
    ...row,
    values: Utils.Array.setAt(row.values, col, value),
  })
let setTitle = (rows: rows, group: Group.t, title: string) =>
  mapRow(rows, group, row => {...row, title})

type cardId = CardId(Group.t, int)

type card = {group: Group.t, id: cardId, value: string}
type cards = array<card>

type solved = {group: Group.t, cards: array<string>}

let makeCards = (rows: rows): cards => {
  List.toArray(rows)->Belt.Array.flatMap(((group, {values})) =>
    values->Belt.Array.mapWithIndex((i, value) => {
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
