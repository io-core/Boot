(* begin-module-use-description
Module HAL (.a64) exercises features of the compiler in bringing Oberon up from bare metal on aarch64.

end-module-use-description *)
(* begin-module-develop-description
Module HAL (.a64) exercises features of the compiler in bringing Oberon up from bare metal on aarch64.

end-module-develop-description *)
MODULE* HAL;
  IMPORT SYSTEM;
  
  CONST
    rsData = -56; 
    rsCtrl = -52;

  TYPE

  VAR


  (* begin-procedure-description
---
**Init** simply returns.
  end-procedure-description *)
PROCEDURE Init( i: INTEGER);
  VAR x, y, z: INTEGER;
BEGIN
  SYSTEM.PUT(rsData,i)
(*
  LED(1); z := 0;
  REPEAT LED(z); x := 1000;
     REPEAT y := 1000;
       REPEAT y := y-1 UNTIL y = 0;
       x := x-1
     UNTIL x = 0;
     z := z+1
  UNTIL FALSE
*)
END Init;


  (* begin-procedure-description
---
**The initialzation code for this module** calls Init and then goes into an infinite loop.
  end-procedure-description *)
BEGIN Init(ORD("O")); Init(ORD("b")); Init(ORD("e")); Init(ORD("r")); Init(ORD("o")); Init(ORD("n")); 
  WHILE TRUE DO END
END HAL.
