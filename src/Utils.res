module Id = {
  let eq = (a, b) => a == b
}

module Tuple = {
  let fst = ((a, _)) => a
  let snd = ((_, b)) => b
}

module Array = {
  let setAt = (ar, i, v) => {
    Belt.Array.concatMany([
      Belt.Array.slice(ar, ~offset=0, ~len=i),
      [v],
      Belt.Array.sliceToEnd(ar, i + 1),
    ])
  }

  let append = (ar, a) => Belt.Array.concat(ar, [a])

  let last = ar => ar[Belt.Array.length(ar) - 1]

  let groupBy = (ar: array<'a>, f: 'a => 'b): list<('b, array<'a>)> =>
    ar->Belt.Array.reduce(list{}, (grouped, item) => {
      let disc = f(item)
      let group = grouped->List.getAssoc(disc, Id.eq)->Option.getWithDefault([])->append(item)
      grouped->List.setAssoc(disc, group, Id.eq)
    })

  let sortBy = (ar: array<'a>, f: 'a => int): array<'a> =>
    ar->List.fromArray->List.sort((a, b) => f(a) - f(b))->List.toArray

  type match<'a> =
    | NoMatch
    | OneAway('a, 'a)
    | Match('a)

  let matchBy = (ar: array<'a>, f: 'a => 'b): match<'b> =>
    switch ar->groupBy(f) {
    | list{(matched, _)} => Match(matched)
    | list{(outlier, [_]), (matched, _)}
    | list{(matched, _), (outlier, [_])} =>
      OneAway(matched, outlier)
    | _ => NoMatch
    }

  let matchAllBy = (ar: array<'a>, f: 'a => 'b): option<'b> => {
    let match = ar->Belt.Array.reduce(#unknown, (match, item) =>
      switch match {
      | #unknown => #match(item->f)
      | #noMatch => #noMatch
      | #match(matched) => matched == f(item) ? match : #noMatch
      }
    )

    switch match {
    | #match(property) => Some(property)
    | _ => None
    }
  }

  let eqSets = (a1: array<'a>, a2: array<'a>): bool => {
    a1->Belt.Array.every(x1 => a2->Belt.Array.some(x2 => x1 == x2))
  }

  let chain = (ar: array<'a>, initial: 'b, f: ('b, 'a) => promise<'b>): promise<'b> =>
    ar->Belt.Array.reduce(Promise.resolve(initial), async (previous, x) =>
      await f(await previous, x)
    )

  let sequence = (ar: array<'a>, f: 'a => promise<unit>): promise<unit> =>
    chain(ar, (), (_, x) => f(x))
}

module Result = {
  let fromOption: (option<'a>, 'e) => result<'a, 'e> = (option, error) => {
    switch option {
    | Some(v) => Ok(v)
    | None => Error(error)
    }
  }

  let toOption: result<'a, 'e> => option<'a> = res =>
    switch res {
    | Ok(v) => Some(v)
    | Error(_) => None
    }

  let mapError: (result<'a, 'e1>, 'e1 => 'e2) => result<'a, 'e2> = (result, map) => {
    switch result {
    | Ok(v) => Ok(v)
    | Error(e) => map(e)->Error
    }
  }
}

module Time = {
  let wait = (duration: int) =>
    Promise.make((resolve, _) => {
      let _ = setTimeout(() => resolve(. ()), duration)
    })
}
