
type game = {
  id: int;
  is_valid: bool;
}

type constraints = {
  max_red: int;
  max_green: int;
  max_blue: int;
}

let maxes = {
  max_red = 12;
  max_green = 13;
  max_blue = 14;
}

let red_regexp = Str.regexp {|\([0-9]+\) red|}
let green_regexp = Str.regexp {|\([0-9]+\) green|}
let blue_regexp = Str.regexp {|\([0-9]+\) blue|}

let parse_color_count regex round_string =
  try
    let _ = Str.search_forward regex round_string 0 in
    int_of_string (Str.matched_group 1 round_string);
  with Not_found ->
    0

let validate_round round_string =
  let red_count = parse_color_count red_regexp round_string in
  let green_count = parse_color_count green_regexp round_string in
  let blue_count = parse_color_count blue_regexp round_string in
  if red_count > maxes.max_red || green_count > maxes.max_green || blue_count > maxes.max_blue then
    false
  else
    true

let validate_game game_index game_string =
  let round_strings = Str.split (Str.regexp ";") game_string in
  let rounds = List.map validate_round round_strings in
  { id = game_index + 1; is_valid = List.for_all Fun.id rounds }

let valid_game_summer accumulator game =
  if game.is_valid then
    accumulator + game.id
  else
    accumulator

let () = 
  let game_strings = In_channel.with_open_text "inputs/day2.txt" In_channel.input_lines in
  let games = List.mapi validate_game game_strings in
  let sum = List.fold_left valid_game_summer 0 games in
  print_endline (string_of_int sum)