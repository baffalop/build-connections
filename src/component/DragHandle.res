@react.component
let make = (~group: Group.t, ~dragControls: FramerMotion.Reorder.dragControls) => {
  <div
    className="cursor-grab grid grid-cols-3 gap-0.5"
    onPointerDown={e => {
      dragControls.start(. e)
      JsxEvent.Pointer.preventDefault(e)
    }}>
    {Belt.Array.range(0, 8)
    ->Belt.Array.map(i =>
      <div key={Int.toString(i)} className={`rounded-full w-1 h-1 ${Group.bgColorDark(group)}`} />
    )
    ->React.array}
  </div>
}
