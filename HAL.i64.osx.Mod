(* begin-module-short-description
provides a Hardware Abstraction Layer for x86_64 in OSX userspace.
end-module-short-description *)

(* begin-module-use-description
Module HAL (.i64.osx) exercises features of the compiler in bringing Oberon up under OSX on x86_64.

end-module-use-description *)
(* begin-module-develop-description
The HAL prepares the Oberon runtime and so cannot rely on it.

* No global variables
* No strings
* No heap allocation

The first thing HAL must do is set up its own stack.

Each platform should have its own HAL. This is the HAL for x86_64 on QEMU.

The HAL remains resident and may be used by other modules.

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
