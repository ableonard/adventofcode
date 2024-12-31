import gleam/int

pub type Point {
  Point(y: Int, x: Int)
}

pub fn add(a: Point, b: Point) -> Point {
  Point(y: a.y + b.y, x: a.x + b.x)
}

pub fn subtract(a: Point, b: Point) -> Point {
  Point(y: a.y - b.y, x: a.x - b.x)
}

pub fn distance(a: Point, b: Point) -> Point {
  Point(y: int.absolute_value(a.y - b.y), x: int.absolute_value(a.x - b.x))
}
