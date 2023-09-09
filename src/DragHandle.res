@react.component
let make = (~dragControls: FramerMotion.Reorder.dragControls) => {
  <div
    className="cursor-grab grid grid-cols-3 gap-0.5" onPointerDown={e => dragControls.start(. e)}>
    {Belt.Array.make(9, <div className="rounded-full w-1 h-1 bg-black/30" />)->React.array}
  </div>
}
