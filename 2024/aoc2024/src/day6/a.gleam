import gleam/io
import gleam/list
import gleam/set.{type Set}
import gleam/string
import glearray.{type Array}
import simplifile

type Point {
  Point(y: Int, x: Int)
}

type Direction {
  North
  East
  South
  West
}

pub fn main() {
  let #(board, pos) = get_input()
  let height = glearray.length(board)
  let assert Ok(first_row) = glearray.get(board, 0)
  let width = glearray.length(first_row)
  let visited_cells = walk(board, pos, North, set.new(), height:, width:)
  io.debug(set.size(visited_cells))
}

fn get_input() -> #(Array(Array(String)), Point) {
  let assert Ok(contents) = simplifile.read(from: "./inputs/day6.txt")
  let lines = string.split(contents, "\n")
  let #(board_list, pos) =
    list.index_fold(lines, #([], Point(-1, -1)), fn(acc, line, row_index) {
      let letters = string.split(line, "")
      case find_index(letters, "^", 0) {
        Ok(col_index) -> {
          let cleaned_letters = string.split(string.replace(line, "^", "."), "")
          #(
            [glearray.from_list(cleaned_letters), ..acc.0],
            Point(row_index, col_index),
          )
        }
        Error(_) -> #([glearray.from_list(letters), ..acc.0], acc.1)
      }
    })
  #(glearray.from_list(list.reverse(board_list)), pos)
}

fn find_index(
  haystack: List(String),
  needle: String,
  index: Int,
) -> Result(Int, Nil) {
  case haystack {
    [head, ..] if head == needle -> Ok(index)
    [_, ..rest] -> find_index(rest, needle, index + 1)
    _ -> Error(Nil)
  }
}

fn walk(
  board: Array(Array(String)),
  current_pos: Point,
  direction: Direction,
  visited: Set(Point),
  height height: Int,
  width width: Int,
) -> Set(Point) {
  let next_pos = move_toward(current_pos, direction)
  let new_visited = set.insert(visited, current_pos)
  let off_board =
    next_pos.x < 0
    || next_pos.x >= width
    || next_pos.y < 0
    || next_pos.y >= height
  case off_board {
    True -> new_visited
    False -> {
      let next_direction = case get_at(board, next_pos.y, next_pos.x) {
        "." -> direction
        "#" -> turn_right(direction)
        _ -> panic
      }
      let next_pos = move_toward(current_pos, next_direction)
      walk(board, next_pos, next_direction, new_visited, height:, width:)
    }
  }
}

fn get_at(grid: Array(Array(t)), row row_index: Int, col col_index: Int) -> t {
  case glearray.get(grid, row_index) {
    Ok(row) ->
      case glearray.get(row, col_index) {
        Ok(val) -> val
        Error(_) -> panic
      }
    Error(_) -> panic
  }
}

fn turn_right(direction: Direction) {
  case direction {
    North -> East
    East -> South
    South -> West
    West -> North
  }
}

fn move_toward(current_pos: Point, direction: Direction) -> Point {
  case direction {
    North -> Point(..current_pos, y: current_pos.y - 1)
    East -> Point(..current_pos, x: current_pos.x + 1)
    South -> Point(..current_pos, y: current_pos.y + 1)
    West -> Point(..current_pos, x: current_pos.x - 1)
  }
}
