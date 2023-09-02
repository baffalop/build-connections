@react.component
let make = (
  ~children: React.element,
  ~buttons: React.element,
  ~title: option<string>=?,
  ~message: React.element=<> </>,
  ~description: option<React.element>=?,
  ~onSubmit: unit => unit,
) => {
  <form
    className="space-y-6 text-center"
    onSubmit={e => {
      ReactEvent.Form.preventDefault(e)
      onSubmit()
    }}>
    {title->Option.mapWithDefault(React.null, title =>
      <h1 className="text-lg font-bold text-center !mb-5"> {React.string(title)} </h1>
    )}
    {description->Option.mapWithDefault(React.null, description =>
      <p className="text-base space-y-1.5 !mb-8 max-w-xl mx-auto"> {description} </p>
    )}
    {children}
    {message}
    <div className="flex justify-center gap-3"> {buttons} </div>
  </form>
}
