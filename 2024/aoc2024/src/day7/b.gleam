import gleam/deque.{type Deque}
import gleam/int
import gleam/io
import gleam/list
import gleam/string
import simplifile

type Equation {
  Equation(result: Int, elements: List(Int))
}

type Operation {
  Num(n: Int)
  Add
  Mult
  Concat
}

pub fn main() {
  let equations = get_input()
  let valid_equations = list.filter(equations, test_for_validity)
  let valid_results =
    list.fold(valid_equations, 0, fn(acc, equation) { acc + equation.result })
  io.debug(valid_results)
}

fn get_input() -> List(Equation) {
  let assert Ok(contents) = simplifile.read(from: "./inputs/day7.txt")
  let lines = string.split(contents, "\n")
  list.map(lines, fn(line) {
    let assert [result_string, elements_string] = string.split(line, ": ")
    let assert Ok(result) = int.parse(result_string)
    let elements =
      list.map(string.split(elements_string, " "), fn(element_string) {
        let assert Ok(element) = int.parse(element_string)
        element
      })
    Equation(result:, elements:)
  })
}

fn test_for_validity(equation: Equation) -> Bool {
  let possibilities = generate_permutations(equation.elements)
  list.any(possibilities, fn(possibility) {
    does_equal(possibility, equation.result)
  })
}

fn generate_permutations(elements: List(Int)) -> List(Deque(Operation)) {
  list.fold(elements, [], fn(acc, element) {
    case acc {
      [_, ..] -> {
        let add_stacks =
          list.map(acc, fn(stack) {
            stack
            |> deque.push_back(Num(element))
            |> deque.push_back(Add)
          })
        let mult_stacks =
          list.map(acc, fn(stack) {
            stack
            |> deque.push_back(Num(element))
            |> deque.push_back(Mult)
          })
        let concat_stacks =
          list.map(acc, fn(stack) {
            stack
            |> deque.push_back(Num(element))
            |> deque.push_back(Concat)
          })
        list.append(list.append(add_stacks, mult_stacks), concat_stacks)
      }
      _ -> [deque.push_back(deque.new(), Num(element))]
    }
  })
}

fn does_equal(stack: Deque(Operation), final_result: Int) -> Bool {
  let assert Ok(#(first_op, stack)) = deque.pop_front(stack)
  let first = case first_op {
    Num(n) -> n
    _ -> panic
  }
  case deque.pop_front(stack) {
    Ok(#(second_op, stack)) -> {
      case deque.pop_front(stack) {
        Ok(#(operator, stack)) -> {
          let second = case second_op {
            Num(n) -> n
            _ -> panic
          }
          let result = case operator {
            Add -> first + second
            Mult -> first * second
            Concat -> {
              case int.parse(int.to_string(first) <> int.to_string(second)) {
                Ok(n) -> n
                Error(_) -> panic
              }
            }
            Num(_) -> panic
          }
          does_equal(deque.push_front(stack, Num(result)), final_result)
        }
        Error(_) -> panic
      }
    }
    Error(Nil) -> first == final_result
  }
}
