import gleam/dict.{type Dict}
import gleam/int
import gleam/io
import gleam/list
import gleam/order
import gleam/string
import simplifile

pub fn main() {
  let #(rules, updates) = get_input()
  let correctly_ordered = filter_to_ordered(updates, rules)
  let medians = get_median_vals(correctly_ordered)
  io.debug(int.sum(medians))
}

fn get_input() -> #(Dict(String, #(Int, Int)), List(List(Int))) {
  let assert Ok(contents) = simplifile.read(from: "./inputs/day5.txt")
  let assert [rule_string, update_string] = string.split(contents, "\n\n")
  let rule_strings = string.split(rule_string, "\n")
  let rules =
    list.fold(rule_strings, dict.new(), fn(acc, rule_string) {
      let assert [before_str, after_str] = string.split(rule_string, "|")
      let assert Ok(before) = int.parse(before_str)
      let assert Ok(after) = int.parse(after_str)
      let key = get_dict_key(before, after)
      dict.insert(acc, key, #(before, after))
    })
  let update_strings = string.split(update_string, "\n")
  let updates =
    list.map(update_strings, fn(update_string) {
      let page_strings = string.split(update_string, ",")
      list.map(page_strings, fn(page_string) {
        let assert Ok(page) = int.parse(page_string)
        page
      })
    })
  #(rules, updates)
}

fn get_dict_key(a: Int, b: Int) -> String {
  case int.compare(a, b) {
    order.Gt -> int.to_string(b) <> int.to_string(a)
    _ -> int.to_string(a) <> int.to_string(b)
  }
}

fn filter_to_ordered(
  updates: List(List(Int)),
  rules: Dict(String, #(Int, Int)),
) -> List(List(Int)) {
  list.filter(updates, fn(page_nums) {
    let sorted =
      list.sort(page_nums, fn(left, right) {
        let key = get_dict_key(left, right)
        case dict.get(rules, key) {
          Ok(#(before, after)) ->
            case before {
              v if v == left -> order.Lt
              v if v == right -> order.Gt
              _ -> {
                io.println(
                  "Found rule for "
                  <> int.to_string(left)
                  <> ","
                  <> int.to_string(right)
                  <> " but couldn't match: "
                  <> int.to_string(before)
                  <> ","
                  <> int.to_string(after),
                )
                panic
              }
            }
          Error(_) -> {
            io.println(
              "No rule found for "
              <> int.to_string(left)
              <> ","
              <> int.to_string(right),
            )
            panic
          }
        }
      })
    page_nums == sorted
  })
}

fn get_median_vals(updates: List(List(Int))) -> List(Int) {
  list.map(updates, fn(page_nums) {
    let median_index = list.length(page_nums) / 2
    case list.drop(page_nums, median_index) {
      [head, ..] -> head
      _ -> panic
    }
  })
}
