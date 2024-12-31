import gleam/int
import gleam/io
import gleam/list
import gleam/option.{Some}
import gleam/regexp
import gleam/string
import simplifile

pub fn main() {
  let lines = get_input()
  let assert Ok(re) = regexp.from_string("mul\\((\\d{1,3}),(\\d{1,3})\\)")
  let lines_of_products =
    list.map(lines, fn(line) {
      let matches = regexp.scan(re, line)
      list.map(matches, fn(match) {
        let assert [Some(str1), Some(str2)] = match.submatches
        let assert Ok(num1) = int.parse(str1)
        let assert Ok(num2) = int.parse(str2)
        num1 * num2
      })
    })
  let summed_products = list.map(lines_of_products, int.sum)
  io.debug(int.sum(summed_products))
}

fn get_input() -> List(String) {
  let assert Ok(contents) = simplifile.read(from: "./inputs/day3.txt")
  let lines = string.split(contents, "\n")
  lines
}
