@react.component
let make = (
  ~children: React.element,
  ~buttons: React.element,
  ~message: React.element=<> </>,
  ~onSubmit: unit => unit,
) => {
  <form
    className="space-y-6"
    onSubmit={e => {
      ReactEvent.Form.preventDefault(e)
      onSubmit()
    }}>
    {children}
    {message}
    <div className="flex justify-center gap-3"> {buttons} </div>
  </form>
}