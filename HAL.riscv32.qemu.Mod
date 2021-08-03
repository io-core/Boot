(* begin-module-short-description
provides a Hardware Abstraction Layer for 32-bit riscv.
end-module-short-description *)

(* begin-module-use-description
Module HAL (.v32) exercises features of the compiler in bringing Oberon up from bare metal on 32-bit RISCV.

end-module-use-description *)
(* begin-module-develop-description
The HAL prepares the Oberon runtime and so cannot rely on it. 

* No global variables
* No strings
* No heap allocation

The first thing HAL must do is set up its own stack.

Each platform should have its own HAL. This is the HAL for riscv32 on QEMU.

The HAL remains resident and may be used by other modules.

end-module-develop-description *)
MODULE* HAL;
  IMPORT SYSTEM;
  
  CONST
    stackOrg = 87FFF000H;
    MTOrg    = 80001000H;
    rsData   = 10000000H;
    FDBPtr   =     1020H;         (*holds the location of the start of the FDTB*)
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
BEGIN SYSTEM.LDREG(SP, stackOrg); 
      SYSTEM.LDREG(MT, MTOrg); 
      Greet;
      Init;
      WHILE TRUE DO END
END HAL.
