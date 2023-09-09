open Vitest
open Bindings
open ReactTestingLibrary
open JsDom

let router = Main.routes->ReactRouter.createMemoryRouter({
  initialEntries: [
    "W3sidCI6IlBvc2l0aXZlIGFkamVjdGl2ZXMiLCJ2IjpbIkdyZWF0IiwiQW1hemluZyIsIkV4dHJhb3JkaW5hcnkiLCJGYW50YXN0aWMiXX0seyJ0IjoiQnVncyIsInYiOlsiU3BpZGVyIiwiQW50IiwiV2FzcCIsIldvcm0iXX0seyJ0IjoiTm9jdHVybmFsIGFuaW1hbHMiLCJ2IjpbIkJhdCIsIk93bCIsIk1vbGUiLCJSYWNjb29uIl19LHsidCI6IlN1cGVyaGVybyBuYW1lcyBlbmRpbmcgd2l0aCDigJhtYW7igJkiLCJ2IjpbIlN1cGVyIiwiSXJvbiIsIkFxdWEiLCJVbHRyYSJdfV0",
  ],
  initialIndex: 0,
})

testAsync("loads puzzle data from slug", async t => {
  render(<ReactRouter.RouterProvider router />)
  t->assertions(1)
  let _ = await screen->findByText("Custom Connections")
  screen->getByText("extraordinary")->expect->toBeInTheDocument
})
