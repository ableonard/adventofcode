import gleam/io
import gleam/list
import gleam/string
import glearray.{type Array}
import simplifile

type Point {
  Point(y: Int, x: Int)
}

pub fn main() {
  let grid = get_input()
  let height = glearray.length(grid)
  let width = case glearray.get(grid, 0) {
    Ok(row) -> glearray.length(row)
    _ -> panic
  }
  let matches = find_matches(grid, width:, height:)
  io.debug(list.length(matches))
}

fn get_input() -> Array(Array(String)) {
  let assert Ok(contents) = simplifile.read(from: "./inputs/day4.txt")
  let lines = string.split(contents, "\n")
  glearray.from_list(
    list.map(lines, fn(line) { glearray.from_list(string.split(line, "")) }),
  )
}

fn find_matches(
  grid: Array(Array(String)),
  width width: Int,
  height height: Int,
) -> List(List(Point)) {
  let grid_list =
    list.map(glearray.to_list(grid), fn(row) { glearray.to_list(row) })
  list.index_fold(grid_list, [], fn(row_acc, row, row_index) {
    let possibilities =
      list.index_fold(row, [], fn(letter_acc, letter, letter_index) {
        case letter {
          "X" ->
            list.append(
              letter_acc,
              generate_locations(
                grid,
                row: row_index,
                col: letter_index,
                width:,
                height:,
              ),
            )
          _ -> letter_acc
        }
      })
    list.append(row_acc, possibilities)
  })
}

fn generate_locations(
  grid: Array(Array(String)),
  row row: Int,
  col col: Int,
  width width: Int,
  height height: Int,
) -> List(List(Point)) {
  list.filter(
    [
      // right
      [
        Point(row, col),
        Point(row, col + 1),
        Point(row, col + 2),
        Point(row, col + 3),
      ],
      // left
      [
        Point(row, col),
        Point(row, col - 1),
        Point(row, col - 2),
        Point(row, col - 3),
      ],
      // down
      [
        Point(row, col),
        Point(row + 1, col),
        Point(row + 2, col),
        Point(row + 3, col),
      ],
      // up
      [
        Point(row, col),
        Point(row - 1, col),
        Point(row - 2, col),
        Point(row - 3, col),
      ],
      // up-right
      [
        Point(row, col),
        Point(row - 1, col + 1),
        Point(row - 2, col + 2),
        Point(row - 3, col + 3),
      ],
      // down-right
      [
        Point(row, col),
        Point(row + 1, col + 1),
        Point(row + 2, col + 2),
        Point(row + 3, col + 3),
      ],
      // up-left
      [
        Point(row, col),
        Point(row - 1, col - 1),
        Point(row - 2, col - 2),
        Point(row - 3, col - 3),
      ],
      // down-left
      [
        Point(row, col),
        Point(row + 1, col - 1),
        Point(row + 2, col - 2),
        Point(row + 3, col - 3),
      ],
    ],
    fn(possibility) { is_valid_pos(grid, possibility, width:, height:) },
  )
}

fn is_valid_pos(
  grid: Array(Array(String)),
  possibility: List(Point),
  width width: Int,
  height height: Int,
) -> Bool {
  let assert [x_pos, m_pos, a_pos, s_pos] = possibility
  { x_pos.y >= 0 && x_pos.y < height && x_pos.x >= 0 && x_pos.x < width }
  && { m_pos.y >= 0 && m_pos.y < height && m_pos.x >= 0 && m_pos.x < width }
  && { a_pos.y >= 0 && a_pos.y < height && a_pos.x >= 0 && a_pos.x < width }
  && { s_pos.y >= 0 && s_pos.y < height && s_pos.x >= 0 && s_pos.x < width }
  && get_letter_from_grid(grid, x_pos) == "X"
  && get_letter_from_grid(grid, m_pos) == "M"
  && get_letter_from_grid(grid, a_pos) == "A"
  && get_letter_from_grid(grid, s_pos) == "S"
}

fn get_letter_from_grid(grid: Array(Array(String)), position: Point) -> String {
  case glearray.get(grid, position.y) {
    Ok(row) ->
      case glearray.get(row, position.x) {
        Ok(letter) -> letter
        _ -> ""
      }
    _ -> ""
  }
}
