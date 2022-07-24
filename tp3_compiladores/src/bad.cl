
(*
 *  execute "coolc bad.cl" to see the error messages that the coolc parser
 *  generates
 *
 *  execute "myparser bad.cl" to see the error messages that your parser
 *  generates
 *)

(* no error *)
class A {
};

(* error:  b is not a type identifier *)
Class b inherits A {
};

(* error:  a is not a type identifier *)
Class C inherits a {
};

(* error:  keyword inherits is misspelled *)
Class D inherts A {
};

(* error: TYPEID errado *)
class P {
    f(): intt { 1 };
};

(* error: let sem OBJECTID  *)
class Q{
    f(): Int {
        let in {
            x <- x + 3;
        }
    } 
}

(* error: operador errado *)
class Q{
    f(): Int {
        let x : Int <- 3 in
            x <- x $ 3;
    }
}

(* error: expressão sem expressão *)
class R{
    f(): Int {
        let x:Int <- 3 in ;
    }
}
(* error: faltando TYPEID *)
class P {
    f(): { 1 };
};