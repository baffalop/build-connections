let useToast = (~duration=2000, ()) => {
  let (message, setMessage) = React.useState((): option<string> => None)
  let showMessage = message => setMessage(_ => Some(message))
  let clearMessage = () => setMessage(_ => None)

  let (timeout, setTimeoutId) = React.useState((): option<timeoutId> => None)
  let clearTimeout = () => timeout->Option.mapWithDefault((), Js.Global.clearTimeout)

  React.useEffect1(() => {
    message->Option.map(_ => {
      setTimeoutId(_ => setTimeout(clearMessage, duration)->Some)
      clearTimeout
    })
  }, [message])

  open FramerMotion

  let toast =
    <AnimatePresence>
      {switch message {
      | None => React.null
      | Some(message) =>
        <Motion.Div
          className="fixed inset-x-0 mx-auto top-20 max-w-max bg-neutral-900/80 rounded-full text-white text-base overflow-hidden"
          initial={{"opacity": 0, "width": 0}}
          animate={{"opacity": 1, "width": #auto}}
          exit={{
            "opacity": 0,
            "translateY": "-2rem",
            "transition": {
              "type": "tween",
              "ease": "anticipate",
              "duration": 0.4,
            },
          }}>
          <div className="px-3 py-2.5 min-w-max"> {React.string(message)} </div>
        </Motion.Div>
      }}
    </AnimatePresence>

  (showMessage, toast)
}
