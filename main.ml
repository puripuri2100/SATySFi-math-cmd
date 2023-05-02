open Printf
open Str
open Sys


type cmd_info = {
  name: string;
  arg: int;
}

let cmd_list = ref []


(*input_fileから一行ずつ取得してcmd_listに格納*)
let parse filename =
  let re = Str.regexp {|^[^%]*direct[^\\]*\(\\[-a-zA-Z1-9]+\)[^:]*:[^a-z;]+\([a-z; ]*\)[^a-z;]+math-cmd.*$|} in
  let parse_cmd_info s =
    if Str.string_match re s 0 then
      let cmd_name = Str.global_replace re {|\1|} s in
      let arg_str = Str.global_replace re {|\2|} s in
      let arg_lst = Str.split (Str.regexp {|;[^a-z; ]*|}) arg_str in
      if List.for_all (fun s -> String.equal (String.trim s) "math") arg_lst then
        if String.equal cmd_name "\\and-also" then
          (* コマンドの中身がスペースであるため、排除 *)
          None
        else
          Some({
            name = cmd_name;
            arg  = List.length arg_lst;
          })
      else
        None
    else
      None
  in
  let fin = open_in filename in
  let rec cat_sub () =
    let s = input_line fin in
    match parse_cmd_info s with
    | None -> cat_sub ()
    | Some(info) -> (
      cmd_list := info :: !cmd_list;
      cat_sub ()
    )
  in
    try cat_sub () with End_of_file -> close_in fin


let rec arg_saty n m =
  if n == m then
    ""
  else
    let s = 97 + n |> Char.chr |> Char.escaped in
    (Printf.sprintf "{%s}" s) ^ (arg_saty (n + 1) m)

let saty_str import_str cmd_lst =
  let cmd_lst_s =
    cmd_lst
    |> List.map (fun info -> (
      Printf.sprintf "| %s%s\n" info.name (arg_saty 0 info.arg)
    ))
    |> List.fold_left (^) ""
  in
  Printf.sprintf "@import: math-cmd
%s
document ${
%s
|}\n" import_str cmd_lst_s


let md_str dir label cmd_lst =
  let cmd_lst_s =
    cmd_lst
    |> List.mapi (fun n info -> (
      Printf.sprintf "| `%s` | ![%s](./%s/%s-%d.png) |\n" info.name info.name dir label (n+1)
    ))
    |> List.fold_left (^) ""
  in
  Printf.sprintf "
|コマンド名|結果|
|:---------|:--------|
%s\n" cmd_lst_s


let main () =
  let argv = Sys.argv in
  let input_path = Array.get argv 1 in
  let import_str = Array.get argv 2 in
  let label = Array.get argv 3 in
  let output_img_dir = Array.get argv 4 in
  let output_saty_path = label ^ ".saty" in
  let output_md_path = label ^ ".md" in

  let () = parse input_path in
  let cmd_lst = List.rev !cmd_list in

  let output_saty = open_out output_saty_path in
  fprintf output_saty "%s" (saty_str import_str cmd_lst);
  close_out output_saty;

  let output_md = open_out output_md_path in
  fprintf output_md "%s" (md_str output_img_dir label cmd_lst);
  close_out output_md;

  ()


let () = main ()
