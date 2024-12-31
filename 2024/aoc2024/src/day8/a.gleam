import gleam/dict
import gleam/int
import gleam/io
import gleam/list
import gleam/set.{type Set}
import gleam/string
import simplifile

type Point {
  Point(y: Int, x: Int)
}

type Antenna {
  Antenna(frequency: String, location: Point)
}

pub fn main() {
  let #(width, height, antennas) = get_input()
  let antinode_points = find_valid_antinodes(antennas, height:, width:)
  io.debug(set.size(antinode_points))
}

fn get_input() -> #(Int, Int, List(Antenna)) {
  let assert Ok(contents) = simplifile.read(from: "./inputs/day8.txt")
  let lines = string.split(contents, "\n")
  let height = list.length(lines)
  let width = case lines {
    [head, ..] -> string.length(head)
    _ -> panic
  }
  let antennas =
    list.index_fold(lines, [], fn(acc, line, row_index) {
      let letters = string.split(line, "")
      case find_antennas(letters, row_index, 0, []) {
        Ok(antennas) -> list.append(acc, antennas)
        Error(_) -> acc
      }
    })
  #(width, height, antennas)
}

fn find_antennas(
  haystack: List(String),
  row_index: Int,
  col_index: Int,
  found: List(Antenna),
) -> Result(List(Antenna), Nil) {
  case haystack {
    [head, ..rest] if head != "." ->
      find_antennas(rest, row_index, col_index + 1, [
        Antenna(frequency: head, location: Point(y: row_index, x: col_index)),
        ..found
      ])
    [_, ..rest] -> find_antennas(rest, row_index, col_index + 1, found)
    _ ->
      case list.length(found) {
        0 -> Error(Nil)
        _ -> Ok(list.reverse(found))
      }
  }
}

fn find_valid_antinodes(
  antennas: List(Antenna),
  height height: Int,
  width width: Int,
) -> Set(Point) {
  let freq_groups =
    dict.to_list(list.group(antennas, fn(antenna) { antenna.frequency }))
  list.fold(freq_groups, set.new(), fn(acc, freq_group) {
    let pairs = list.combinations(freq_group.1, 2)
    let antinode_points =
      list.flat_map(pairs, fn(pair) {
        case pair {
          [head, tail] -> get_antinodes(head.location, tail.location)
          _ -> panic
        }
      })
    let valid_points =
      list.filter(antinode_points, fn(point) {
        point.y >= 0 && point.y < height && point.x >= 0 && point.x < width
      })
    set.union(acc, set.from_list(valid_points))
  })
}

fn get_antinodes(one: Point, two: Point) -> List(Point) {
  let x_diff = one.x - two.x
  let #(lefter, righter) = case x_diff {
    x if x > 0 -> #(two, one)
    _ -> #(one, two)
  }
  let y_diff = one.y - two.y
  let #(higher, lower) = case y_diff {
    y if y > 0 -> #(two, one)
    _ -> #(one, two)
  }
  case x_diff, y_diff {
    0, 0 -> panic
    0, y -> {
      let diff = int.absolute_value(y)
      [
        Point(y: higher.y - diff, x: higher.x),
        Point(y: lower.y + diff, x: lower.x),
      ]
    }
    x, 0 -> {
      let diff = int.absolute_value(x)
      [
        Point(y: lefter.y, x: lefter.x - diff),
        Point(y: lefter.y, x: righter.x + diff),
      ]
    }
    x, y if x < 0 && y < 0 -> {
      [Point(y: one.y + y, x: one.x + x), Point(y: two.y - y, x: two.x - x)]
    }
    x, y if x > 0 && y > 0 -> {
      [Point(y: two.y - y, x: two.x - x), Point(y: one.y + y, x: one.x + x)]
    }
    x, y if x < 0 && y > 0 -> {
      [Point(y: one.y + y, x: one.x + x), Point(y: two.y - y, x: two.x - x)]
    }
    x, y if x > 0 && y < 0 -> {
      [Point(y: one.y - y, x: one.x - x), Point(y: two.y + y, x: two.x + x)]
    }
    _, _ -> panic
  }
}
