(* begin-documentation-node
###############
Porting
###############

Integrated Oberon is a self-contained development environment capable of re-creating from its source code all its own executable binary files and of upgrading itself in-place.

However IO currently lacks source code revision control and tools for project coordination and OS virtualization.

Currently an IO developer uses a host OS such as Linux, Mac or Windows to check in and check out code and to build Integrated Oberon disk images.

Process
========

The development cycle is as follows:

1. Check out the source code from https://github.com/io-core/io, including subrepositories
2. Check out additional non-core repositories for additional desired (perhaps private) modules
3. Edit the source code of a module (or create one)
4. Edit the startup script to include invoking the compiler to compile the module file
5. Execute a batch script on the host which creates an IO disk image including the source and the startup script
6. Observe any compiler errors, goto step 3
7. Exercise the module within the emulator, observe any undesired behavior or runtime errors, goto step 3
8. add the changed files to revision control, with appripriate commit messages
9. push changes or make pull requests for the changes as appropriate

Tasks
======

Integrated Oberon needs three things to run on a new platform:

1. A Compiler Target
2. A Boot Shim
3. A Hardware Abstraction Layer
4. Device Drivers

Some of these may already exist for an intended target platform.

Make a Compiler Target
-----------------------

The Integrated Oberon compiler 'OXP' can create module binaries for the following architectures via a flag:

* /r RISC5 
* /I x86_64 (very limited functionality)
* /A aarch64 (very limited functionality)
* /a arm 32 (very limited functionality)
* /V riscv64 (very limited functionality)
* /v riscv32 (very limited functionality)

Support for additinal architectures can be added by modifying OXG.Mod and OXX.Mod in the Build package and may require changes in other core Oberon packages.

Create a Boot Shim
-------------------

Each hardware platform expects an operating system to conform to that platform's expectations of a bootable OS image. Modern PCs expect a PE+ UEFI file placed in a specific location on a FAT32 volume for example, while phones, tablets, and IOT devices often expect an ELF file at a specific sector location or a pure binary executable image placed in flash at a memory offset.

IO prepends a boot shim conforming to these expectations in front of the actual Integrated Oberon HAL and core modules. This boot shim should be very small and should do the least amount of work possible to pass execution and some configuration settings to the HAL.

The boot shim may be coded in Oberon or may not be necessary but often will be written in the assembly language of the platform and assembled outside of Oberon.

An OS may also host Integrated Oberon as a userspace application, in which the boot shim may be a C program using host OS libraries to provide storage, memory, a framebuffer, etc. to Oberon. In addition, the shim may provide a bridge between host OS command invocation and an executing Oberon subsystem, for example by presenting Oberon as the interpreter for compiled Oberon modules, e.g. \#!/usr/bin/env Oberon, with the Oberon 'interpreters' coordinating a single application interpreting all modules via unix FIFOs.

Make a Hardware Abstraction Layer
----------------------------------

Each platform will have unique devices, arrangements of devices, io register locations, initialization methods, etc. that may be abstracted over for starting the system and providing low-level facilities needed by the OS. Each platform will have a module that implements for its HAL the following:

* Memory Map Page Table initialization and operation, if necessary
* Initialization of essential run-time structures for the heap, stack, and module space
* Population of a system configuration data structure from bootloader provided system configuration data
* Interrupt table initialization and modification
* An initial serial device if present
* An initial video frame buffer if present
* A timer if present
* A means for enumerating dynamic busses with puggable bus drivers (e.g. pci and usb)

Write Device Drivers
---------------------

Each platform may have unique devices requiring specific device drivers. Integrated Oberon needs at least the following:

* Serial
* Keyboard and Mouse
* Video
* Block Storage Device
* Network

https://github.com/io-core/Boot/blob/main/BootLoad.Mod

end-documentation-node *)

(* begin-package-description

The Boot package manages:

* Loading the Oberon inner core from boot media
* Passing hardware configuration (FDT or UEFI table) to the Oberon Kernel

Each architecture may have several specific implementations of a Hardware Abastraction Layer.  For example:

* HAL.a64.qemu.Mod allows Oberon to boot on aarch64 emulated in QEMU
* HAL.a64.rpi4.Mod does the same on the 64-bit Raspberry Pi and
* HAL.v32.qemu.Mod boots Oberon on riscv32 emulated in QEMU while
* HAL.v32.bl602.Mod does the same on the BL602 IOT riscv device.
* HAL.i64.lin.Mod boots Oberon under Linux as a userspace process.

Each compilation or cross-compilation of Oberon will import only one of the HAL modules, referred to as 'HAL'.

The Bootloaders package also contains shell scripts used outside of Oberon to prepare an Oberon UEFI or raw binary image.

Preparing Boot and Distribution Media
====================

Generating a new Integrated Oberon image suitable for booting requires the following steps:

1. Compile the Inner Core modules (HAL, Kernel, FileDir, Files, Modules)
#. Collect the compiled HAL, Kernel, FileDir, Files, and Modules binary modules
#. Assemble the boot-<architecture>.S UEFI PE shim or ELF header shim
#. Place the Oberon modules at appropriate offsets in the PE or ELF shim
#. Place the PE or ELF file on the boot media or in the device firmware
#. Place IO distribution files in the root media
#. Boot

end-package-description *)

(* begin-module-short-description
loads the Inner Core from disk or serial.
end-module-short-description *)

(* begin-module-use-description
Module BootLoad is the firmware for the RISC Oberon platform.

    OXP.Compile BootLoad.Mod ~
    ORF.WriteFile BootLoad.rsc prom.mem ~                      

end-module-use-description *)

(* begin-package-development

Porting IO to a new platform in a supported CPU architecture requries:

1. Preparing a new HAL.<arch>.<platform>.Mod file
#. Adapting existing hardware modules or introducing new ones (e.g. Input and Display)
#. Recompiling all distribution modules dependent on modules who's interfaces have changed
#. Preparing the Boot and Distribution Media


end-package-development *)
(* begin-module-develop-description

The HAL needs to get the Inner Core into memory, prepare basic OS bookkeeping structures, and link the modules.
The HAL also abstracts some hardware features.

BootLoad doesn't have to work that hard. The RISC5 environment is so simple the hardware needs no abstracting.

In addition the classic RISC5 Linker prepares an already linked kernel with structures in place so BootLoad only needs to load
the kernel, place some integers in memory, and pass some values in registers to the kernel entry point.

end-module-develop-description *)
MODULE* BootLoad;  (*NW 20.10.2013 / PR 4.2.2014; boot from SDHC disk or line*)
  IMPORT SYSTEM;
  (* sw0: init SD; sw1: line|disk*)
  CONST 
    MT = 12; SP = 14; LNK = 15;
    MTOrg = 20H; MemLim = 0E7EF0H; stackOrg = 80000H;
    swi = -60; led = -60; rsData = -56; rsCtrl = -52;
    spiData = -48; spiCtrl = -44;
    CARD0 = 1; SPIFAST = 4;
    FSoffset = 80000H;   (*block offset*)
  TYPE

  VAR

  (* begin-section-description
## ---------- Boot Via RS232 Serial
  end-section-description *)

  (* begin-procedure-description
---
**RecInt** gets a 32-bit binary value from the serial line.
  end-procedure-description *)
  PROCEDURE RecInt(VAR x: INTEGER);
    VAR z, y, i: INTEGER;
  BEGIN z := 0;  i := 4;
    REPEAT i := i-1;
      REPEAT UNTIL SYSTEM.BIT(rsCtrl, 0);
      SYSTEM.GET(rsData, y); z := ROR(z+y, 8)
    UNTIL i = 0;
    x := z
  END RecInt;

  (* begin-procedure-description
---
**LoadFromLine** Loads the binary image of the inner core of Oberon from the serial line.
  end-procedure-description *)
  PROCEDURE LoadFromLine;
    VAR len, adr, dat: INTEGER;
  BEGIN RecInt(len);
    WHILE len > 0 DO
      RecInt(adr);
      REPEAT RecInt(dat); SYSTEM.PUT(adr, dat); adr := adr + 4; len := len - 4 UNTIL len = 0;
      RecInt(len)
    END
  END LoadFromLine;

  (* begin-section-description
## ---------- Boot Via SPI SD Card
  end-section-description *)

  (* begin-procedure-description
---
**SPIIdle** sends n FFs slowly with no card selected.
  end-procedure-description *)
  PROCEDURE SPIIdle(n: INTEGER); (*send n FFs slowly with no card selected*)
  BEGIN SYSTEM.PUT(spiCtrl, 0);
    WHILE n > 0 DO DEC(n); SYSTEM.PUT(spiData, -1);
      REPEAT UNTIL SYSTEM.BIT(spiCtrl, 0)
    END
  END SPIIdle;

  (* begin-procedure-description
---
**SPI** Delivers a value to SPI data on CARD0 and waits for acceptance.
  end-procedure-description *)
  PROCEDURE SPI(n: INTEGER); (*send&rcv byte slowly with card selected*)
  BEGIN SYSTEM.PUT(spiCtrl, CARD0); SYSTEM.PUT(spiData, n);
    REPEAT UNTIL SYSTEM.BIT(spiCtrl, 0)
  END SPI;

  (* begin-procedure-description
---
**SPICmd** Synchronously ends an SPI command and its argument.
  end-procedure-description *)
  PROCEDURE SPICmd(n, arg: INTEGER);
    VAR i, data, crc: INTEGER;
  BEGIN (*send cmd*)
    REPEAT SPIIdle(1); SYSTEM.GET(spiData, data) UNTIL data = 255; (*flush while unselected*)
    REPEAT SPI(255); SYSTEM.GET(spiData, data) UNTIL data = 255; (*flush while selected*)
    IF n = 8 THEN crc := 135 ELSIF n = 0 THEN crc := 149 ELSE crc := 255 END;
    SPI(n MOD 64 + 64); (*send command*)
    FOR i := 24 TO 0 BY -8 DO SPI(ROR(arg, i)) END; (*send arg*)
    SPI(crc); i := 32;
    REPEAT SPI(255); SYSTEM.GET(spiData, data); DEC(i) UNTIL (data < 80H) OR (i = 0)
  END SPICmd;

  (* begin-procedure-description
---
**InitSPI** Initializes the SPI interface.
  end-procedure-description *)
  PROCEDURE InitSPI;
    VAR res, data: INTEGER;
  BEGIN SPIIdle(9); (*first, idle for at least 80 clks*)
    SPICmd(0, 0); (*CMD0 when card selected, sets MMC SPI mode*)
    SPICmd(8, 1AAH); SPI(-1); SPI(-1); SPI(-1); (*CMD8 for SD cards*)
    REPEAT (*until card becomes ready*)
      (*ACMD41, optionally with high-capacity (HCS) bit set, starts init*)
      SPICmd(55, 0); (*APP cmd follows*)
      SPICmd(41, LSL(1(*HCS*), 30));
      SYSTEM.GET(spiData, res);
      SPI(-1); SPI(-1); SPI(-1); (*flush response*)
      SPIIdle(10) (*was 10000*)
    UNTIL res = 0;
    (*CMD16 set block size as a precaution (should default)*)
    SPICmd(16, 512); SPIIdle(1)
  END InitSPI;

  (* begin-procedure-description
---
**SDShift** Interrogates an SPI storage card.
  end-procedure-description *)
  PROCEDURE SDShift(VAR n: INTEGER);
    VAR data: INTEGER;
  BEGIN SPICmd(58, 0);  (*CMD58 get card capacity bit*)
    SYSTEM.GET(spiData, data); SPI(-1);
    IF (data # 0) OR ~SYSTEM.BIT(spiData, 6) THEN n := n * 512 END ;  (*non-SDHC card*)
    SPI(-1); SPI(-1); SPIIdle(1)  (*flush response*)
  END SDShift;

  (* begin-procedure-description
---
**ReadSD** Retrieves one block from the SD card via SPI.
  end-procedure-description *)
  PROCEDURE ReadSD(src, dst: INTEGER);
    VAR i, data: INTEGER;
  BEGIN SDShift(src); SPICmd(17, src); (*CMD17 read one block*)
    i := 0; (*wait for start data marker*)
    REPEAT SPI(-1); SYSTEM.GET(spiData, data); INC(i) UNTIL data = 254;
    SYSTEM.PUT(spiCtrl, SPIFAST + CARD0);
    FOR i := 0 TO 508 BY 4 DO
      SYSTEM.PUT(spiData, -1);
      REPEAT UNTIL SYSTEM.BIT(spiCtrl, 0);
      SYSTEM.GET(spiData, data); SYSTEM.PUT(dst, data); INC(dst, 4)
    END;
    SPI(255); SPI(255); SPIIdle(1) (*may be a checksum; deselect card*)
  END ReadSD;

  (* begin-procedure-description
---
**LoadFromDisk** Retreives the Innner Core of Oberon from the SD Card.
  end-procedure-description *)
  PROCEDURE LoadFromDisk;
    VAR src, dst, adr, lim: INTEGER;
  BEGIN src := FSoffset + 4;   (*start at boot block*)
    ReadSD(src, 0); SYSTEM.GET(16, lim);
    INC(src); dst := 512;
    WHILE dst < lim DO ReadSD(src, dst); INC(src); INC(dst, 512) END
  END LoadFromDisk;

  (* begin-procedure-description
---
**The initialzation code for this module** sets the stack and Module table origin, 
calls the appropriate Load routine, then places the MemoryLimit, and stackOrg in memory for Oberon to find and jumps to the start of memory.

  end-procedure-description *)
BEGIN SYSTEM.LDREG(SP, stackOrg); SYSTEM.LDREG(MT, MTOrg);
  IF SYSTEM.REG(LNK) = 0 THEN (*cold start*)
    LED(80H); InitSPI;
    IF SYSTEM.BIT(swi, 0) THEN LED(81H); LoadFromLine ELSE LED(82H); LoadFromDisk END ;
  ELSIF SYSTEM.BIT(swi, 0) THEN LED(81H); LoadFromLine
  END ;
  SYSTEM.PUT(12, MemLim); SYSTEM.PUT(24, stackOrg); LED(84H)
END BootLoad.
