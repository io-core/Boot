#!/bin/bash

# build.sh uses nasm and the gnu assembler for x86_64 and the objcopy, and ld tools for 
# ARM 64 and 32-bit as well as RISCV. Adjust the paths below to match their locations
# on your system.

NASMTOOLS=/usr/bin/
AA64TOOLS=/home/arm/gcc-arm-9.2-2019.12-x86_64-aarch64-none-linux-gnu/bin/
AA32TOOLS=/home/arm/gcc-arm-none-eabi-9-2019-q4-major/arm-none-eabi/bin/
RISCVTOOLS=/home/riscv/bin/

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





if [ "$tools" == "available" ] ; then

  if [ ! -f ./Core.x64 ] ; then
	echo "need ./Core.x64 to build BOOTX64.EFI. Skipping."
  else
	echo "Building BOOTX64.EFI"
	nasm -f bin x64/boot-x64.S -o BOOTX64.EFI
	dd if=Core.x64 of=BOOTX64.EFI bs=1 seek=20480 conv=notrunc
  fi

  if [ ! -f ./Core.a64 ] ; then
	echo "need ./Core.a64 to build BOOTAA64.EFI. Skipping."
  else
	echo "Building BOOTAA64.EFI"
	${AA64TOOLS}aarch64-none-linux-gnu-as a64/boot-a64.S -o boot-a64.o
	${AA64TOOLS}aarch64-none-linux-gnu-objcopy --dump-section PE=BOOTAA64.EFI boot-a64.o
	dd if=Core.a64 of=BOOTAA64.EFI bs=1 seek=20480 conv=notrunc
	rm boot-a64.o
  fi

  if [ ! -f ./Core.a32 ] ; then
	echo "need ./Core.a32 to build BOOTAA32.BIN. Skipping."
  else
	echo "Building BOOTAA32.BIN"
	${AA32TOOLS}as -mcpu=cortex-a9  a32/boot-a32.S -o boot-a32.o
	${AA32TOOLS}ld -T a32/boot-a32.ld boot-a32.o -o boot-a32.elf
	${AA32TOOLS}objcopy -O binary --only-section=.text boot-a32.elf BOOTAA32.BIN
	dd if=Core.a32 of=BOOTAA32.BIN bs=1 seek=20480 conv=notrunc
	rm boot-a32.o boot-a32.elf
  fi

  if [ ! -f ./Core.r64 ] ; then
	echo "need ./Core.r64 to build BOOTRV64.EFI. Skipping."
  else
	echo "Building BOOTRV64.EFI"
	${RISCVTOOLS}riscv64-unknown-elf-as -march=rv64imac r64/boot-r64.S -o boot-r64.o
	${RISCVTOOLS}riscv64-unknown-elf-objcopy --dump-section PE=BOOTRV64.EFI boot-r64.o
	dd if=Core.r64 of=BOOTRV64.EFI bs=1 seek=20480 conv=notrunc
	rm boot-rv64.o
  fi

  if [ ! -f ./Core.r32 ] ; then
	echo "need ./Core.r32 to build BOOTRV32.BIN. Skipping."
  else
	echo "Building BOOTRV32.BIN"
	${RISCVTOOLS}riscv64-unknown-elf-as r32/boot-r32.S -o boot-r32.o
	${RISCVTOOLS}riscv64-unknown-elf-ld boot-r32.o -o boot-r32.elf
	${RISCVTOOLS}riscv64-unknown-elf-objcopy -O binary --only-section=.text boot-r32.elf BOOTRV32.BIN
	dd if=Core.r32 of=BOOTRV32.BIN bs=1 seek=20480 conv=notrunc
	rm boot-r32.o boot-r32.elf
  fi
fi
