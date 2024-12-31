import gleam/deque.{type Deque}
import gleam/int
import gleam/io
import gleam/option.{type Option, Some}
import gleam/regexp
import gleam/string
import simplifile

type Instruction {
  Do
  Dont
  Mul(left: Int, right: Int)
}

pub fn main() {
  let lines = get_input()
  let instructions = parse_lines(lines, deque.new())
  let result = execute(instructions, 0, False)
  io.debug(result)
}

fn get_input() -> List(String) {
  let assert Ok(contents) = simplifile.read(from: "./inputs/day3.txt")
  let lines = string.split(contents, "\n")
  lines
}

fn parse_lines(
  lines: List(String),
  instructions: Deque(Instruction),
) -> Deque(Instruction) {
  let assert Ok(re) =
    regexp.from_string("do\\(\\)|don't\\(\\)|mul\\((\\d{1,3}),(\\d{1,3})\\)")
  case lines {
    [line, ..rest] ->
      parse_lines(rest, parse_matches(regexp.scan(re, line), instructions))
    _ -> instructions
  }
}

fn parse_matches(
  matches: List(regexp.Match),
  instructions: Deque(Instruction),
) -> Deque(Instruction) {
  case matches {
    [match, ..rest] -> parse_matches(rest, parse_match(match, instructions))
    _ -> instructions
  }
}

fn parse_match(
  match: regexp.Match,
  instructions: Deque(Instruction),
) -> Deque(Instruction) {
  case match.content {
    "do()" -> deque.push_back(instructions, Do)
    "don't()" -> deque.push_back(instructions, Dont)
    "mul" <> _remainder ->
      deque.push_back(instructions, parse_mul(match.submatches))
    _ -> panic
  }
}

fn parse_mul(factors: List(Option(String))) -> Instruction {
  let assert [Some(left_string), Some(right_string)] = factors
  let assert Ok(left) = int.parse(left_string)
  let assert Ok(right) = int.parse(right_string)
  Mul(left, right)
}

fn execute(stack: Deque(Instruction), result: Int, should_skip: Bool) -> Int {
  case deque.pop_front(stack) {
    Ok(#(instruction, new_stack)) ->
      case instruction {
        Do -> execute(new_stack, result, False)
        Dont -> execute(new_stack, result, True)
        Mul(left, right) if should_skip == False ->
          execute(new_stack, result + left * right, False)
        Mul(_, _) -> execute(new_stack, result, True)
      }
    _ -> result
  }
}
