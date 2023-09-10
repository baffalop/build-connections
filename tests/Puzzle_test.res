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
})
