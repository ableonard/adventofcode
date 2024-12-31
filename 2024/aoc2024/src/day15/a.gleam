import gleam/int
import gleam/io
import gleam/list
import gleam/string
import grid.{type Grid}
import point.{type Point, Point}
import simplifile

pub fn main() {
  let #(board, start_pos, moves) = get_input()
  let height = grid.height(board)
  let width = grid.width(board)
  let final_board = move(board, height, width, start_pos, moves)
  let box_coords = find_box_coords(final_board)
  io.debug(int.sum(box_coords))
}

fn get_input() -> #(Grid(String), Point, List(String)) {
  let assert Ok(contents) = simplifile.read(from: "./inputs/day15.test.txt")
  let assert [board_string, moves_string] = string.split(contents, "\n\n")
  let board_rows = string.split(board_string, "\n")
  let #(board_list, start_pos) =
    list.index_fold(board_rows, #([], Point(-1, -1)), fn(acc, line, row_index) {
      let spaces = string.split(line, "")
      case find_index(spaces, "@", 0) {
        Ok(col_index) -> #([spaces, ..acc.0], Point(row_index, col_index))
        _ -> #([spaces, ..acc.0], acc.1)
      }
    })
  let moves = string.split(string.replace(moves_string, "\n", ""), "")
  case start_pos {
    Point(x, y) if x == -1 && y == -1 -> panic
    _ -> #(grid.from_lists(list.reverse(board_list)), start_pos, moves)
  }
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

fn move(
  board: Grid(String),
  height: Int,
  width: Int,
  current_pos: Point,
  remaining_moves: List(String),
) -> Grid(String) {
  case remaining_moves {
    [first_move, ..rest] -> {
      let potential_pos = case first_move {
        "^" -> Point(..current_pos, y: current_pos.y - 1)
        ">" -> Point(..current_pos, x: current_pos.x + 1)
        "v" -> Point(..current_pos, y: current_pos.y + 1)
        "<" -> Point(..current_pos, x: current_pos.x - 1)
        _ -> panic
      }
      let is_valid =
        potential_pos.x < 1
        || potential_pos.y < 1
        || potential_pos.x >= width - 1
        || potential_pos.y >= height - 1
      case is_valid {
        False -> move(board, height, width, current_pos, rest)
        True -> {
          case grid.get_at(board, potential_pos.y, potential_pos.x) {
            "#" -> move(board, height, width, current_pos, rest)
            "." -> {
              let new_board = case
                grid.put_at(board, current_pos.y, current_pos.x, ".")
              {
                Ok(board) -> board
                Error(_) -> panic
              }
              let new_board = case
                grid.put_at(new_board, potential_pos.y, potential_pos.x, "@")
              {
                Ok(board) -> board
                Error(_) -> panic
              }
              move(new_board, height, width, potential_pos, rest)
            }
            "O" -> {
              todo
              board
            }
            _ -> panic
          }
        }
      }
    }
    _ -> board
  }
}

fn find_box_coords(board: Grid(String)) -> List(Int) {
  todo
}
