open Vitest
open Puzzle

include Matchers({
  type return<'a> = cardId
  let emptyReturn = CardId(Group.Yellow, 0)
})

describe("inCanonicalOrder", () => {
  test("sorts ids in same group by index", _ => {
    let _ =
      [
        CardId(Group.Green, 1),
        CardId(Group.Green, 0),
        CardId(Group.Green, 3),
        CardId(Group.Green, 2),
      ]
      ->inCanonicalOrder
      ->expect
      ->toEqual([
        CardId(Group.Green, 0),
        CardId(Group.Green, 1),
        CardId(Group.Green, 2),
        CardId(Group.Green, 3),
      ])
  })

  test("one id of wrong group but correct index goes in index position", _ => {
    let _ =
      [
        CardId(Group.Green, 1),
        CardId(Group.Green, 0),
        CardId(Group.Green, 3),
        CardId(Group.Blue, 2),
      ]
      ->inCanonicalOrder
      ->expect
      ->toEqual([
        CardId(Group.Green, 0),
        CardId(Group.Green, 1),
        CardId(Group.Blue, 2),
        CardId(Group.Green, 3),
      ])
  })

  test("one id of wrong group and duplicate index fills index position of matching group", _ => {
    let _ =
      [
        CardId(Group.Green, 1),
        CardId(Group.Green, 0),
        CardId(Group.Green, 3),
        CardId(Group.Blue, 0),
      ]
      ->inCanonicalOrder
      ->expect
      ->toEqual([
        CardId(Group.Green, 0),
        CardId(Group.Green, 1),
        CardId(Group.Blue, 0),
        CardId(Group.Green, 3),
      ])
  })

  test("one id of wrong group fills index position, when groups are reversed", _ => {
    let _ =
      [
        CardId(Group.Green, 0),
        CardId(Group.Purple, 2),
        CardId(Group.Purple, 3),
        CardId(Group.Purple, 0),
      ]
      ->inCanonicalOrder
      ->expect
      ->toEqual([
        CardId(Group.Purple, 0),
        CardId(Group.Green, 0),
        CardId(Group.Purple, 2),
        CardId(Group.Purple, 3),
      ])
  })

  test("when there are 2 of each group, earlier group takes precedence", _ => {
    let _ =
      [
        CardId(Group.Green, 1),
        CardId(Group.Yellow, 1),
        CardId(Group.Green, 0),
        CardId(Group.Yellow, 3),
      ]
      ->inCanonicalOrder
      ->expect
      ->toEqual([
        CardId(Group.Green, 0),
        CardId(Group.Yellow, 1),
        CardId(Group.Green, 1),
        CardId(Group.Yellow, 3),
      ])
  })

  test("when there are 2 of one group, 2 of different groups, different groups fill places", _ => {
    let _ =
      [
        CardId(Group.Blue, 1),
        CardId(Group.Green, 1),
        CardId(Group.Yellow, 3),
        CardId(Group.Blue, 2),
      ]
      ->inCanonicalOrder
      ->expect
      ->toEqual([
        CardId(Group.Yellow, 3),
        CardId(Group.Blue, 1),
        CardId(Group.Blue, 2),
        CardId(Group.Green, 1),
      ])
  })
})
