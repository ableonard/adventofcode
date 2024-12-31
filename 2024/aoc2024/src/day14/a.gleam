import gleam/int
import gleam/io
import gleam/list
import gleam/option.{Some}
import gleam/regexp
import gleam/string
import simplifile

type Point {
  Point(y: Int, x: Int)
}

type Robot {
  Robot(velocity: Point, pos: Point)
}

const width = 101

const height = 103

pub fn main() {
  let bots = get_input()
  io.println("All bots:")
  io.debug(bots)
  let final_positions = step(bots, 100)
  let quarter_counts = get_quarter_counts(final_positions)
  io.print("Quarter counts: ")
  io.debug(quarter_counts)
  let safety_factor =
    list.fold(quarter_counts, 1, fn(acc, count) { acc * count })
  io.debug(safety_factor)
}

fn get_input() -> List(Robot) {
  let assert Ok(re) = regexp.from_string("p=(\\d+),(\\d+) v=(-?\\d+),(-?\\d+)")
  let assert Ok(contents) = simplifile.read(from: "./inputs/day14.txt")
  let lines = string.split(contents, "\n")
  list.map(lines, fn(line) {
    let assert [match] = regexp.scan(re, line)
    let assert [Some(pos_x), Some(pos_y), Some(vel_x), Some(vel_y)] =
      match.submatches
    let assert [Ok(pos_x), Ok(pos_y)] = [int.parse(pos_x), int.parse(pos_y)]
    let assert [Ok(vel_x), Ok(vel_y)] = [int.parse(vel_x), int.parse(vel_y)]
    Robot(pos: Point(y: pos_y, x: pos_x), velocity: Point(y: vel_y, x: vel_x))
  })
}

fn step(bots: List(Robot), remaining_steps: Int) -> List(Robot) {
  io.println("Step " <> int.to_string(remaining_steps))
  case remaining_steps {
    0 -> bots
    _ -> {
      let new_bots =
        list.map(bots, fn(bot) {
          Robot(
            ..bot,
            pos: add_with_bounds(bot.pos, bot.velocity, width, height),
          )
        })
      io.debug(list.map(new_bots, fn(bot) { bot.pos }))
      step(new_bots, remaining_steps - 1)
    }
  }
}

fn get_quarter_counts(bots: List(Robot)) -> List(Int) {
  let quarters = [
    #(Point(0, 0), Point(height / 2 - 1, width / 2 - 1)),
    #(Point(0, width / 2 + 1), Point(height / 2 - 1, width - 1)),
    #(Point(height / 2 + 1, 0), Point(height - 1, width / 2 - 1)),
    #(Point(height / 2 + 1, width / 2 + 1), Point(height - 1, width - 1)),
  ]
  io.println(
    "Width: " <> int.to_string(width) <> ", Height: " <> int.to_string(height),
  )
  io.println("Quarter ranges:")
  io.debug(quarters)
  list.map(quarters, fn(quarter) {
    list.count(bots, fn(bot) { between(bot.pos, quarter.0, quarter.1) })
  })
}

fn add_with_bounds(a: Point, b: Point, max_x: Int, max_y: Int) -> Point {
  let new_y = case a.y + b.y {
    y if y < 0 -> max_y + y
    y if y >= max_y -> y % max_y
    y -> y
  }
  let new_x = case a.x + b.x {
    x if x < 0 -> max_x + x
    x if x >= max_x -> x % max_x
    x -> x
  }
  Point(y: new_y, x: new_x)
}

fn subtract(a: Point, b: Point) -> Point {
  Point(y: a.y - b.y, x: a.x - b.x)
}

fn between(point_to_test: Point, left: Point, right: Point) -> Bool {
  let left_diff = subtract(point_to_test, left)
  let is_left_valid = left_diff.y >= 0 && left_diff.x >= 0

  let right_diff = subtract(right, point_to_test)
  let is_right_valid = right_diff.y >= 0 && right_diff.x >= 0

  is_left_valid && is_right_valid
}
