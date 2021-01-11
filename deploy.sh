#!/bin/bash

if [ ! -f /stick/EFI/BOOT/BOOTX64.EFI ] ; then
	echo "target disk expected to be mounted on /stick mount point"
else
	sudo cp bin/BOOTX64.EFI /stick/EFI/BOOT/BOOTX64.EFI
	sudo cp bin/BOOTAA64.EFI /stick/EFI/BOOT/qemu-arm-armv8.efi  
	sudo cp bin/BOOTRV64.EFI /stick/EFI/BOOT/qemu-riscv-generic.efi
	sync
fi
