@react.component
let make = (~group: Group.t, ~children) => {
  let color = switch group {
  | Yellow => "bg-yellow-400"
  | Green => "bg-green-400"
  | Blue => "bg-blue-400"
  | Purple => "bg-purple-400"
  }
  <div className={`p-6 rounded-lg ${color}`}> {children} </div>
}
