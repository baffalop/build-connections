@module("js-base64") external encode: (string, bool) => string = "encode"

module Internal = {
  @module("js-base64") external decode: string => string = "decode"
}

let decode: string => option<string> = value => {
  try {
    Some(Internal.decode(value))
  } catch {
  | Js.Exn.Error(_) => None
  }
}
