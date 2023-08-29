%%raw("import './tailwind.css'")

open ReactRouter

let router =
  <>
    <Route path="/" element={<Create />} />
    <Route path=":puzzle" element={<Game />} />
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
