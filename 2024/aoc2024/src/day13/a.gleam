import gleam/int
import gleam/io
import gleam/list
import gleam/option.{Some}
import gleam/regexp
import gleam/string
import simplifile

type Point {
  Point(x: Int, y: Int)
}

type Problem {
  Problem(a: Point, b: Point, goal: Point)
}

pub fn main() {
  let problems = get_input()
  let min_tokens = list.flat_map(problems, cramers_rule)
  io.debug(int.sum(min_tokens))
}

fn get_input() -> List(Problem) {
  let assert Ok(re) = regexp.from_string("X[+=](\\d+), Y[+=](\\d+)")
  let assert Ok(contents) = simplifile.read(from: "./inputs/day13.txt")
  let problem_strings = string.split(contents, "\n\n")
  let problems =
    list.fold(problem_strings, [], fn(acc, problem_string) {
      let assert [a_match, b_match, goal_match] =
        regexp.scan(re, problem_string)

      let assert [Some(a_x_str), Some(a_y_str)] = a_match.submatches
      let assert Ok(a_x) = int.parse(a_x_str)
      let assert Ok(a_y) = int.parse(a_y_str)
      let a = Point(x: a_x, y: a_y)

      let assert [Some(b_x_str), Some(b_y_str)] = b_match.submatches
      let assert Ok(b_x) = int.parse(b_x_str)
      let assert Ok(b_y) = int.parse(b_y_str)
      let b = Point(x: b_x, y: b_y)

      let assert [Some(goal_x_str), Some(goal_y_str)] = goal_match.submatches
      let assert Ok(goal_x) = int.parse(goal_x_str)
      let assert Ok(goal_y) = int.parse(goal_y_str)
      let goal = Point(x: goal_x, y: goal_y)

      [Problem(a:, b:, goal:), ..acc]
    })
  list.reverse(problems)
}

fn cramers_rule(problem: Problem) -> List(Int) {
  let equation_matrix = #(#(problem.a.x, problem.b.x), #(
    problem.a.y,
    problem.b.y,
  ))
  let det_equations = determinant(equation_matrix)
  let a =
    int.absolute_value(
      determinant(
        #(#(problem.b.x, problem.goal.x), #(problem.b.y, problem.goal.y)),
      )
      / det_equations,
    )
  let b =
    int.absolute_value(
      determinant(
        #(#(problem.a.x, problem.goal.x), #(problem.a.y, problem.goal.y)),
      )
      / det_equations,
    )
  let final_pos =
    Point(
      x: { a * problem.a.x } + { b * problem.b.x },
      y: { a * problem.a.y } + { b * problem.b.y },
    )
  case final_pos == problem.goal {
    True -> [a * 3 + b * 1]
    False -> []
  }
}

fn determinant(matrix: #(#(Int, Int), #(Int, Int))) -> Int {
  { matrix.0.0 * matrix.1.1 } - { matrix.0.1 * matrix.1.0 }
}
