#!/bin/bash

/opt/qemu-risc6/x86_64-softmmu/qemu-system-x86_64 -name guest=x64 -machine pc,accel=kvm,usb=off,dump-guest-core=off -smp 2,sockets=2,cores=1,threads=1 -uuid 515645b7-ab3a-4e82-ba62-25751e4b523f -bios bin/OVMF.fd -m 1G -display gtk -drive file=/home/images/gigdisk.img -monitor stdio 

/home/qemu-2021/build/qemu-system-aarch64 -m 1024 -cpu cortex-a57 -M virt -name guest=aa64 -bios bin/arm64-u-boot.bin -smp 2,sockets=1,threads=1 -uuid 515645b7-ab3a-4e82-ba62-25751e4b523f -m 1G -device bochs-display -display gtk -monitor stdio -drive file=/home/images/gigdisk.img

/home/qemu-2021/build/qemu-system-arm -m 1024 -M virt -name guest=aa32 -kernel bin/Core.a32 -smp 2,sockets=1,threads=1 -uuid 515645b7-ab3a-4e82-ba62-25751e4b523f -m 1G -device bochs-display -display gtk -monitor stdio -drive file=/home/images/gigdisk.img

/home/qemu-2021/build/qemu-system-riscv64 -name guest=rv64 -machine virt -smp 2 -m 1G -kernel bin/rv64-u-boot.elf -bios none -device virtio-blk-device,drive=hd0 -drive file=/home/images/gigdisk.img,format=raw,id=hd0  -device bochs-display -display gtk -monitor stdio

#/opt/qemu-risc6/riscv64-softmmu/qemu-system-riscv64 -name guest=rv64 -machine virt -smp 2 -m 1G -kernel bin/rv64-u-boot.elf -bios none -device virtio-blk-device,drive=hd0 -drive file=/home/images/gigdisk.img,format=raw,id=hd0  -device bochs-display -display gtk -monitor stdio

/home/qemu-2021/build/qemu-system-riscv32 -name guest=rv32 -M virt  -bios bin/rv32fw_jump.elf -kernel bin/Core.v32 -append "root=/dev/vda ro" -netdev user,id=net0 -device virtio-net-device,netdev=net0 -device bochs-display -display gtk -monitor stdio -device virtio-blk-device,drive=hd0 -drive file=/home/images/gigdisk.img,format=raw,id=hd0

/opt/qemu-risc6/risc6-softmmu/qemu-system-risc6 -name guest=risc5 -machine fpga-risc -display gtk -g 1400x968x8 -monitor stdio -device loader,file=/opt/qemu-risc6/hw/risc6/flex-boot.asm.bin,addr=0xfffff800 -drive format=raw,file=/opt/oberon/io/images/io.img -smp 1 -m 1M

