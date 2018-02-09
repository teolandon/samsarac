open Printf

(* Returns the numeric value of the given char, given it's a digit *)
let int_of_char ch =
  (Pervasives.int_of_char ch) - 48

exception Lexing_error of string

(* Returns Some char if the stream still has characters left,
 * and None if there are no characters left
 *)
let safe_read_char ic =
  try
    Some (input_char ic)
  with End_of_file ->
    None

let seekback ic =
  seek_in ic ((pos_in ic) - 1)

(* Boolean checks for chars *)

let is_whitespace ch =
  match ch with
  | ' ' | '\n' | '\r' | '\t' -> true
  | _                        -> false

let ends_int ch =
  match ch with
  | c when is_whitespace c -> true
  | '(' | ')'              -> true
  | _                      -> false

let is_digit ch =
  match ch with
  | '0'..'9' -> true
  | _        -> false

let is_alphabetic ch =
  match ch with
  | 'a'..'z' | 'A'..'Z' -> true
  | _        -> false

let is_chevron ch =
  match ch with
  | '<' | '>' -> true
  | _         -> false

(* Converts a list of chars to a string using the
 * Buffer module in an attempt to be more efficient
 *)
let string_of_charlist chars =
  let buf = Buffer.create (List.length chars) in
  List.iter (Buffer.add_char buf) chars;
  Buffer.contents buf

(* Converts an integer i to a floating point number equal to
 * the representation 0.i
 *)
let to_mantissa i =
  let rec get_divident i =
    match i with
    | 0 -> 1
    | _ -> 10 * (get_divident (i / 10))
  in
  (float_of_int i) /. (float_of_int (get_divident i))

(* Reads a number, returns either an integer literal or a
 * float literal
 *)
let rec read_num ic digit_list:(Parser.token) =
  let rec calc_int curr_mult curr_int curr_digit_list =
    match curr_digit_list with
    | []     -> curr_int
    | (h::t) ->
        let new_part_int = h * curr_mult in
        calc_int (curr_mult * 10) (new_part_int + curr_int) t
  in
  let finalize_int () =
    seekback ic;
    Parser.EInt (calc_int 1 0 digit_list)
  in
  let next = safe_read_char ic in
  match next with
  | None                     -> finalize_int ()
  | Some ch when ends_int ch -> finalize_int ()
  | Some digit when is_digit digit ->
      read_num ic ((int_of_char digit)::digit_list)
  | Some '.' ->
      let float_integral   = float_of_int (calc_int 1 0 digit_list) in
      let float_fractional = match read_num ic [] with
      | Parser.EInt fractional -> to_mantissa fractional
      | _ -> raise (Lexing_error "Bad floating point number")
      in
      Parser.EFloat (float_integral +. float_fractional)
  | _ -> raise (Lexing_error "Invalid end of integer")

(* Reads a string from stream ic until it reaches a
 * terminating character, and then seeks back to make
 * sure that the terminating character is not consumed.
 *)
let rec read_string ic char_list =
  let finalize_str () =
    seekback ic;
    string_of_charlist (List.rev char_list)
  in
  let next = safe_read_char ic in
  match next with
  | None                     -> finalize_str ()
  | Some ch when ends_int ch -> finalize_str ()
  | Some ch when is_alphabetic ch ->
      read_string ic (ch::char_list)
  | _ -> raise (Lexing_error "Invalid end of string")

(* Does the heavy lexing, with all the cases, etc. *)
let rec lex_h ic tokenList =
  let read_num_h i =
    read_num ic [i]
  in
  let read_string_h ch =
    read_string ic [ch]
  in
  let ch = safe_read_char ic in
  match ch with
  | None  -> List.rev tokenList
  | Some c ->
      let newList =
        match c with
        | '('   -> Parser.ELeftParen :: tokenList
        | ')'   -> Parser.ERightParen :: tokenList
        | '+'   -> Parser.EOp Parser.EPlus :: tokenList
        | '-'   -> Parser.EOp Parser.EMinus :: tokenList
        | '*'   -> Parser.EOp Parser.EMult :: tokenList
        | '/'   -> Parser.EOp Parser.EDiv :: tokenList
        | '%'   -> Parser.EOp Parser.EMod :: tokenList
        | ch when is_chevron ch ->
            let next = safe_read_char ic in
            let (token:Parser.token) =
              match (ch, next) with
              | ('<', Some '=') -> Parser.EComp Parser.ELessEq
              | ('>', Some '=') -> Parser.EComp Parser.EGreaterEq
              | ('<', None) -> Parser.EComp Parser.ELess
              | ('>', None) -> Parser.EComp Parser.EGreater
              | ('<', Some ch) when ends_int ch ->
                  seekback ic; Parser.EComp Parser.ELess
              | ('>', Some ch) when ends_int ch ->
                  seekback ic; Parser.EComp Parser.EGreater
              | _ -> raise (Lexing_error "Invalid sequence after comparison")
            in
            token :: tokenList
        | ch when is_alphabetic ch ->
            (match (read_string_h ch) with
            | "true"  -> Parser.EBool true  :: tokenList
            | "false" -> Parser.EBool false :: tokenList
            | "if"    -> Parser.EIf         :: tokenList
            | "NaN"   -> Parser.ENaN        :: tokenList
            | _       -> raise (Lexing_error "Invalid string")
            )
        | '0'..'9' ->
            read_num_h (int_of_char c) :: tokenList
        | ' ' | '\n' | '\r' | '\t' -> tokenList
        |  _  -> raise (Lexing_error "Invalid char")
      in
      lex_h ic newList

let lex file =
  let ic = open_in file in
  lex_h ic []
