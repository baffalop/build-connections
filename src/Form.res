@react.component
let make = (~children: React.element, ~buttons: React.element, ~onSubmit: unit => unit) => {
  <form
    className="space-y-6"
    onSubmit={e => {
      ReactEvent.Form.preventDefault(e)
      onSubmit()
    }}>
    {children}
    <div className="flex justify-center gap-4"> {buttons} </div>
  </form>
}
