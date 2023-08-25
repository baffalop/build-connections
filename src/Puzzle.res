type card = {group: Group.t, id: string, value: string}

type cards = array<card>

let makeCards = (values: array<array<string>>): cards => {
  Belt.Array.zip(Group.rainbow, values)->Belt.Array.flatMap(((group, row)) =>
    row->Belt.Array.mapWithIndex((i, value) => {
      group,
      id: `${Group.name(group)}-${Belt.Int.toString(i)}`,
      value: Js.String.trim(value),
    })
  )
}
