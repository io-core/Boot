(* begin-module-short-description
provides a Hardware Abstraction Layer for aarch64 on the Pinephone.
end-module-short-description *)

(* begin-module-use-description
Module HAL (.a64) exercises features of the compiler in bringing Oberon up from bare metal on aarch64 on the Pinephone.

end-module-use-description *)
(* begin-module-develop-description
The HAL prepares the Oberon runtime and so cannot rely on it.

* No global variables
* No strings
* No heap allocation

The first thing HAL must do is set up its own stack.

Each platform should have its own HAL. This is the HAL for aarch64 on the Pinephone.

The HAL remains resident and may be used by other modules.

end-module-develop-description *)
MODULE* HAL;
  IMPORT SYSTEM;
  
  CONST
    stackOrg = 47FFF000H;
    MTOrg    = 40001000H;
    rsData   = 9000000H;
    FDTLoc   = 48000000H; (* At start R02 holds the location of the FDTB *)
    MT = 12; SP = 14; LNK = 15;   (*dedicated registers RISC5 ordinal*)

  TYPE

  VAR


  (* begin-procedure-description
---
**Greet** Transmits a greeting on the serial port.
  end-procedure-description *)
PROCEDURE Greet;
BEGIN
  SYSTEM.PUT(rsData,ORD("O"));
  SYSTEM.PUT(rsData,ORD("b"));
  SYSTEM.PUT(rsData,ORD("e"));
  SYSTEM.PUT(rsData,ORD("r"));
  SYSTEM.PUT(rsData,ORD("o"));
  SYSTEM.PUT(rsData,ORD("n"));
  SYSTEM.PUT(rsData,13);
  SYSTEM.PUT(rsData,10);
END Greet;

  (* begin-procedure-description
---
**Init** queries the system configuration, establishes the module store and the heap, and passes control to the Kernel.
  end-procedure-description *)
PROCEDURE Init;
  VAR x, y, z: INTEGER;
BEGIN

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
**The initialzation code for this module** establishes the stack and module table origin, transmits a greeting, and then calls Init.
  end-procedure-description *)
BEGIN SYSTEM.LDREG(0, stackOrg); 
      SYSTEM.REGREG(SP,0); (*can't load constants to SP directly on aarch64*)
      SYSTEM.LDREG(MT, MTOrg);
      Greet;
      Init;
      WHILE TRUE DO END
END HAL.
