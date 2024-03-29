type rainbow = NoRainbow | Rainbow | ReverseRainbow

let rainbow = Group.rainbow->List.toArray
let reverseRainbow = rainbow->Belt.Array.reverse

@react.component
let make = (~guesses: array<array<Puzzle.cardId>>, ~close: unit => unit) => {
  let (showToast, toast) = Toast.useToast()

  let matches = guesses->Belt.Array.map(Utils.Array.matchAllBy(_, Puzzle.groupFromId))
  let fullMatches = matches->Belt.Array.keepMap(g => g)
  let mistakes = matches->Belt.Array.keep(Option.isNone)->Array.length

  let rainbow =
    fullMatches == rainbow ? Rainbow : fullMatches == reverseRainbow ? ReverseRainbow : NoRainbow

  let copyResults = async () => {
    let grid =
      guesses->Belt.Array.joinWith(
        "\n",
        Belt.Array.joinWith(_, "", (Puzzle.CardId(group, _)) => Group.swatch(group)),
      )
    let result = `Custom Connections\n\n${grid}`

    try {
      await Clipboard.writeText(result)
      showToast("Copied to clipboard")
    } catch {
    | _ => {
        Console.log(result)
        showToast("Cannot access clipboard:\nCheck console")
      }
    }
  }

  let popVariants = {
    "in": {"opacity": 0, "scale": 0.9},
    "open": {
      "opacity": 1,
      "scale": 1,
      "transition": {
        "duration": 0.1,
        "scale": {
          "type": #spring,
          "duration": 0.3,
          "bounce": 0.5,
        },
      },
    },
    "out": {
      "opacity": 0,
      "scale": 0.7,
      "transition": {"duration": 0.1},
    },
  }

  open FramerMotion

  <div className="fixed inset-0 !m-0">
    {toast}
    <Motion.Variant.Div
      variants={popVariants}
      initial="in"
      animate="open"
      exit="out"
      className="fixed inset-0 z-10 m-auto max-w-max max-h-max flex flex-col items-center gap-5
        rounded-lg bg-neutral-100 border border-neutral-800 px-5 pt-4 pb-5">
      <button
        type_="button"
        className="text-2xl leading-none cursor-pointer self-end"
        onClick={_ => close()}>
        {React.string("×")}
      </button>
      <div className="grid grid-cols-[auto_auto_auto_auto] gap-x-1 gap-y-2">
        {guesses
        ->Belt.Array.mapWithIndex((i, guess) =>
          guess->Belt.Array.mapWithIndex((j, cardId) => {
            let key = `${Int.toString(i)},${Int.toString(j)}`
            let color = cardId->Puzzle.groupFromId->Group.bgColor

            <div key className={`w-10 h-10 rounded ${color}`} />
          })
        )
        ->Belt.Array.concatMany
        ->React.array}
      </div>
      <h4 className="text-lg font-medium">
        {switch mistakes {
        | 0 =>
          switch rainbow {
          | Rainbow => "Perfection! 🌈"
          | ReverseRainbow => "Galaxy brain 🌈"
          | NoRainbow => "Magnificent!"
          }
        | 1 => "Good stuff"
        | 2 => "Not bad"
        | 3 => "Scraped by!"
        | 4 => "...Blame the puzzle maker"
        | _ => "Unbelievable! Literally"
        }->React.string}
      </h4>
      <button type_="button" className="action" onClick={_ => copyResults()->Promise.done}>
        {React.string("Copy Results")}
      </button>
    </Motion.Variant.Div>
    <Motion.Div
      initial={{"opacity": 0}}
      animate={{"opacity": 0.8}}
      exit={{"opacity": 0}}
      transition={{"duration": 0.15}}
      className="w-full h-full bg-neutral-900"
      onClick={_ => close()}
    />
  </div>
}
