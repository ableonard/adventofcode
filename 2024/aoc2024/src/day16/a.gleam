import gleam/float
import gleam/int
import gleam/io
import gleam/list
import gleam/string
import gleamy/priority_queue.{type Queue} as pq
import glearray.{type Array}
import grid.{type Grid}
import point.{type Point}
import simplifile

const step_cost = 1

const turn_cost = 1000

type Direction {
  North
  East
  South
  West
}

type Move {
  Move(pos: Point, cost: Int, dir: Direction)
}

pub fn main() {
  let #(board, start_pos, end_pos) = get_input()
  let height = grid.height(board)
  let width = grid.width(board)
  let min_score = find_min_path(board, height, width, start_pos, end_pos)
  io.debug(min_score)
}

fn get_input() -> #(Grid(String), Point, Point) {
  let assert Ok(contents) = simplifile.read(from: "./inputs/day15.test.txt")
  let board_rows = string.split(contents, "\n")
  let #(board_list, start_pos, end_pos) =
    list.index_fold(
      board_rows,
      #([], Point(-1, -1), Point(-1, -1)),
      fn(acc, line, row_index) {
        let spaces = string.split(line, "")
        let start_pos = case find_index(spaces, "S", 0) {
          Ok(col_index) -> Point(row_index, col_index)
          _ -> acc.1
        }
        let end_pos = case find_index(spaces, "E", 0) {
          Ok(col_index) -> Point(row_index, col_index)
          _ -> acc.2
        }
        #([spaces, ..acc.0], start_pos, end_pos)
      },
    )
  let valid_pos =
    start_pos.x != -1 && start_pos.y != -1 && end_pos.x != -1 && end_pos.y != -1
  case valid_pos {
    True -> #(grid.from_list(list.reverse(board_list)), start_pos, moves)
    _ -> panic
  }
}

fn find_index(
  haystack: List(String),
  needle: String,
  index: Int,
) -> Result(Int, Nil) {
  case haystack {
    [head, ..] if head == needle -> Ok(index)
    [_, ..rest] -> find_index(rest, needle, index + 1)
    _ -> Error(Nil)
  }
}

fn find_min_path(
  board: Array(Array(String)),
  height: Int,
  width: Int,
  start_pos: Point,
  end_pos: Point,
) -> Int {
  let start_move = Move(pos: start_pos, cost: 0, dir: East)
  let moves = pq.push(pq.new(compare_move), start_move)
  case a_star(board, end_pos, dict.new(), moves) {
    Ok(cost) -> cost
    Error(_) -> panic
  }
}

fn a_star(
  board: Array(Array(String)),
  goal_pos: Point,
  visited: Dict(Point, Bool),
  next_moves: Queue(Move),
) -> Result(Int, Nil) {
  case next_moves.pop() {
    Ok(#(move, remaining_moves)) -> {
      let has_arrived = move.pos.x == goal_pos.x && move.pos.y == goal_pos.y
      case has_arrived {
        True -> Ok(move.cost)
        False -> {
          let visited = dict.set(visited, move.pos, True)
          let valid_moves = find_valid_moves(board, move, visited)
          case valid_moves {
            [] -> Error(Nil)
            moves -> {
              let next_moves = list.fold(moves, remaining_moves, pq.push)
              a_star(board, goal_pos, visited, next_moves)
            }
          }
        }
      }
    }
    Error(Nil) -> Error(Nil)
  }
}

fn find_valid_moves(
  board: Grid(String),
  cur_move: Move,
  visited: Dict(Point, Bool),
) -> List(Move) {
  let potential_moves =
    list.append([forward_move(cur_move)], side_moves(cur_move))
  let width = grid.width(board)
  let height = grid.height(board)
  let valid_moves =
    list.filter(potential_moves, fn(move) {
      move.pos.x >= 0
      && move.pos.x < width
      && move.pos.y >= 0
      && move.pos.y < height
      && !dict.has_key(visited, move.pos)
    })
}

fn best_case_cost(height: Int, width: Int) -> Int {
  case height, width {
    h, w if h == 0 -> w
    h, w if w == 0 -> h
    h, w -> height + width + 1000
  }
}

fn worst_case_cost(height: Int, width: Int) -> Int {
  let hypotenuse =
    float.square_root(int.power(height, 2) +. int.power(width, 2))
  let move_count = float.truncate(float.ceiling(hypotenuse))
  move_count * turn_cost + move_count * step_cost
}

fn compare_move(a: Move, b: Move) -> Order {
  int.compare(a.cost, b.cost)
}

fn forward_move(cur_move: Move) -> Move {
  case cur_move.dir {
    North ->
      Move(pos: Point(..cur_move.pos, y: y - 1), dir: cur_move.dir, cost: 1)
    East ->
      Move(pos: Point(..cur_move.pos, x: x + 1), dir: cur_move.dir, cost: 1)
    South ->
      Move(pos: Point(..cur_move.pos, y: y + 1), dir: cur_move.dir, cost: 1)
    West ->
      Move(pos: Point(..cur_move.pos, x: x - 1), dir: cur_move.dir, cost: 1)
  }
}

fn side_moves(cur_move: Move) -> List(Move) {
  case cur_move.dir {
    North -> [
      Move(
        pos: point.add(cur_move.pos, Point(y: 0, x: -1)),
        dir: West,
        cost: 1001,
      ),
      Move(
        pos: point.add(cur_move.pos, Point(y: 0, x: 1)),
        dir: East,
        cost: 1001,
      ),
    ]
    South -> [
      Move(
        pos: point.add(cur_move.pos, Point(y: 0, x: -1)),
        dir: West,
        cost: 1001,
      ),
      Move(
        pos: point.add(cur_move.pos, Point(y: 0, x: 1)),
        dir: East,
        cost: 1001,
      ),
    ]
    East -> [
      Move(
        pos: point.add(cur_move.pos, Point(y: -1, x: 0)),
        dir: North,
        cost: 1001,
      ),
      Move(
        pos: point.add(cur_move.pos, Point(y: 1, x: 0)),
        dir: South,
        cost: 1001,
      ),
    ]
    West -> [
      Move(
        pos: point.add(cur_move.pos, Point(y: -1, x: 0)),
        dir: North,
        cost: 1001,
      ),
      Move(
        pos: point.add(cur_move.pos, Point(y: 1, x: 0)),
        dir: South,
        cost: 1001,
      ),
    ]
  }
}

fn opposite_dir(dir: Direction) -> Direction {
  case dir {
    North -> South
    East -> West
    South -> North
    West -> East
  }
}
