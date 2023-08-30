type connection = {title: string, values: array<string>}
type connections = list<(Group.t, connection)>

let blankRow = {title: "", values: Belt.Array.make(4, "")}
let blankRows = Group.rainbow->List.map(group => (group, blankRow))

let eq = (a, b) => a == b
let getRow = (rows: connections, group: Group.t): connection =>
  List.getAssoc(rows, group, eq)->Option.getExn
let setRow = (rows: connections, group: Group.t, row: connection): connections =>
  List.setAssoc(rows, group, row, eq)
let mapRow = (rows: connections, group: Group.t, f: connection => connection) =>
  setRow(rows, group, getRow(rows, group)->f)

let setValue = (rows: connections, group: Group.t, col: int, value: string) =>
  mapRow(rows, group, row => {
    ...row,
    values: Utils.Array.setAt(row.values, col, value),
  })
let setTitle = (rows: connections, group: Group.t, title: string) =>
  mapRow(rows, group, row => {...row, title})

type cardId = CardId(Group.t, int)

type card = {group: Group.t, id: cardId, value: string}
type cards = array<card>

type solution = {group: Group.t, title: string, values: array<string>}
type solved = array<solution>

let makeCards = (rows: connections): cards => {
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

let decode: string => result<connections, Funicular.Decode.jsonParseError> = slug => {
  open Funicular.Decode

  parse(slug, value => {
    array(value => {
      let o = value->object_
      let title = o->field("t", string)
      let values = o->field("v", array(string, _))

      rmap((title, values) => {title, values})->v(title)->v(values)
    }, value)
  })->Result.map(connections => {
    connections->List.fromArray->List.zip(Group.rainbow, _)
  })
}

let encode = (connections: connections) => {
  open Funicular.Encode

  connections
  ->List.toArray
  ->array(((_, {title, values})) => object_([("t", string(title)), ("v", array(values, string))]))
}
