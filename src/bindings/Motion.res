module AnimatePresence = {
  @react.component @module("framer-motion")
  external make: (~children: React.element=?) => React.element = "AnimatePresence"
}

module Div = {
  @react.component @module("framer-motion") @scope("motion")
  external make: (
    ~children: React.element=?,
    ~className: string=?,
    ~initial: {..}=?,
    ~animate: {..}=?,
    ~exit: {..}=?,
  ) => React.element = "div"
}
