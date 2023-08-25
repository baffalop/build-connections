module Array = {
  let setAt = (ar, i, v) => {
    Belt.Array.concatMany([
      Belt.Array.slice(ar, ~offset=0, ~len=i),
      [v],
      Belt.Array.sliceToEnd(ar, i + 1),
    ])
  }

  let append = (ar, a) => Belt.Array.concat(ar, [a])
}
