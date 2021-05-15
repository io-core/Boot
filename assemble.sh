#!/bin/bash

# build.sh uses nasm and the gnu assembler for x86_64 and the objcopy, and ld tools for 
# ARM 64 and 32-bit as well as RISCV. Adjust the paths below to match their locations
# on your system.

NASMTOOLS=/usr/bin/
AA64TOOLS=/home/arm/gcc-arm-9.2-2019.12-x86_64-aarch64-none-linux-gnu/bin/
AA32TOOLS=/home/arm/gcc-arm-none-eabi-9-2019-q4-major/arm-none-eabi/bin/
RISCVTOOLS=/home/riscv/bin/
WABTTOOLS=/opt/wabt/build/

tools="available"

if [ ! -f ${NASMTOOLS}nasm ] ; then
	echo "nasm is required and NASMTOOLS must be set correctly"
	tools="unavailable"
fi

if [ ! -f ${AA64TOOLS}aarch64-none-linux-gnu-as ] ; then
	echo "gnu assembler for aa64 is required and AA64TOOLS must be set correctly"
	tools="unavailable"
fi

if [ ! -f ${AA32TOOLS}as ] ; then
	echo "gnu assembler for arm is required and AA32TOOLS must be set correctly"
	tools="unavailable"
fi

if [ ! -f ${RISCVTOOLS}riscv64-unknown-elf-as ] ; then
	echo "gnu assembler for riscv is required and RISCVTOOLS must be set correctly"
	tools="unavailable"
fi

if [ ! -f ${WABTTOOLS}wasm2wat ] ; then
	echo "web assembly is required and WABTTOOLS must be set correctly"
	tools="unavailable"
fi

if [ ! `command -v oberon` ] ; then
	echo "oberon command not found, you might want to install it in your system to enable userspace Oberon"
fi



if [ "$tools" == "available" ] ; then

  if [ ! -f bin/Core.i64.qemu ] ; then
	echo "need bin/Core.i64.qemu to build BOOTX64.EFI. Skipping."
  else
	echo "Building BOOTX64.EFI"
	nasm -f bin i64/boot-i64.S -o bin/BOOTX64.EFI
	dd if=bin/Core.i64.qemu of=bin/BOOTX64.EFI bs=1 seek=20480 conv=notrunc
  fi

  if [ ! -f bin/Core.i64.lin ] ; then
	echo "need bin/Core.i64.lin to build io-core-i64-linux Skipping."
  else
	echo "Building boot-i64-lin.elf"
#	objcopy -I binary -O elf64-little --change-section-address .data=0x00 bin/Core.i64.lin bin/boot-i64-lin.elf
	objcopy --input binary --output elf64-x86-64 --binary-architecture i386:x86-64  bin/Core.i64.lin boot-i64-lin.o
	ld   -nostdlib -T i64/boot-i64-lin.ld  boot-i64-lin.o -o boot-i64-lin.elf
#	echo "Building io-core-i64-linux"
#	echo "#!/usr/bin/env oberon" > bin/io-core-i64-linux
#	echo  >> bin/io-core-i64-linux
#	cat bin/Core.i64.lin >> bin/io-core-i64-linux
#	chmod +x bin/io-core-i64-linux
  fi

  if [ ! -f bin/Core.a64.qemu ] ; then
	echo "need bin/Core.a64.qemu to build BOOTAA64.EFI. Skipping."
  else
	echo "Building BOOTAA64.EFI"
	${AA64TOOLS}aarch64-none-linux-gnu-as a64/boot-a64-qemu.S -o boot-a64-qemu.o
	${AA64TOOLS}aarch64-none-linux-gnu-objcopy --dump-section PE=bin/BOOTAA64.EFI boot-a64-qemu.o
	dd if=bin/Core.a64.qemu of=bin/BOOTAA64.EFI bs=1 seek=20480 conv=notrunc
	#rm boot-a64-qemu.o
  fi

  if [ ! -f bin/Core.a64.pbpro ] ; then
	echo "need bin/Core.a64.pbpro to build BOOTAA64PBP.EFI. Skipping."
  else
	echo "Building BOOTAA64PBP.EFI"
	${AA64TOOLS}aarch64-none-linux-gnu-as a64/boot-a64-pbpro.S -o boot-a64-pbpro.o
	${AA64TOOLS}aarch64-none-linux-gnu-objcopy --dump-section PE=bin/BOOTAA64PBP.EFI boot-a64-pbpro.o
	dd if=bin/Core.a64.pbpro of=bin/BOOTAA64PBP.EFI bs=1 seek=20480 conv=notrunc
	#rm boot-a64-pbpro.o
  fi

  if [ ! -f bin/Core.a64.pphone ] ; then
	echo "need bin/Core.a64.pphone to build BOOTAA64PPH.EFI. Skipping."
  else
	echo "Building BOOTAA64PPH.EFI"
	${AA64TOOLS}aarch64-none-linux-gnu-as a64/boot-a64-pphone.S -o boot-a64-pphone.o
	${AA64TOOLS}aarch64-none-linux-gnu-objcopy --dump-section PE=bin/BOOTAA64PPH.EFI boot-a64-pphone.o
	dd if=bin/Core.a64.pphone of=bin/BOOTAA64PPH.EFI bs=1 seek=20480 conv=notrunc
	#rm boot-a64-pphone.o
  fi

  if [ ! -f bin/Core.a32.qemu ] ; then
	echo "need bin/Core.a32.qemu to build BOOTAA32.BIN. Skipping."
  else
	echo "Building BOOTAA32.BIN"
	${AA32TOOLS}as -mcpu=cortex-a9  a32/boot-a32-qemu.S -o boot-a32-qemu.o
	${AA32TOOLS}ld -T a32/boot-a32-qemu.ld boot-a32-qemu.o -o boot-a32-qemu.elf
	${AA32TOOLS}objcopy -O binary --only-section=.text boot-a32-qemu.elf bin/BOOTAA32.BIN
	dd if=bin/Core.a32.qemu of=bin/BOOTAA32.BIN bs=1 seek=20480 conv=notrunc
	#rm boot-a32.o boot-a32.elf
  fi

  if [ ! -f bin/Core.cm4.qemu ] ; then
	echo "need bin/Core.cm4.qemu to build BOOTCM4.BIN. Skipping."
  else
	echo "Building BOOTCM4.BIN"
	${AA32TOOLS}as -mcpu=cortex-m4  cm4/boot-cm4-qemu.S -o boot-cm4-qemu.o
	${AA32TOOLS}ld -T cm4/boot-cm4-qemu.ld boot-cm4-qemu.o -o boot-cm4-qemu.elf
	${AA32TOOLS}objcopy -O binary --only-section=.text boot-cm4-qemu.elf bin/BOOTCM4.BIN
	dd if=bin/Core.cm4.qemu of=bin/BOOTCM4.BIN bs=1 seek=20480 conv=notrunc
	#rm boot-cm4-qemu.o boot-cm4-qemu.elf
  fi

  if [ ! -f bin/Core.cm0.qemu ] ; then
	echo "need bin/Core.cm0.qemu to build BOOTCM0.BIN. Skipping."
  else
	echo "Building BOOTCM0.BIN"
	${AA32TOOLS}as -mcpu=cortex-m0  cm0/boot-cm0-qemu.S -o boot-cm0-qemu.o
	${AA32TOOLS}ld -T cm0/boot-cm0-qemu.ld boot-cm0-qemu.o -o boot-cm0-qemu.elf
	${AA32TOOLS}objcopy -O binary --only-section=.text boot-cm0-qemu.elf bin/BOOTCM0.BIN
	dd if=bin/Core.cm0.qemu of=bin/BOOTCM0.BIN bs=1 seek=20480 conv=notrunc
	#rm boot-cm0-qemu.o boot-cm0-qemu.elf
  fi
  
  if [ ! -f bin/Core.cm4.ptime ] ; then
	echo "need bin/Core.cm4.ptime to build BOOTPTIME.BIN. Skipping."
  else
	echo "Building BOOTPTIME.BIN"
	${AA32TOOLS}as -mcpu=cortex-m4  cm4/boot-cm4-ptime.S -o boot-cm4-ptime.o
	${AA32TOOLS}ld -T cm4/boot-cm4-ptime.ld boot-cm4-ptime.o -o boot-cm4-ptime.elf
	${AA32TOOLS}objcopy -O binary --only-section=.text boot-cm4-ptime.elf bin/BOOTPTIME.BIN
	dd if=bin/Core.cm4.ptime of=bin/BOOTPTIME.BIN bs=1 seek=20480 conv=notrunc
	#rm boot-cm4-ptime.o boot-cm4-ptime.elf
  fi

  if [ ! -f bin/Core.cm0.pico ] ; then
	echo "need bin/Core.cm0.pico to build bootpico.uf2. Skipping."
  else
	echo "Building bootpico.uf2"
	${AA32TOOLS}as -mcpu=cortex-m0  cm0/boot-cm0-pico.S -o boot-cm0-pico.o
	${AA32TOOLS}ld -T cm0/boot-cm0-pico.ld boot-cm0-pico.o -o boot-cm0-pico.elf
	${AA32TOOLS}objcopy -O binary --only-section=.text boot-cm0-pico.elf bin/bootpico.uf2
	dd if=bin/Core.cm0.pico of=bin/bootpico.uf2 bs=1 seek=20480 conv=notrunc
	#rm boot-cm0-pico.o boot-cm0-pico.elf
  fi

  if [ ! -f bin/Core.v64.qemu ] ; then
	echo "need bin/Core.v64.qemu to build BOOTRV64.EFI. Skipping."
  else
	echo "Building BOOTRV64.EFI"
	${RISCVTOOLS}riscv64-unknown-elf-as -march=rv64imac v64/boot-v64-qemu.S -o boot-v64-qemu.o
	${RISCVTOOLS}riscv64-unknown-elf-objcopy --dump-section PE=bin/BOOTRV64.EFI boot-v64-qemu.o
	dd if=bin/Core.v64.qemu of=bin/BOOTRV64.EFI bs=1 seek=20480 conv=notrunc
	rm boot-v64-qemu.o
  fi

  if [ ! -f bin/Core.v32.qemu ] ; then
	echo "need bin/Core.v32.qemu to build BOOTRV32.BIN. Skipping."
  else
	echo "Building BOOTRV32.BIN"
	${RISCVTOOLS}riscv64-unknown-elf-as v32/boot-v32-qemu.S -o boot-v32-qemu.o
	${RISCVTOOLS}riscv64-unknown-elf-ld boot-v32-qemu.o -o boot-v32-qemu.elf
	${RISCVTOOLS}riscv64-unknown-elf-objcopy -O binary --only-section=.text boot-v32-qemu.elf bin/BOOTRV32.BIN
	dd if=bin/Core.v32.qemu of=bin/BOOTRV32.BIN bs=1 seek=20480 conv=notrunc
	rm boot-v32-qemu.o boot-v32-qemu.elf
  fi

  if [ ! -f bin/Core.w64.wasmer ] ; then
	echo "need bin/Core.w64.wasmer to build boot-w64-wasmer.wasm. Skipping."
  else
	echo "Building boot-w64-wasmer.wasm"
	${WABTTOOLS}wasm2wat w64/boot-w64-wasmer.wat -o bin/boot-w64-wasmer.wasm
#	${RISCVTOOLS}riscv64-unknown-elf-ld boot-v32-qemu.o -o boot-v32-qemu.elf
#	${RISCVTOOLS}riscv64-unknown-elf-objcopy -O binary --only-section=.text boot-v32-qemu.elf bin/BOOTRV32.BIN
#	dd if=bin/Core.v32.qemu of=bin/BOOTRV32.BIN bs=1 seek=20480 conv=notrunc
#	rm boot-v32-qemu.o boot-v32-qemu.elf
  fi
fi
