module IntPairs =
  struct
    type t = int * int
    let compare (x0,y0) (x1,y1) =
      match Stdlib.compare x0 x1 with
          0 -> Stdlib.compare y0 y1
        | c -> c
  end

module PairsSet = Set.Make(IntPairs)

type dimensions = {
  height: int;
  width: int;
}
let dims = {
  height = 140;
  width = 140;
}

let symbol_regexp = Str.regexp {|[^0-9.]|}
let part_num_regexp = Str.regexp {|\([0-9]+\)|}

let rec get_symbol_locations_on_row row line start symbols =
  try
    let index = Str.search_forward symbol_regexp line start in
    get_symbol_locations_on_row row line (index + 1) (PairsSet.add (row, index) symbols)
  with 
    Not_found -> symbols

let get_symbol_locations_on_row row line =
  get_symbol_locations_on_row row line 0 PairsSet.empty

let get_symbol_locations lines =
  let symbols_by_row = List.mapi get_symbol_locations_on_row lines in
  List.fold_left (PairsSet.union) PairsSet.empty symbols_by_row

let generate_edge_locations start_row start_col length =
  let above_and_below_pairs = List.init length (fun i -> PairsSet.empty |> PairsSet.add (start_row - 1, start_col + i) |> PairsSet.add (start_row + 1, start_col + i)) in
  let above_and_below_set = List.fold_left (fun acc pairs -> PairsSet.union acc pairs) PairsSet.empty above_and_below_pairs in
  let locations = PairsSet.empty
    |> PairsSet.add (start_row - 1, start_col - 1)
    |> PairsSet.add (start_row, start_col - 1)
    |> PairsSet.add (start_row + 1, start_col - 1)
    |> PairsSet.add (start_row - 1, start_col + length)
    |> PairsSet.add (start_row, start_col + length)
    |> PairsSet.add (start_row + 1, start_col + length)
    |> PairsSet.union above_and_below_set
  in
  PairsSet.filter (fun (y,x) -> x >= 0 && x <= dims.width && y >= 0 && y <= dims.height) locations

let rec get_valid_part_nums_on_row row line symbols start valid_part_nums =
  try
    let index = Str.search_forward part_num_regexp line start in
    let matched_str = Str.matched_group 1 line in
    let matched_length = String.length matched_str in
    let points_to_check = generate_edge_locations row index matched_length in
    if PairsSet.cardinal (PairsSet.inter points_to_check symbols) > 0 then
      get_valid_part_nums_on_row row line symbols (index + matched_length) ((int_of_string matched_str) :: valid_part_nums)
    else
      get_valid_part_nums_on_row row line symbols (index + matched_length) valid_part_nums
  with
    Not_found -> valid_part_nums

let get_valid_part_nums lines =
  let symbols = get_symbol_locations lines in
  List.concat (List.mapi (fun row line -> get_valid_part_nums_on_row row line symbols 0 []) lines)

let () =
  let lines = In_channel.with_open_text "inputs/day3.txt" In_channel.input_lines in
  let part_nums = get_valid_part_nums lines in
  print_endline (string_of_int (List.fold_left (+) 0 part_nums))