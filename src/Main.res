%%raw("import './tailwind.css'")

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
    <div className="p-3 w-screen max-w-screen-sm">
      <RouterProvider router />
    </div>
  </React.StrictMode>,
)
