(* models one-dimensional cellular automaton on a circle of finite radius
   arrays are faked as Strings,
   X's respresent live cells, dots represent dead cells,
   no error checking is done *)

(*
    Foi adicionado mais alguns testes no arquivo test.cl.
    Houve a inclusão de testes que faltavam, como testes de atribuição, comentário,
    atribuição de caractere inválido, atribuições de tipos incorretos e
    checagem de tipos implementados, 

*)
class CellularAutomaton inherits IO {
    population_map : String;
   
    init(map : String) : SELF_TYPE {
        {
            population_map <- map;
            self;
        }
    };
   
    print() : SELF_TYPE {
        {
            out_string(population_map.concat("\n"));
            self;
        }
    };
   
    num_cells() : Int {
        population_map.length()
    };
   
    cell(position : Int) : String {
        population_map.substr(position, 1)
    };
   
    cell_left_neighbor(position : Int) : String {
        if position = 0 then
            cell(num_cells() - 1)
        else
            cell(position - 1)
        fi
    };
   
    cell_right_neighbor(position : Int) : String {
        if position = num_cells() - 1 then
            cell(0)
        else
            cell(position + 1)
        fi
    };
   
    (* a cell will live if exactly 1 of itself and it's immediate
       neighbors are alive *)
    cell_at_next_evolution(position : Int) : String {
        if (if cell(position) = "X" then 1 else 0 fi
            + if cell_left_neighbor(position) = "X" then 1 else 0 fi
            + if cell_right_neighbor(position) = "X" then 1 else 0 fi
            = 1)
        then
            "X"
        else
            "." (* Altera para aspa dupla *)
        fi
    };
   
    evolve() : SELF_TYPE {
        (let position : Int in
        (let num : Int <- num_cells[] in
        (let temp : String in
            {
                while position < num loop
                    {
                        temp <- temp.concat(cell_at_next_evolution(position));
                        position <- position + 1;
                    }
                pool;
                population_map <- temp;
                self;
            }
        ) ) )
    };

};

class Main {
    cells : CellularAutomaton;

    (* Testa algumas implementações do arq cool.flex *)
	--single line comment check-- (* testa a criação de uma comentário inline *)
    bool_val : Bool <- true;      (* testa o tipo Bool *)
	bool_val2 : Bool <- false;    (* testa novamente o tipo Bool type *)
	numb : Int <- 1;              (* testa o tipo Int *)


    _invalid_void : Void;  (* testa caractere inválido)
    &invalid_int : Int;    (* testa outro caractere inválido)

    str : String [ <- "Hello World" ]; (* Testa string incorreta*)

    main() : SELF_TYPE {
        {

            if (isVoid cells) then out_string("cells is void"); (* testa isVoid *)
            if(not isVoid str) then out_string("str is not void"); (* testa not *)

            (* Testa alguns testes com a keyword case *)
            case cells.cell_right_neighbor(1) of
                a : CellularAutomaton => out_string("a e do tipo CellularAutomaton");
                b : Void   => out_string("b e do tipo Void");
                c : Int    => out_string("c e do tipo Int");
                d : String => out_string("d e do tipo String");
            esac

            cells <- (new CellularAutomaton).init("         X         ");
            cells.print();
            (let countdown : Int <- 20 in
                while 0 < countdown loop   (* cool não tem > *)
                    {
                        cells.evolve();
                        cells.print();
                        countdown <- countdown - 1;
                    
                pool
            );  (* end let countdown -> fecha comentário aqui *)
            self;
        }
    };
};

