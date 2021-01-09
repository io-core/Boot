# SPDX-License-Identifier: GPL-2.0+ OR BSD-2-Clause 

#
# boot-rv64.S - PE/COFF header and bootloader for riscv64 EFI
#
# Copyright (C) 2021 Charles Perkins <charlesap@gmail.com>
# Copyright (C) 2014 Linaro Ltd. <ard.biesheuvel@linaro.org>
#
#
# This file is taken and modified from the gnu-efi project.


# assemble with           riscv64-unknown-elf-as -march=rv64imac shoe-rv64.S -o shoe-rv64.o
# produce empty shoe with riscv64-unknown-elf-objcopy --dump-section PE=shoe-rv64.efi shoe-rv64.o
# tie shoe with           dd if=fixup-rv64.bin of=shoe-rv64.efi bs=1 seek=4352 conv=notrunc
# fill shoe with          dd if=core-rv64.bin of=shoe-rv64.efi bs=1 seek=20480 conv=notrunc

	.section PE
	.globl	ImageBase
HeaderBase:
	.ascii	"MZ"
        .short  0
	.fill	14, 4, 0x00000000
	.long   0x00000080
	.fill	16, 4, 0x00000000
pe_header:
	.ascii	"PE"
	.short 	0
coff_header:
	.short	0x5064			 # rv64
	.short	3			 # nr_sections
	.long	0x5cba52f6 		 # TimeDateStamp
	.quad	0			 # PointerToSymbolTable + NumberOfSymbols
	.short	oend - oheader		 # SizeOfOptionalHeader
	.short	0x206			 # Characteristics.
oheader:
	.short	0x20b			 # PE32+ format
	.byte	0x02			 # MajorLinkerVersion
	.byte	0x14			 # MinorLinkerVersion
	.long	8192			 # SizeOfCode
	.long	270336			 # SizeOfInitializedData
	.long	0			 # SizeOfUninitializedData
	.long	4096			 # AddressOfEntryPoint
	.long	4096			 # BaseOfCode

extra_header_fields:          
	.quad	0x84000000  #0x8000000		 # ImageBase
	.long	4096			 # SectionAlignment
	.long	4096			 # FileAlignment
	.quad	0			 # OS, Image, subsys  Major, Minor
	.quad	0			 # misc

	.long	282624			 # SizeOfImage

 # Everything before the kernel image is considered part of the header
	.long	4096			 # SizeOfHeaders
	.long	0			 # CheckSum
	.long	0x0040000A		 # Subsystem &  DllCharacteristics
	.quad	0x10000			 # SizeOfStackReserve
	.quad	0x10000			 # SizeOfStackCommit
	.quad	0x10000			 # SizeOfHeapReserve
	.quad	0			 # SizeOfHeapCommit
	.long	0			 # LoaderFlags
	.long	0x10			 # NumberOfRvaAndSizes

	.quad	0			 # ExportTable
	.quad	0			 # ImportTable
	.quad	0			 # ResourceTable
	.quad	0			 # ExceptionTable
	.quad	0			 # CertificationTable
	.long	0x84005000   #0x8005000		 # BaseRelocationTable
	.long	0

 # Section table
oend:
	.ascii	".text\0\0\0"
	.long	8192 # _data - _start	 # VirtualSize
	.long	4096 # _start - ImageBase # VirtualAddress
	.long	8192 # _data - _start	 # SizeOfRawData
	.long	4096 # _start - ImageBase # PointerToRawData

	.long	0		
	.long	0		
	.short	0		
	.short	0		
	.long	0x60000020 # Characteristics (section flags)

	.ascii	".data\0\0\0"
	.long	270336 # _data_size	 # VirtualSize
	.long	12288  # _data - ImageBase # VirtualAddress
	.long	270336 # _data_size	 # SizeOfRawData
	.long	12288  # _data - ImageBase # PointerToRawData

	.long	0		
	.long	0		
	.short	0		
	.short	0		
	.long	0xc0000040 # Characteristics (section flags)

        .ascii  ".reloc\0\0\0"
        .long   0       # _data_size            # VirtualSize
        .long   282624  # _data - ImageBase     # VirtualAddress
        .long   0       # _data_size            # SizeOfRawData
        .long   282624  # _data - ImageBase     # PointerToRawData

        .long   0               
        .long   0               
        .short  0               
        .short  0               
        .long   0x02000040      # Characteristics (section flags)
HeaderEnd:
	.fill	4096 - (HeaderEnd - HeaderBase)

CodeStart:

        .equ EFI_SYSTEM_TABLE_CONOUT                      ,64
        .equ EFI_SYSTEM_TABLE_BOOTSERVICES                ,96
        .equ EFI_SIMPLE_TEXT_OUTPUT_PROTOCOL_OUTPUTSTRING ,8
        .equ EFI_BOOT_SERVICES_GETMEMORYMAP               ,56
        .equ EFI_BOOT_SERVICES_EXIT                       ,216
        .equ EFI_BOOT_SERVICES_EXITBOOTSERVICES           ,232

        j        over                    # jump over static local variables

	.short 0
msg:    .short 'o', 'k', '.', '\r', '\n',  0

memmapsize:      .quad 4096             #+16
memmapkey:       .quad 0                #+24
memmapdescsize:  .quad 48               #+32
memmapdescver:   .quad 0                #+40


over:

	mv	x26, x10	# save the handle	
	mv	x24, x15	# save the base of code
	mv	x27, x11        # save the system table


	ld	ra, EFI_SYSTEM_TABLE_CONOUT(x27)	
	ld	ra, 8(ra)
	mv	a1, x24
	add	a1, a1, 4
	jalr	ra, 0

        ld      ra, EFI_SYSTEM_TABLE_BOOTSERVICES(x27)
        ld      ra, EFI_BOOT_SERVICES_GETMEMORYMAP(ra)
        mv      a0, x24
        add     a0, a0, 16     # * memmapsize
        mv      a1, x24
        .equ tmp, 4096
        li      a2, tmp
        add     a1, a1, a2   # * memmap
        mv      a2, x24
        add     a2, a2, 24     # * memmapkey
        mv      a3, x24
        add     a3, a3, 32     # * memmapdescsize
        mv      a4, x24
        add     a4, a4, 48     # * memmapdescver
        jalr    ra, 0

	j	FixAt

EfiEnd:
        .fill   256 - (EfiEnd - CodeStart)
FixAt:

        .equ    uart, 0x100000000 

	addiw           a1,zero,1
	slli            a1,a1,28


        li	a0, 110
        sb	a0, (a1)

        li	a0, 111
        sb	a0, (a1)

        li	a0, 32
        sb	a0, (a1)

        li	a0, 102
        sb	a0, (a1)

        li	a0, 105
        sb	a0, (a1)

        li	a0, 120
        sb	a0, (a1)

        li	a0, 117
        sb	a0, (a1)

        li	a0, 112
        sb	a0, (a1)

        li	a0, 46
        sb	a0, (a1)

        li	a0, 10
        sb	a0, (a1)


#  Bus  0, device   1, function 0:
#    Display controller: PCI device 1234:1111
#      PCI subsystem 1af4:1100
#      BAR0: 32 bit prefetchable memory at 0x40000000 [0x40ffffff].
#      BAR2: 32 bit memory at 0x41000000 [0x41000fff].
#      BAR6: 32 bit memory at 0xffffffffffffffff [0x00007ffe].
#      id ""

# 0x400: 0x00002020 0x00000000 0x00000000 0x00000000
# 0x410: 0xffffffff 0xffffffff 0xffffffff 0xffffffff

# 0x500: 0x0320b0c5 0x00200258 0x00000041 0x147a0320
# 0x510: 0x00000000 0x00000100 0x00000000 0x00000000

	  # bochs_display registers and values
	.equ	VBE_DISPI_INDEX_ID,               0x0
	.equ	VBE_DISPI_INDEX_XRES,             0x1
	.equ	VBE_DISPI_INDEX_YRES,             0x2
	.equ	VBE_DISPI_INDEX_BPP,              0x3
	.equ	VBE_DISPI_INDEX_ENABLE,           0x4
	.equ	VBE_DISPI_INDEX_BANK,             0x5
	.equ	VBE_DISPI_INDEX_VIRT_WIDTH,       0x6
	.equ	VBE_DISPI_INDEX_VIRT_HEIGHT,      0x7
	.equ	VBE_DISPI_INDEX_X_OFFSET,         0x8
	.equ	VBE_DISPI_INDEX_Y_OFFSET,         0x9
	.equ	VBE_DISPI_INDEX_VIDEO_MEMORY_64K, 0xa

	.equ	VBE_DISPI_ENABLED,                0x01
	.equ	VBE_DISPI_GETCAPS,                0x02
	.equ	VBE_DISPI_8BIT_DAC,               0x20
	.equ	VBE_DISPI_LFB_ENABLED,            0x40
	.equ	VBE_DISPI_NOCLEARMEM,             0x80

          # Offsets for accessing ioports via PCI BAR1 (MMIO) 
	.equ	VGA_MMIO_OFFSET, (0x400 - 0x3c0)
	.equ	VBE_MMIO_OFFSET, 0x500

        .equ    uart, 0x100000000

        addiw	a1, zero, 0x41
        slli	a1, a1, 24

	addiw	a0, zero, 0x0   # disable VBE
	sh	a0, 0x506(a1)

        .equ    v1, 0xB0C5
	li	a0, v1
	sh	a0, 0x500(a1)
	addiw	a0, zero, 1600 # 800
	sh	a0, 0x502(a1)
	addiw	a0, zero, 900 # 600
	sh	a0, 0x504(a1)
	addiw	a0, zero, 0x0008   # bpp
	sh	a0, 0x508(a1)
	addiw	a0, zero, 0x0041   # VBE lfb, enabled
	sh	a0, 0x506(a1)


loop:
	j	loop




CodeEnd:
        .fill   8192 - (CodeEnd - CodeStart)

#	.section data
DataStart:


DataEnd:
		.fill 4096 - (DataEnd - DataStart)

memmap:
		.fill 4096 
payload:     # 64 4k pages=262144 (256k)

#mov rcx, [FB]
#mov rax, [FBS]
#Qz:
#dec rax
#mov byte[rcx+rax],0xBB
#jnz Qz
#
#jmp $
#magic          .quad 0x9988776655443322

		.fill 262144 #- 8 - 27  db 0
#datasize equ $ - $$


#	.section reloc


