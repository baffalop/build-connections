/**
 * Initial bindings from package rescript-react-router-dom
 */
type location = {
  pathname: string,
  search: string,
  hash: string,
  state: option<string>,
  key: string,
}

type params = {slug: option<string>}
type loaderParams<'a> = {params: 'a}

type router = Router
type route = Route

@module("react-router-dom")
external createHashRouter: array<route> => router = "createHashRouter"

@module("react-router-dom")
external createRoutesFromElements: React.element => array<route> = "createRoutesFromElements"

module RouterProvider = {
  @react.component @module("react-router-dom")
  external make: (~router: router) => React.element = "RouterProvider"
}

module HashRouter = {
  @react.component @module("react-router-dom")
  external make: (~children: React.element) => React.element = "HashRouter"
}

module BrowserRouter = {
  @react.component @module("react-router-dom")
  external make: (~children: React.element) => React.element = "BrowserRouter"
}

module Routes = {
  @react.component @module("react-router-dom")
  external make: (~children: React.element) => React.element = "Routes"
}

module Route = {
  @react.component @module("react-router-dom")
  external make: (
    ~path: string,
    ~element: React.element,
    ~loader: loaderParams<'a> => 'b=?,
  ) => React.element = "Route"
}

module Internal = {
  module Link = {
    @react.component @module("react-router-dom")
    external make: (~children: React.element, ~to: string, ~className: string=?) => React.element =
      "Link"
  }
}

module Link = {
  @react.component
  let make = (~children: React.element, ~href: string, ~className: option<string>=?) => {
    switch className {
    | Some(cl) => <Internal.Link to={href} className={cl}> {children} </Internal.Link>
    | None => <Internal.Link to={href}> {children} </Internal.Link>
    }
  }
}

@module("react-router-dom")
external useLocation: unit => location = "useLocation"

@module("react-router-dom")
external useParams: unit => params = "useParams"

type navigate = (string, option<string>) => unit
@module("react-router-dom")
external useNavigate: unit => navigate = "useNavigate"

@module("react-router-dom")
external useLoaderData: unit => 'a = "useLoaderData"
