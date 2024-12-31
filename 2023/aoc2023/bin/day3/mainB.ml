module PartLocation = struct
  module T = struct
    type t = int * int * int
    let compare (row0,start0,length0) (row1,start1,length1) =
      match Stdlib.compare row0 row1 with
          0 -> (
            if start1 <= start0 then
              if (start1 + length1) >= (start0 + length0) then
                0
              else
                1
            else
              -1
          )
        | c -> c
  end
  include T
  include Comparator.Make(T)
end

module PartLocationSet = Set.Make(PartLocation)

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

let rec get_part_locations_on_row (row : int) line start part_nums =
  try
    let index = Str.search_forward part_num_regexp line start in
    let matched_str = Str.matched_group 1 line in
    let matched_length = String.length matched_str in
    let part_location = (row, index, matched_length) in
    get_part_locations_on_row row line (index + matched_length) (PartLocationSet.add part_location part_nums)
  with
    Not_found -> part_nums

let get_part_locations_and_vals lines =
  let part_nums_on_rows = List.mapi (fun row line -> get_part_locations_on_row row line 0 PartLocationSet.empty) lines in
  let part_locations = List.fold_left (PartLocationSet.union) PartLocationSet.empty part_nums_on_rows in
  let part_values = List.fold_left in
  (part_locations, part_values)

let generate_edge_locations start_row start_col =
  let locations = PartLocationSet.empty
    |> PartLocationSet.add (start_row - 1, start_col - 1, 1)
    |> PartLocationSet.add (start_row, start_col - 1, 1)
    |> PartLocationSet.add (start_row + 1, start_col - 1, 1)
    |> PartLocationSet.add (start_row - 1, start_col, 1)
    |> PartLocationSet.add (start_row + 1, start_col, 1)
    |> PartLocationSet.add (start_row - 1, start_col + 1, 1)
    |> PartLocationSet.add (start_row, start_col + 1, 1)
    |> PartLocationSet.add (start_row + 1, start_col + 1, 1)
  in
  PartLocationSet.filter (fun (y,x,_) -> x >= 0 && x <= dims.width && y >= 0 && y <= dims.height) locations

let rec get_gear_ratios_on_row row line start gear_ratios part_locations =
  try
    let index = Str.search_forward symbol_regexp line start in
    let points_to_check = generate_edge_locations row index in
    Printf.printf "Checking edge locations on row %d:\n" row;
    PartLocationSet.iter (fun (x, y, len) -> Printf.printf "(%d, %d-%d)" x y (y + len)) points_to_check;
    print_newline ();
    let parts_touching = PartLocationSet.inter points_to_check part_locations in
    Printf.printf "Parts touching %d %d:\n" row index;
    PartLocationSet.iter (fun (x, y, len) -> Printf.printf "(%d, %d-%d)" x y (y + len)) parts_touching;
    print_newline ();
    if PartLocationSet.cardinal (parts_touching) == 2 then
      let gear_ratio = PartLocationSet.fold (fun part ratio -> let (_,_,_,part_val) = part in ratio * part_val) parts_touching 1 in
      get_gear_ratios_on_row row line (index + 1) (gear_ratio :: gear_ratios) part_locations
    else
      get_gear_ratios_on_row row line (index + 1) gear_ratios part_locations
  with 
    Not_found -> 
      Printf.printf "Gear Ratios on line %d: \n" row;
      List.iter (fun r -> Printf.printf "%d," r) gear_ratios;
      print_newline ();
      gear_ratios

let get_gear_ratios lines =
  let (part_locations, part_values) = get_part_locations_and_vals lines in
  print_endline "Part locations:"; PartLocationSet.iter (fun (x,y,z) -> Printf.printf "(%d, %d-%d) " x y (y + z)) part_locations; print_newline ();
  print_endline "Part values: "; 
  List.concat (List.mapi (fun row line -> get_gear_ratios_on_row row line 0 [] part_locations) lines)

let () =
  let lines = In_channel.with_open_text "inputs/day3.txt" In_channel.input_lines in
  let gear_ratios = get_gear_ratios lines in
  print_endline "Gear Ratios:";
  List.iter (Printf.printf "%d,") gear_ratios;
  print_newline ();
  print_endline (string_of_int (List.fold_left (+) 0 gear_ratios))