import gleam/int
import gleam/io
import gleam/list
import gleam/string
import simplifile

pub fn main() {
  let initial_stones = get_input()
  let end_stones = blink_n(initial_stones, 75)
  io.debug(list.length(end_stones))
}

fn get_input() -> List(String) {
  let assert Ok(contents) = simplifile.read(from: "./inputs/day11.txt")
  string.split(contents, " ")
}

fn blink_n(stones: List(String), remaining_blinks: Int) -> List(String) {
  case remaining_blinks {
    0 -> stones
    _ -> {
      let new_stones =
        list.flat_map(stones, fn(stone) {
          case stone {
            "0" -> ["1"]
            _ -> {
              let str_length = string.length(stone)
              let has_even_digits = int.is_even(str_length)
              case has_even_digits {
                True -> {
                  let half = str_length / 2
                  [string.drop_end(stone, half), string.drop_start(stone, half)]
                }
                False -> {
                  let assert Ok(num) = int.parse(stone)
                  [int.to_string(num * 2024)]
                }
              }
            }
          }
        })
      blink_n(new_stones, remaining_blinks - 1)
    }
  }
}
