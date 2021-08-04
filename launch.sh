#!/bin/bash

what=$1

if [ "$what" == "" ]; then
	what="all"
fi

# qemu x86_64
if [ "$what" == "x64" ] || [ "$what" == "all" ] ; then
/opt/qemu-risc6/x86_64-softmmu/qemu-system-x86_64 -name guest=x64 -machine pc,accel=kvm,usb=off,dump-guest-core=off -smp 2,sockets=2,cores=1,threads=1 -uuid 515645b7-ab3a-4e82-ba62-25751e4b523f -bios bin/OVMF.fd -m 1G -display gtk -drive file=/home/images/gigdisk.img -monitor stdio
fi

# qemu aarch64
if [ "$what" == "a64" ] || [ "$what" == "all" ] ; then
/home/qemu-2021/build/qemu-system-aarch64 -m 1024 -cpu cortex-a57 -M virt -name guest=aa64 -bios bin/arm64-u-boot.bin -smp 2,sockets=1,threads=1 -uuid 515645b7-ab3a-4e82-ba62-25751e4b523f -m 1G -device bochs-display -display gtk -monitor stdio -drive file=/home/images/gigdisk.img
fi

# qemu arm32
if [ "$what" == "a32" ] || [ "$what" == "all" ] ; then
/home/qemu-2021/build/qemu-system-arm -m 1024 -M virt -name guest=aa32 -kernel bin/Core.arm32.qemu -smp 2,sockets=1,threads=1 -uuid 515645b7-ab3a-4e82-ba62-25751e4b523f -m 1G -device bochs-display -display gtk -monitor stdio -drive file=/home/images/gigdisk.img
fi

# qemu cortex-m4
if [ "$what" == "m4" ] || [ "$what" == "all" ] ; then
/home/qemu-2021/build/qemu-system-arm -m 1024 -cpu cortex-m4 -M nuri -name guest=cm4 -kernel bin/Core.cortex4.qemu -smp 2,sockets=1,threads=1 -uuid 515645b7-ab3a-4e82-ba62-25751e4b523f -m 1G -display gtk -monitor stdio -drive file=/home/images/gigdisk.img
fi

# qemu cortex-m0
if [ "$what" == "m0" ] || [ "$what" == "all" ] ; then
/home/qemu-2021/build/qemu-system-arm -m 1024 -cpu cortex-m0 -M nuri -name guest=cm0 -kernel bin/Core.cortex0.qemu -smp 2,sockets=1,threads=1 -uuid 515645b7-ab3a-4e82-ba62-25751e4b523f -m 1G -display gtk -monitor stdio -drive file=/home/images/gigdisk.img
fi

# cortex-m0+ for pi pico:
#/home/qemu-2021/build/qemu-system-arm -cpu cortex-m0 -M foo
#qemu-system-arm -M nuri -kernel output/images/zImage -append "console=ttySAC1,115200" -smp 2 -serial null -serial stdio

# qemu rv64
if [ "$what" == "v64" ] || [ "$what" == "all" ] ; then
/home/qemu-2021/build/qemu-system-riscv64 -name guest=rv64 -machine virt -smp 2 -m 1G -kernel bin/rv64-u-boot.elf -bios none -device virtio-blk-device,drive=hd0 -drive file=/home/images/gigdisk.img,format=raw,id=hd0  -device bochs-display -display gtk -monitor stdio
fi

#/opt/qemu-risc6/riscv64-softmmu/qemu-system-riscv64 -name guest=rv64 -machine virt -smp 2 -m 1G -kernel bin/rv64-u-boot.elf -bios none -device virtio-blk-device,drive=hd0 -drive file=/home/images/gigdisk.img,format=raw,id=hd0  -device bochs-display -display gtk -monitor stdio

# qemu rv32
if [ "$what" == "v32" ] || [ "$what" == "all" ] ; then
/home/qemu-2021/build/qemu-system-riscv32 -name guest=rv32 -M virt  -bios bin/rv32fw_jump.elf -kernel bin/Core.riscv32.qemu -append "root=/dev/vda ro" -netdev user,id=net0 -device virtio-net-device,netdev=net0 -device bochs-display -display gtk -monitor stdio -device virtio-blk-device,drive=hd0 -drive file=/home/images/gigdisk.img,format=raw,id=hd0
fi

# qemu risc6
if [ "$what" == "rsc" ] || [ "$what" == "all" ] ; then
/opt/qemu-risc6/risc6-softmmu/qemu-system-risc6 -name guest=risc5 -machine fpga-risc -display gtk -g 1400x968x8 -monitor stdio -device loader,file=/opt/qemu-risc6/hw/risc6/flex-boot.asm.bin,addr=0xfffff800 -drive format=raw,file=/opt/oberon/io/images/io.img -smp 1 -m 1M
fi
