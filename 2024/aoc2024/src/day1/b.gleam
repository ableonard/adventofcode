import gleam/dict.{type Dict}
import gleam/int
import gleam/io
import gleam/list
import gleam/option.{type Option, None, Some}
import gleam/string
import simplifile

pub fn main() {
  let #(list1, list2) = get_input()
  let freq_table = build_freq_table(list2, dict.new())
  let similarity =
    list.fold(list1, 0, fn(score, loc_id) {
      case dict.get(freq_table, loc_id) {
        Ok(frequency) -> score + frequency * loc_id
        Error(Nil) -> score
      }
    })
  io.debug(similarity)
}

fn get_input() -> #(List(Int), List(Int)) {
  let assert Ok(contents) = simplifile.read(from: "./inputs/day1.txt")
  let lines = string.split(contents, "\n")
  let loc_ids =
    list.map(lines, fn(line) {
      let assert [str1, str2] = string.split(line, "   ")
      let assert Ok(num1) = int.parse(str1)
      let assert Ok(num2) = int.parse(str2)
      #(num1, num2)
    })
  list.unzip(loc_ids)
}

fn build_freq_table(loc_ids: List(Int), freq_table) -> Dict(Int, Int) {
  case loc_ids {
    [first, ..rest] ->
      build_freq_table(rest, dict.upsert(freq_table, first, increment_entry))
    [] -> freq_table
  }
}

fn increment_entry(entry: Option(Int)) -> Int {
  case entry {
    Some(i) -> i + 1
    None -> 1
  }
}
