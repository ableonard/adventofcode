import gleam/int
import gleam/io
import gleam/list
import gleam/string
import simplifile

pub fn main() {
  let initial_stones = get_input()
  let end_stones = blink_n(initial_stones, 25)
  io.debug(list.length(end_stones))
}

fn get_input() -> List(Int) {
  let assert Ok(contents) = simplifile.read(from: "./inputs/day11.txt")
  let numbers = string.split(contents, " ")
  list.map(numbers, fn(num) {
    let assert Ok(parsed) = int.parse(num)
    parsed
  })
}

fn blink_n(stones: List(Int), remaining_blinks: Int) -> List(Int) {
  case remaining_blinks {
    0 -> stones
    _ -> {
      let new_stones =
        list.flat_map(stones, fn(stone) {
          case stone {
            0 -> [1]
            n -> {
              let str_num = int.to_string(stone)
              let str_length = string.length(str_num)
              let has_even_digits = int.is_even(str_length)
              case has_even_digits {
                True -> {
                  let half = str_length / 2
                  let assert Ok(first) =
                    int.parse(string.drop_end(str_num, half))
                  let assert Ok(second) =
                    int.parse(string.drop_start(str_num, half))
                  [first, second]
                }
                False -> [n * 2024]
              }
            }
          }
        })
      blink_n(new_stones, remaining_blinks - 1)
    }
  }
}
