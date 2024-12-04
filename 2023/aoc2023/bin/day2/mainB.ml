let red_regexp = Str.regexp {|\([0-9]+\) red|}
let green_regexp = Str.regexp {|\([0-9]+\) green|}
let blue_regexp = Str.regexp {|\([0-9]+\) blue|}

let parse_color_count regex round_string =
  try
    let _ = Str.search_forward regex round_string 0 in
    int_of_string (Str.matched_group 1 round_string);
  with Not_found ->
    0

let parse_game game_string =
  let round_strings = Str.split (Str.regexp ";") game_string in
  let reds = List.map (parse_color_count red_regexp) round_strings in
  let greens = List.map (parse_color_count green_regexp) round_strings in
  let blues = List.map (parse_color_count blue_regexp) round_strings in
  let max_red = List.fold_left Int.max (List.hd reds) reds in
  let max_green = List.fold_left Int.max (List.hd greens) greens in
  let max_blue = List.fold_left Int.max (List.hd blues) blues in
  max_red * max_green * max_blue

let () = 
  let game_strings = In_channel.with_open_text "inputs/day2.txt" In_channel.input_lines in
  let games = List.map parse_game game_strings in
  let sum = List.fold_left (+) 0 games in
  print_endline (string_of_int sum)