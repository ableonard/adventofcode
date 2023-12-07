let num_regex = Str.regexp {|[0-9]\|one\|two\|three\|four\|five\|six\|seven\|eight\|nine|}

let get_numeral_from_regex found_match = 
  match found_match with
  | "one" -> "1"
  | "two" -> "2"
  | "three" -> "3"
  | "four" -> "4"
  | "five" -> "5"
  | "six" -> "6"
  | "seven" -> "7"
  | "eight" -> "8"
  | "nine" -> "9"
  | n -> n

let get_first_num line = 
  let _ = Str.search_forward num_regex line 0 in
    get_numeral_from_regex (Str.matched_string line)

let get_last_num line = 
  let line_length = String.length line in
  let _ = Str.search_backward num_regex line line_length in
    get_numeral_from_regex (Str.matched_string line)

let get_nums_from_line line =
  let first = get_first_num line in
  let last = get_last_num line in
    first ^ last

let string_nums_reducer sum string_num = sum + int_of_string string_num

let () = 
  let lines = In_channel.with_open_text "inputs/day1.txt" In_channel.input_lines in
  let string_nums = List.map get_nums_from_line lines in
  let sum = List.fold_left string_nums_reducer 0 string_nums in
  print_endline (string_of_int sum)