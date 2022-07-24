(* class and dispatch *)
class Silly {
  copy() : SELF_TYPE { self };
};

(* inherits *)
class Sally inherits Silly { };

(*type string and more*)
class P {
  f(): Int { 1 };
  };
  class C inherits P {
  f(): String { "1" };
};

(* dispatch*)
class M {
  x : Sally <- (new Sally).copy();
  p : P <- (new P);
  main() : Sally { x };
};

(* if and let*)
class Mn inherits IO {
  main(): Object {{
    out_string("Enter an integer greater-than or equal-to 0: ");

    let input: Int <- in_int() in
      if input < 0 then
        out_string("ERROR: Number must be greater-than or equal-to 0\n")
      else {
        out_string("The factorial of ").out_int(input);
        out_string(" is ").out_int(factorial(input));
        out_string("\n");
      }
      fi;
  }};

  factorial(num: Int): Int {
    if num = 0 then 1 else num * factorial(num - 1) fi
  };
};

(* New *)
cLass Ma {
  i : IO <- new IO;
  main() :Object { i.out_string("Hello World") };
};

(* while *)
cLass Me {
  i : IO <- new IO;
  main() :Object {
    let x : Int <- 3 in
      while x <= 0 loop x <- 0 pool
  };
};

(*  case *)
cLass Main {
  i : IO <- new IO;
  main() :Object {
    let x : Int <- 3 in
      case x of
        x: Int => 3;
        x: Int => 4;
      esac
  };
};