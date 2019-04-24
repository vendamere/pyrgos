open Syntax

type gamma = (symbol*ty) list

let rec check (g : gamma) (e : unit expr) (t : ty) : bool =
  match e with
  | Lambda (arg, body) ->
    (match t with
    | Func (t1, t2) -> check ((arg, t1) :: g) body t2
    | _ -> false (* We have no type aliasiang mechanism *))
  | _ -> synthesize g e = Some t

and synthesize (g : gamma) : unit expr -> ty option = function
  | Annotate (e, t) -> if check g e t then Some t else None
  | Appl (f, x) ->
    (match synthesize g f with
    | Some (Func (t1, t2)) -> if check g x t1 then Some t2 else None
    | _ -> None)
  | Atom _ -> Some (TVar "Atom") (* The Atom type is an infinite disjunction. *)
  | Lambda _ -> None (* There is no synthesis rule for lambdas *)
  | Quote e -> Some (TVar "Expr")
  | Symbol v ->
    (match List.find_all (fst >> (=) v) g with
    | [(_, t)] -> Some t
    | _ -> None)
