import gleam/int
import gleam/io
import gleam/list
import gleam/string
import simplifile

pub fn main() {
  let reports = get_input()
  let safe_reports =
    list.filter(reports, fn(levels) {
      list.any(generate_combinations(levels), is_valid_report)
    })
  io.debug(list.length(safe_reports))
}

fn get_input() -> List(List(Int)) {
  let assert Ok(contents) = simplifile.read(from: "./inputs/day2.txt")
  let lines = string.split(contents, "\n")
  list.map(lines, fn(line) {
    let levels = string.split(line, " ")
    list.map(levels, fn(level) {
      let assert Ok(number) = int.parse(level)
      number
    })
  })
}

fn generate_combinations(levels: List(Int)) -> List(List(Int)) {
  let combos =
    list.index_map(levels, fn(_, index) {
      list.append(list.take(levels, index), list.drop(levels, index + 1))
    })
  list.prepend(to: combos, this: levels)
}

fn is_valid_report(levels: List(Int)) -> Bool {
  let sorted_levels = list.sort(levels, int.compare)
  let consistent =
    levels == sorted_levels || levels == list.reverse(sorted_levels)
  consistent
  && list.all(list.window_by_2(levels), fn(level_pair) {
    let #(level1, level2) = level_pair
    let abs_diff = int.absolute_value(level2 - level1)
    abs_diff >= 1 && abs_diff <= 3
  })
}
