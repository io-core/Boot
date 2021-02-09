(* begin-module-use-description
Module HAL (.a32) exercises features of the compiler in bringing Oberon up from bare metal on 32-bit ARM.

end-module-use-description *)
(* begin-module-develop-description
Module HAL (.a32) exercises features of the compiler in bringing Oberon up from bare metal on 32-bit ARM..

end-module-develop-description *)
MODULE* HAL;
  IMPORT SYSTEM;
  
  CONST
    MTOrg    = 40001000H;
    rsData   = 9000000H; 
    rsCtrl   = -52;
    MT = 12; SP = 14; LNK = 15;   (*dedicated registers RISC5 ordinal*)

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
BEGIN SYSTEM.LDREG(MT, MTOrg); 
      Init(ORD("O")); Init(ORD("b")); Init(ORD("e")); Init(ORD("r")); Init(ORD("o")); Init(ORD("n"));
  WHILE TRUE DO END
END HAL.
