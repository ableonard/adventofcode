import gleam/deque.{type Deque}
import gleam/int
import gleam/io
import gleam/list
import gleam/string
import simplifile

pub fn main() {
  let block_layout = get_input()
  let compacted_layout = compact(block_layout)
  io.debug(calc_checksum(compacted_layout))
}

fn get_input() -> List(String) {
  let assert Ok(contents) = simplifile.read(from: "./inputs/day9.txt")
  let disk_map =
    list.map(string.split(contents, ""), fn(num_string) {
      let assert Ok(num) = int.parse(num_string)
      num
    })
  list.index_fold(list.sized_chunk(disk_map, 2), [], fn(acc, disk_elem, index) {
    case disk_elem {
      [file_size, free_size] ->
        list.append(
          list.append(acc, list.repeat(int.to_string(index), file_size)),
          list.repeat(".", free_size),
        )
      [file_size] ->
        list.append(acc, list.repeat(int.to_string(index), file_size))
      _ -> panic
    }
  })
}

fn compact(block_layout: List(String)) -> List(String) {
  let stack = deque.from_list(block_layout)
  compact_step(stack, [], [])
}

fn compact_step(
  remaining: Deque(String),
  new_layout: List(String),
  end_elements: List(String),
) -> List(String) {
  case deque.pop_front(remaining) {
    Ok(#(block, next_remaining)) ->
      case block {
        "." -> {
          case pop_back_to_nonempty(next_remaining, []) {
            #(Ok(fill_block), next_remaining, more_end_elements) ->
              compact_step(
                next_remaining,
                [fill_block, ..new_layout],
                list.append(end_elements, more_end_elements),
              )
            #(Error(Nil), _, more_end_elements) -> {
              list.append(
                list.reverse([block, ..new_layout]),
                list.append(end_elements, more_end_elements),
              )
            }
          }
        }
        b -> compact_step(next_remaining, [b, ..new_layout], end_elements)
      }
    Error(_) -> list.append(list.reverse(new_layout), end_elements)
  }
}

fn pop_back_to_nonempty(
  stack: Deque(String),
  end_elements: List(String),
) -> #(Result(String, Nil), Deque(String), List(String)) {
  case deque.pop_back(stack) {
    Ok(#(element, next_stack)) ->
      case element {
        "." -> pop_back_to_nonempty(next_stack, [element, ..end_elements])
        _ -> #(Ok(element), next_stack, list.reverse([".", ..end_elements]))
      }
    Error(_) -> #(Error(Nil), stack, list.reverse(end_elements))
  }
}

fn calc_checksum(layout: List(String)) -> Int {
  list.index_fold(layout, 0, fn(acc, block, index) {
    case int.parse(block) {
      Ok(file_id) -> file_id * index + acc
      Error(_) -> acc
    }
  })
}
