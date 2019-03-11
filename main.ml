open Printf
open Str


let libdir = "/usr/local/share/satysfi/"
let filename = "dist/packages/math.satyh"
let input_file = libdir ^ filename
let output_file_saty = "main.saty"
let output_file_md = "math-cmd.md"

let cmd_list = ref []

(*input_fileから一行ずつ取得してcmd_listに格納*)
let cat filename =
  let fin = open_in filename in
  let rec cat_sub () =
    cmd_list := (input_line fin) :: !cmd_list;
    cat_sub ()
  in
    try cat_sub () with End_of_file -> close_in fin

let () = cat input_file

let () = cmd_list := List.rev !cmd_list

(* `  direct \cmd : [] math-cmd` の行だけ取り出し*)
let reg = Str.regexp "[^%]* direct .* \[\] math-cmd"
let direct_line r s = Str.string_match r s 0
let cmd_list_2 = List.filter (direct_line reg) !cmd_list


(* `direct \cmd : [] math-cmd` から`\cmd`以外の部分を消去*)
let reg_cmd_1 = Str.regexp ":.*"
let reg_cmd_2 = Str.regexp "direct"
let cmd_line_1 s = Str.replace_first reg_cmd_1 "" s
let cmd_line_2 s = Str.replace_first reg_cmd_2 "" s
let cmd_list_3 = List.map cmd_line_2 (List.map cmd_line_1 cmd_list_2)


let message_list = cmd_list_3


let message_saty =
    List.map (fun s -> "|" ^ s ^ "\n") message_list
      |> List.fold_left (^) ""


let cmd_num = ref 1

let s_n_list s =
  let () = cmd_num := !cmd_num + 1 in
  (s, !cmd_num)

let message_list_2 = List.map s_n_list message_list

let md_cell (s, n) =
  "| `" ^ s ^ "` |![" ^ s ^
    "](https://github.com/puripuri2100/SATySFi-math-cmd/blob/master/img/math-cmd-" ^ string_of_int n ^ ".png) |\n"

let message_md =
  List.map md_cell message_list_2
    |> List.fold_left (^) ""



(*.satyファイルに書き出す内容*)
let output_list_saty = [
    "@import: math-cmd";
    "@require: math";
    "document${";
    message_saty;
    "|}"
  ]
let output_saty =
  List.map (fun s -> s ^ "\n") output_list_saty
    |> List.fold_left (^) ""


(*.mdファイルに書き出す内容*)
let output_list_md = [
  "|コマンド名|結果|";
  "|:---------|:--------|";
    message_md;
  ]
let output_md =
  List.map (fun s -> s ^ "\n") output_list_md
    |> List.fold_left (^) ""



(*.satyファイルに書き出す*)
let () =
  let oc_saty = open_out output_file_saty in
  fprintf oc_saty "%s" output_saty;
  close_out oc_saty


(*.mdファイルに書き出す*)
let () =
  let oc_md = open_out output_file_md in
  fprintf oc_md "%s" output_md;
  close_out oc_md;
