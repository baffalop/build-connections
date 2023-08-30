external encode: string => string = "btoa"

module Internal = {
  external atob: string => string = "atob"
}

let decode: string => option<string> = value => {
  try {
    Some(Internal.atob(value))
  } catch {
  | Js.Exn.Error(_) => None
  }
}
