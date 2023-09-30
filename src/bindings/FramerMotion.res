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
      ~layout: bool=?,
      ~onClick: unit => unit=?,
    ) => React.element = "div"
  }

  module Button = {
    @react.component @module("framer-motion") @scope("motion")
    external make: (
      ~children: React.element=?,
      ~className: string=?,
      ~initial: {..}=?,
      ~animate: {..}=?,
      ~exit: {..}=?,
      ~transition: {..}=?,
      ~layout: bool=?,
      ~\"type": string=?,
      ~onClick: unit => unit=?,
      ~ref: JsxDOM.domRef=?,
    ) => React.element = "button"
  }

  module Variant = {
    module Div = {
      @react.component @module("framer-motion") @scope("motion")
      external make: (
        ~children: React.element=?,
        ~className: string=?,
        ~variants: {..},
        ~initial: string=?,
        ~animate: string=?,
        ~exit: string=?,
        ~layout: bool=?,
        ~onClick: unit => unit=?,
      ) => React.element = "div"
    }

    module Button = {
      @react.component @module("framer-motion") @scope("motion")
      external make: (
        ~children: React.element=?,
        ~className: string=?,
        ~variants: {..},
        ~initial: string=?,
        ~animate: string=?,
        ~exit: string=?,
        ~layout: bool=?,
        ~\"type": string=?,
        ~onClick: unit => unit=?,
        ~ref: JsxDOM.domRef=?,
      ) => React.element = "button"
    }
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

@module("framer-motion")
external animate: (string, {..}, {..}) => promise<unit> = "animate"

type delay

@module("framer-motion")
external stagger: float => delay = "stagger"
