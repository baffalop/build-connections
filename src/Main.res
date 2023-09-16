%%raw("import './tailwind.css'")
%%raw(`import './main.css'`)

module GameLoader = {
  @react.component
  let make = () => {
    let (connections, slug): (Puzzle.connections, string) = ReactRouter.useLoaderData()
    <Game connections slug />
  }
}

open ReactRouter

let router =
  <>
    <Route path="/" element={<Create />} />
    <Route
      path=":slug"
      element={<GameLoader />}
      loader={({params}: loaderParams<{"slug": string}>) => {
        let slug = params["slug"]
        switch Puzzle.Decode.slug(slug) {
        | Ok(connections) => Data((connections, slug))
        | Error(e) => {
            Console.log3("Failed to decode slug: ", slug, e)
            ReactRouter.redirect("/")
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
