import gleam/int
import gleam/io
import gleam/list
import gleam/string
import simplifile

pub fn main() {
  let #(list1, list2) = get_input()
  let sorted1 = list.sort(list1, by: int.compare)
  let sorted2 = list.sort(list2, by: int.compare)
  let zipped = list.zip(sorted1, sorted2)
  let distances =
    list.map(zipped, fn(loc_tuple) {
      let #(loc1, loc2) = loc_tuple
      int.absolute_value(loc1 - loc2)
    })
  io.debug(int.sum(distances))
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
