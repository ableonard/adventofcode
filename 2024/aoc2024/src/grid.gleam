import gleam/list
import glearray.{type Array}

pub type Grid(t) =
  Array(Array(t))

pub fn from_lists(vals: List(List(t))) -> Grid(t) {
  glearray.from_list(list.map(vals, glearray.from_list))
}

pub fn height(grid: Grid(t)) -> Int {
  glearray.length(grid)
}

pub fn width(grid: Grid(t)) -> Int {
  case glearray.get(grid, 0) {
    Ok(row) -> glearray.length(row)
    Error(_) -> 0
  }
}

pub fn get_at(grid: Grid(t), y: Int, x: Int) -> Result(t, Nil) {
  case glearray.get(grid, y) {
    Ok(row) -> glearray.get(row, x)
    Error(e) -> Error(e)
  }
}

pub fn put_at(grid: Grid(t), y: Int, x: Int, val: t) -> Result(Grid(t), Nil) {
  case glearray.get(grid, y) {
    Ok(row) ->
      case glearray.copy_set(row, x, val) {
        Ok(row) -> glearray.copy_set(grid, y, row)
        Error(_) -> panic
      }
    Error(_) -> panic
  }
}
