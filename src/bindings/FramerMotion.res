module AnimatePresence = {
  @react.component @module("framer-motion")
  external make: (~children: React.element=?) => React.element = "AnimatePresence"
}

module Motion = {
  module Div = {
    @react.component @module("framer-motion") @scope("motion")
    external make: (
      ~children: React.element=?,
      ~className: string=?,
      ~initial: {..}=?,
      ~animate: {..}=?,
      ~exit: {..}=?,
      ~transition: {..}=?,
    ) => React.element = "div"
  }
}

module Reorder = {
  type dragControls = {start: (. JsxEvent.Pointer.t) => unit}

  module Group = {
    @react.component @module("framer-motion") @scope("Reorder")
    external make: (
      ~children: React.element,
      ~\"as": string=?,
      ~axis: [#y | #x],
      ~values: array<'a>,
      ~onReorder: array<'a> => unit,
      ~transition: {..}=?,
      ~className: string=?,
    ) => React.element = "Group"
  }

  module Item = {
    @react.component @module("framer-motion") @scope("Reorder")
    external make: (
      ~children: React.element=?,
      ~\"as": string=?,
      ~key: string,
      ~value: 'a,
      ~dragListener: bool=?,
      ~dragControls: dragControls=?,
      ~className: string=?,
    ) => React.element = "Item"
  }

  @module("framer-motion")
  external useDragControls: unit => dragControls = "useDragControls"
}
