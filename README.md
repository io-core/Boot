# Bootloaders
Boot methods for loading Oberon on various architectures.

Each architecture and system board or emulator needs a tailored boot process.

Some platforms have a common boot infrastructure that reduces the work to boot the operating system. UEFI and U-Boot are two examples.

This repository containes UEFI bootloaders for x86_64, aarch64, and riscv64 Oberon using a PE+/COFF header.

This repository also contains bootloaders for 32-bit Arm and riscv32 Oberon using the ELF header that may be used with U-BOOT or QEMU or loaded directly into system flash.

This repository also contains a RISC5 bootloader that may be used with FPGA or software emulator of the Oberon RISC machine.
