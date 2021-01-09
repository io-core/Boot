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

	echo "Building BOOTX64.EFI"
	nasm -f bin x64/boot-x64.S -o BOOTX64.EFI
	dd if=Core.x64 of=BOOTX64.EFI bs=1 seek=20480 conv=notrunc

	echo "Building BOOTAA64.EFI"
	${AA64TOOLS}aarch64-none-linux-gnu-as aa64/boot-aa64.S -o boot-aa64.o
	${AA64TOOLS}aarch64-none-linux-gnu-objcopy --dump-section PE=BOOTAA64.EFI boot-aa64.o
	dd if=Core.a64 of=BOOTAA64.EFI bs=1 seek=20480 conv=notrunc
	rm boot-aa64.o

	echo "Building BOOTAA32.BIN"
	${AA32TOOLS}as -mcpu=cortex-a9  aa32/boot-aa32.S -o boot-aa32.o
	${AA32TOOLS}ld -T aa32/boot-aa32.ld boot-aa32.o -o boot-aa32.elf
	${AA32TOOLS}objcopy -O binary --only-section=.text aa32test.elf BOOTAA32.BIN
	dd if=Core.a32 of=BOOTAA32.BIN bs=1 seek=20480 conv=notrunc
	rm boot-aa32.o boot-aa32.elf

	echo "Building BOOTRV64.EFI"
	${RISCVTOOLS}riscv64-unknown-elf-as -march=rv64imac rv64/boot-rv64.S -o boot-rv64.o
	${RISCVTOOLS}riscv64-unknown-elf-objcopy --dump-section PE=BOOTRV64.EFI boot-rv64.o
	dd if=Core.r64 of=BOOTRV64.EFI bs=1 seek=20480 conv=notrunc
	rm boot-rv64.o

	echo "Building BOOTRV32.BIN"
	${RISCVTOOLS}riscv64-unknown-elf-as rv32/boot-rv32.S -o boot-rv32.o
	${RISCVTOOLS}riscv64-unknown-elf-ld boot-rv32.o -o boot-rv32.elf
	${RISCVTOOLS}riscv64-unknown-elf-objcopy -O binary --only-section=.text boot-rv32.elf BOOTRV32.BIN
	dd if=Core.r32 of=BOOTRV32.BIN bs=1 seek=20480 conv=notrunc
	rm boot-rv32.o boot-rv32.elf

fi
