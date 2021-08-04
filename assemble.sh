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

  if [ ! -f bin/Core.x8664.qemu ] ; then
	echo "need bin/Core.x8664.qemu to build BOOTX64.EFI. Skipping."
  else
	echo "Building BOOTX64.EFI"
	nasm -f bin x8664/boot-x8664.S -o bin/BOOTX64.EFI
	dd if=bin/Core.x8664.qemu of=bin/BOOTX64.EFI bs=1 seek=20480 conv=notrunc
  fi

  if [ ! -f bin/Core.x8664.lin ] ; then
	echo "need bin/Core.x8664.lin to build io-core-x8664-linux Skipping."
  else
	echo "Building boot-x8664-lin.elf"
#	objcopy -I binary -O elf64-little --change-section-address .data=0x00 bin/Core.x8664.lin bin/boot-8664-lin.elf
	objcopy --input binary --output elf64-x86-64 --binary-architecture i386:x86-64  bin/Core.x8664.lin boot-x8664-lin.o
	ld   -nostdlib -T x8664/boot-x8664-lin.ld  boot-x8664-lin.o -o boot-x8664-lin.elf
#	echo "Building io-core-i64-linux"
#	echo "#!/usr/bin/env oberon" > bin/io-core-i64-linux
#	echo  >> bin/io-core-i64-linux
#	cat bin/Core.x8664.lin >> bin/io-core-i64-linux
#	chmod +x bin/io-core-i64-linux
  fi

  if [ ! -f bin/Core.arm64.qemu ] ; then
	echo "need bin/Core.arm64.qemu to build BOOTAA64.EFI. Skipping."
  else
	echo "Building BOOTAA64.EFI"
	${AA64TOOLS}aarch64-none-linux-gnu-as arm64/boot-arm64-qemu.S -o boot-arm64-qemu.o
	${AA64TOOLS}aarch64-none-linux-gnu-objcopy --dump-section PE=bin/BOOTAA64.EFI boot-arm64-qemu.o
	dd if=bin/Core.arm64.qemu of=bin/BOOTAA64.EFI bs=1 seek=20480 conv=notrunc
	#rm boot-arm64-qemu.o
  fi

  if [ ! -f bin/Core.arm64.pbpro ] ; then
	echo "need bin/Core.arm64.pbpro to build BOOTAA64PBP.EFI. Skipping."
  else
	echo "Core.arm64.pbpro may be loaded by a u-boot script"
#	${AA64TOOLS}aarch64-none-linux-gnu-as a64/boot-a64-pbpro.S -o boot-a64-pbpro.o
#	${AA64TOOLS}aarch64-none-linux-gnu-objcopy --dump-section PE=bin/BOOTAA64PBP.EFI boot-a64-pbpro.o
#	dd if=bin/Core.a64.pbpro of=bin/BOOTAA64PBP.EFI bs=1 seek=20480 conv=notrunc
	#rm boot-a64-pbpro.o
  fi

  if [ ! -f bin/Core.arm64.pphone ] ; then
	echo "need bin/Core.a64.pphone to build BOOTAA64PPH.EFI. Skipping."
  else
	echo "Core.arm64.pphone may be loaded by a u-boot script"
#	${AA64TOOLS}aarch64-none-linux-gnu-as a64/boot-a64-pphone.S -o boot-a64-pphone.o
#	${AA64TOOLS}aarch64-none-linux-gnu-objcopy --dump-section PE=bin/BOOTAA64PPH.EFI boot-a64-pphone.o
#	dd if=bin/Core.a64.pphone of=bin/BOOTAA64PPH.EFI bs=1 seek=20480 conv=notrunc
	#rm boot-a64-pphone.o
  fi

  if [ ! -f bin/Core.arm32.qemu ] ; then
	echo "need bin/Core.arm32.qemu to build BOOTAA32.BIN. Skipping."
  else
	echo "Building BOOTAA32.BIN"
	${AA32TOOLS}as -mcpu=cortex-a9  arm32/boot-arm32-qemu.S -o boot-arm32-qemu.o
	${AA32TOOLS}ld -T arm32/boot-arm32-qemu.ld boot-arm32-qemu.o -o boot-arm32-qemu.elf
	${AA32TOOLS}objcopy -O binary --only-section=.text boot-arm32-qemu.elf bin/BOOTAA32.BIN
	dd if=bin/Core.arm32.qemu of=bin/BOOTAA32.BIN bs=1 seek=20480 conv=notrunc
	#rm boot-arm32.o boot-a3rm2.elf
  fi

  if [ ! -f bin/Core.cortex4.qemu ] ; then
	echo "need bin/Core.cortex4.qemu to build BOOTCM4.BIN. Skipping."
  else
	echo "Building BOOTCM4.BIN"
	${AA32TOOLS}as -mcpu=cortex-m4  cortex4/boot-cortex4-qemu.S -o boot-cortex4-qemu.o
	${AA32TOOLS}ld -T cortex4/boot-cortex4-qemu.ld boot-cortex4-qemu.o -o boot-cortex4-qemu.elf
	${AA32TOOLS}objcopy -O binary --only-section=.text boot-cortex4-qemu.elf bin/BOOTCM4.BIN
	dd if=bin/Core.cortex4.qemu of=bin/BOOTCM4.BIN bs=1 seek=20480 conv=notrunc
	#rm boot-cm4-qemu.o boot-cm4-qemu.elf
  fi

  if [ ! -f bin/Core.cortex0.qemu ] ; then
	echo "need bin/Core.cortex0.qemu to build BOOTCM0.BIN. Skipping."
  else
	echo "Building BOOTCM0.BIN"
	${AA32TOOLS}as -mcpu=cortex-m0  cortex0/boot-cortex0-qemu.S -o boot-cortex0-qemu.o
	${AA32TOOLS}ld -T cortex0/boot-cortex0-qemu.ld boot-cortex0-qemu.o -o boot-cortex0-qemu.elf
	${AA32TOOLS}objcopy -O binary --only-section=.text boot-cortex0-qemu.elf bin/BOOTCM0.BIN
	dd if=bin/Core.cortex0.qemu of=bin/BOOTCM0.BIN bs=1 seek=20480 conv=notrunc
	#rm boot-cm0-qemu.o boot-cm0-qemu.elf
  fi
  
  if [ ! -f bin/Core.cortex4.ptime ] ; then
	echo "need bin/Core.cortex4.ptime to build BOOTPTIME.BIN. Skipping."
  else
	echo "Building BOOTPTIME.BIN"
	${AA32TOOLS}as -mcpu=cortex-m4  cortex4/boot-cortex4-ptime.S -o boot-cortex4-ptime.o
	${AA32TOOLS}ld -T cortex4/boot-cortex4-ptime.ld boot-cortex4-ptime.o -o boot-cortex4-ptime.elf
	${AA32TOOLS}objcopy -O binary --only-section=.text boot-cortex4-ptime.elf bin/BOOTPTIME.BIN
	dd if=bin/Core.cortex4.ptime of=bin/BOOTPTIME.BIN bs=1 seek=20480 conv=notrunc
	#rm boot-cm4-ptime.o boot-cm4-ptime.elf
  fi

  if [ ! -f bin/Core.cortex0.pico ] ; then
	echo "need bin/Core.cortex0.pico to build bootpico.uf2. Skipping."
  else
	echo "Building bootpico.uf2"
	${AA32TOOLS}as -mcpu=cortex-m0  cortex0/boot-cortex0-pico.S -o boot-cortex0-pico.o
	${AA32TOOLS}ld -T cortex0/boot-cortex0-pico.ld boot-cortex0-pico.o -o boot-cortex0-pico.elf
	${AA32TOOLS}objcopy -O binary --only-section=.text boot-cortex0-pico.elf bin/bootpico.uf2
	dd if=bin/Core.cortex0.pico of=bin/bootpico.uf2 bs=1 seek=20480 conv=notrunc
	#rm boot-cm0-pico.o boot-cm0-pico.elf
  fi

  if [ ! -f bin/Core.riscv64.qemu ] ; then
	echo "need bin/Core.riscv64.qemu to build BOOTRV64.EFI. Skipping."
  else
	echo "Building BOOTRV64.EFI"
	${RISCVTOOLS}riscv64-unknown-elf-as -march=rv64imac riscv64/boot-riscv64-qemu.S -o boot-riscv64-qemu.o
	${RISCVTOOLS}riscv64-unknown-elf-objcopy --dump-section PE=bin/BOOTRV64.EFI boot-riscv64-qemu.o
	dd if=bin/Core.riscv64.qemu of=bin/BOOTRV64.EFI bs=1 seek=20480 conv=notrunc
	rm boot-riscv64-qemu.o
  fi

  if [ ! -f bin/Core.riscv32.qemu ] ; then
	echo "need bin/Core.riscv32.qemu to build BOOTRV32.BIN. Skipping."
  else
	echo "Building BOOTRV32.BIN"
	${RISCVTOOLS}riscv64-unknown-elf-as riscv32/boot-riscv32-qemu.S -o boot-riscv32-qemu.o
	${RISCVTOOLS}riscv64-unknown-elf-ld boot-riscv32-qemu.o -o boot-riscv32-qemu.elf
	${RISCVTOOLS}riscv64-unknown-elf-objcopy -O binary --only-section=.text boot-riscv32-qemu.elf bin/BOOTRV32.BIN
	dd if=bin/Core.riscv32.qemu of=bin/BOOTRV32.BIN bs=1 seek=20480 conv=notrunc
	rm boot-riscv32-qemu.o boot-riscv32-qemu.elf
  fi

fi
