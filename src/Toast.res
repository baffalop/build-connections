let duration = 2000

@react.component
let make = (~message: option<string>, ~clear: unit => unit) => {
  let (timeout, setTimeoutId) = React.useState((): option<timeoutId> => None)
  let clearTimeout = () => timeout->Option.mapWithDefault((), Js.Global.clearTimeout)

  React.useEffect1(() => {
    message->Option.map(_ => {
      setTimeoutId(_ => setTimeout(clear, duration)->Some)
      clearTimeout
    })
  }, [message])

  switch message {
  | None => React.null
  | Some(message) =>
    <div
      className="fixed inset-x-0 mx-auto top-20 max-w-max bg-neutral-900/80 rounded-full p-3 text-white">
      {React.string(message)}
    </div>
  }
}
