import gleam/dict.{type Dict}
import gleam/int
import gleam/io
import gleam/list
import gleam/option.{None, Some}
import gleam/set.{type Set}
import gleam/string
import glearray.{type Array}
import simplifile

type Point {
  Point(y: Int, x: Int)
}

pub fn main() {
  let #(board, trailheads) = get_input()
  let scores_by_head = calculate_trail_scores(board, trailheads)
  let score_sum =
    dict.fold(scores_by_head, 0, fn(acc, _trailhead, score) { acc + score })
  io.debug(score_sum)
}

fn get_input() -> #(Array(Array(Int)), List(Point)) {
  let assert Ok(contents) = simplifile.read(from: "./inputs/day10.txt")
  let lines = string.split(contents, "\n")
  let #(board_list, trailheads) =
    list.index_fold(lines, #([], []), fn(acc, line, row_index) {
      let heights =
        list.map(string.split(line, ""), fn(str) {
          let assert Ok(num) = int.parse(str)
          num
        })
      case find_indices(heights, 0, 0, []) {
        indices -> {
          #(
            [glearray.from_list(heights), ..acc.0],
            list.append(
              acc.1,
              list.map(indices, fn(index) { Point(row_index, index) }),
            ),
          )
        }
      }
    })
  #(glearray.from_list(list.reverse(board_list)), list.reverse(trailheads))
}

fn find_indices(
  haystack: List(Int),
  needle: Int,
  index: Int,
  matches: List(Int),
) -> List(Int) {
  case haystack {
    [head, ..rest] if head == needle ->
      find_indices(rest, needle, index + 1, [index, ..matches])
    [_, ..rest] -> find_indices(rest, needle, index + 1, matches)
    _ -> list.reverse(matches)
  }
}

fn calculate_trail_scores(
  board: Array(Array(Int)),
  trailheads: List(Point),
) -> Dict(Point, Int) {
  list.fold(trailheads, dict.new(), fn(acc, trailhead) {
    let trailends = find_trailends(board, trailhead, 0)
    dict.upsert(acc, trailhead, fn(val) {
      case val {
        Some(n) -> n + set.size(trailends)
        None -> set.size(trailends)
      }
    })
  })
}

fn find_trailends(
  board: Array(Array(Int)),
  current_pos: Point,
  current_height: Int,
) -> Set(Point) {
  let next_pos = get_valid_nexts(board, current_pos, current_height)
  case current_height {
    8 -> set.from_list(next_pos)
    _ -> {
      case next_pos {
        [_, ..] ->
          list.fold(next_pos, set.new(), fn(acc, position) {
            set.union(acc, find_trailends(board, position, current_height + 1))
          })
        _ -> set.new()
      }
    }
  }
}

fn get_valid_nexts(
  board: Array(Array(Int)),
  current_pos: Point,
  current_height: Int,
) -> List(Point) {
  let height = glearray.length(board)
  let assert Ok(first_row) = glearray.get(board, 0)
  let width = glearray.length(first_row)

  let next_height = current_height + 1
  let possible_pos = [
    Point(y: current_pos.y - 1, x: current_pos.x),
    Point(y: current_pos.y, x: current_pos.x + 1),
    Point(y: current_pos.y + 1, x: current_pos.x),
    Point(y: current_pos.y, x: current_pos.x - 1),
  ]
  list.filter(possible_pos, fn(pos) {
    pos.y >= 0
    && pos.y < height
    && pos.x >= 0
    && pos.x < width
    && get_at(board, pos.y, pos.x) == next_height
  })
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
