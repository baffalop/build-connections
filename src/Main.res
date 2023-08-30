%%raw("import './tailwind.css'")
%%raw(`import './main.css'`)

open ReactRouter

let router =
  <>
    <Route path="/" element={<Create />} />
    <Route
      path=":slug"
      element={<Game />}
      loader={({params}: loaderParams<{"slug": string}>) => {
        open Puzzle.Codec

        switch decode(params["slug"]) {
        | Ok(connections) => connections
        | Error(e) => {
            switch e {
            | Not4Connections => "Wrong number of connections"
            | Base64ParseError => "Base64 parse error"
            | JsonParseError(_) => "Json parse error"
            }->Console.log2("Failed to decode slug:", _)

            list{}
          }
        }
      }}
    />
  </>
  ->createRoutesFromElements
  ->createHashRouter

ReactDOM.querySelector("#root")
->Option.getExn
->ReactDOM.Client.createRoot
->ReactDOM.Client.Root.render(
  <React.StrictMode>
    <div
      className="p-3 min-h-screen w-screen max-w-screen-sm mx-auto flex flex-col items-stretch justify-center">
      <RouterProvider router />
    </div>
  </React.StrictMode>,
)
