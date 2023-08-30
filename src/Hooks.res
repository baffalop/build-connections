let useLocalStorage = (
  init: unit => 'a,
  key: string,
  parser: Funicular.Decode.parser<'a, [> Funicular.Decode.jsonParseError]>,
  encode: 'a => Js.Json.t,
): ('a, ('a => 'a) => unit) => {
  let localStorage = Dom.Storage.localStorage
  let parsed =
    Dom.Storage.getItem(key, localStorage)->Option.flatMap(v =>
      Funicular.Decode.parse(v, parser)->Utils.Result.toOption
    )

  let (state, setState) = React.useState(() => parsed->Option.getWithDefault(init()))

  React.useEffect1(() => {
    Dom.Storage.setItem(key, state->encode->Js.Json.stringify, localStorage)
    None
  }, [state])

  (state, setState)
}
