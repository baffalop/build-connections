type rect = {
  width: nullable<float>,
  height: nullable<float>,
}

@module("@uidotdev/usehooks")
external useMeasure: unit => (JsxDOM.domRef, rect) = "useMeasure"
