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
        params["slug"]
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
