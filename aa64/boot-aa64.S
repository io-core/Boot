/* SPDX-License-Identifier: GPL-2.0+ OR BSD-2-Clause */

/*
 * boot-aa64.S - PE/COFF header and bootloader for aarch64 EFI
 *
 * Copyright (C) 2021 Charles Perkins <charlesap@gmail.com>
 * Copyright (C) 2014 Linaro Ltd. <ard.biesheuvel@linaro.org>
 *
 *
 * This file is taken and modified from the gnu-efi project.
 */

// assemble with           aarch64-none-linux-gnu-as shoe-aa64.S -o shoe-aa64.o
// produce empty shoe with aarch64-none-linux-gnu-objcopy --dump-section PE=shoe-aa64.efi shoe-aa64.o
// tie shoe with           dd if=fixup-aa64.bin of=shoe-aa64.efi bs=1 seek=4352 conv=notrunc
// fill shoe with          dd if=core-aa64.bin of=shoe-aa64.efi bs=1 seek=20480 conv=notrunc

	.section PE

	.globl _start
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
	.short	0xaa64				// AArch64
	.short	3				// nr_sections
	.long	0x5cba52f6 			// TimeDateStamp
	.quad	0				// PointerToSymbolTable + NumberOfSymbols
	.short	oend - oheader			// SizeOfOptionalHeader
	.short	0x202e				// Characteristics.
						// IMAGE_FILE_DEBUG_STRIPPED |
						// IMAGE_FILE_EXECUTABLE_IMAGE |
						// IMAGE_FILE_LINE_NUMS_STRIPPED
oheader:
	.short	0x20b				// PE32+ format
	.byte	0x02				// MajorLinkerVersion
	.byte	0x14				// MinorLinkerVersion
	.long	8192				// SizeOfCode
	.long	270336				// SizeOfInitializedData
	.long	0				// SizeOfUninitializedData
	.long	4096				// AddressOfEntryPoint
	.long	4096				// BaseOfCode

extra_header_fields:
	.quad	0x8000000			// ImageBase
	.long	4096				// SectionAlignment
	.long	4096				// FileAlignment
	.quad	0				// OS, Image, subsys  Major, Minor
	.quad	0				// misc

	.long	282624				// SizeOfImage

	// Everything before the kernel image is considered part of the header
	.long	4096				// SizeOfHeaders
	.long	0				// CheckSum
	.long	0x0040000A			// Subsystem &  DllCharacteristics
	.quad	0x10000				// SizeOfStackReserve
	.quad	0x10000				// SizeOfStackCommit
	.quad	0x10000				// SizeOfHeapReserve
	.quad	0				// SizeOfHeapCommit
	.long	0				// LoaderFlags
	.long	0x10				// NumberOfRvaAndSizes

	.quad	0				// ExportTable
	.quad	0				// ImportTable
	.quad	0				// ResourceTable
	.quad	0				// ExceptionTable
	.quad	0				// CertificationTable
	.long	0x8005000			// BaseRelocationTable
	.long	0

	// Section table
oend:
	.ascii	".text\0\0\0"
	.long	8192 // _data - _start		// VirtualSize
	.long	4096 // _start - ImageBase	// VirtualAddress
	.long	8192 // _data - _start		// SizeOfRawData
	.long	4096 // _start - ImageBase	// PointerToRawData

	.long	0		
	.long	0		
	.short	0		
	.short	0		
	.long	0x60000020	// Characteristics (section flags)

	.ascii	".data\0\0\0"
	.long	270336 // _data_size		// VirtualSize
	.long	12288  // _data - ImageBase	// VirtualAddress
	.long	270336 // _data_size		// SizeOfRawData
	.long	12288  // _data - ImageBase	// PointerToRawData

	.long	0		
	.long	0		
	.short	0		
	.short	0		
	.long	0xc0000040	// Characteristics (section flags)

        .ascii  ".reloc\0\0\0"
        .long   0       // _data_size            // VirtualSize
        .long   282624  // _data - ImageBase     // VirtualAddress
        .long   0       // _data_size            // SizeOfRawData
        .long   282624  // _data - ImageBase     // PointerToRawData

        .long   0               
        .long   0               
        .short  0               
        .short  0               
        .long   0x02000040      // Characteristics (section flags)
HeaderEnd:
	.fill	4096 - (HeaderEnd - HeaderBase)


//	.section text
CodeStart:

        .equ EFI_SUCCESS                                  ,0
        .equ EFI_SYSTEM_TABLE_SIGNATURE                   ,0x5453595320494249
        .equ EFI_SYSTEM_TABLE_CONOUT                      ,64
        .equ EFI_SYSTEM_TABLE_RUNTIMESERVICES             ,88
        .equ EFI_SYSTEM_TABLE_BOOTSERVICES                ,96
     
        .equ EFI_SIMPLE_TEXT_OUTPUT_PROTOCOL_RESET        ,0
        .equ EFI_SIMPLE_TEXT_OUTPUT_PROTOCOL_OUTPUTSTRING ,8
        .equ EFI_SIMPLE_TEXT_OUTPUT_PROTOCOL_CLEARSCREEN  ,48
             
        .equ EFI_BOOT_SERVICES_GETMEMORYMAP               ,56
        .equ EFI_BOOT_SERVICES_LOCATEHANDLE               ,176
        .equ EFI_BOOT_SERVICES_LOADIMAGE                  ,200
        .equ EFI_BOOT_SERVICES_EXIT                       ,216
        .equ EFI_BOOT_SERVICES_EXITBOOTSERVICES           ,232
        .equ EFI_BOOT_SERVICES_LOCATEPROTOCOL             ,320
             
        .equ EFI_RUNTIME_SERVICES_RESETSYSTEM             ,104


	.equ oHandle		,8
	.equ oSystemTable	,16
	.equ oInterface		,24
	.equ oBS		,32
	.equ oRTS		,40

        b               Over
msg:    .short 'o', 'k', '.', '\r', '\n',  0

memmapsize:      .quad 4096		//+16
memmapkey:       .quad 0		//+24
memmapdescsize:  .quad 48		//+32
memmapdescver:   .quad 0		//+40


Over:

	mov		x26, x0		// save the Handle
	mov		x27, x1		// save the SystemTable
	mov		x28, x2		// save the BaseOfCode

	ldr		x8, [x27, #EFI_SYSTEM_TABLE_CONOUT]
	ldr		x8, [x8, #EFI_SIMPLE_TEXT_OUTPUT_PROTOCOL_OUTPUTSTRING]
        mov             x1, x28
	add		x1, x1, #4					
	blr		x8		// Output 'ok.' from efi

	ldr		x8, [x27, #EFI_SYSTEM_TABLE_BOOTSERVICES]
	ldr		x8, [x8, #EFI_BOOT_SERVICES_GETMEMORYMAP]
        mov             x0, x28
	add		x0, x0, #16	// * memmapsize					
        mov             x1, x28
	add		x1, x1, #4096	// * memmap					
        mov             x2, x28
	add		x2, x2, #24	// * memmapkey					
        mov             x3, x28
	add		x3, x3, #32	// * memmapdescsize					
        mov             x4, x28
	add		x4, x4, #40	// * memmapdescver					
	blr		x8

	ldr		x8, [x27, #EFI_SYSTEM_TABLE_BOOTSERVICES]
	ldr		x8, [x8, #EFI_BOOT_SERVICES_EXITBOOTSERVICES]
        mov             x0, x26
        mov             x1, x28
	ldr		x1, [x1, #56]	// memmapkey
	blr		x8		
        b		FixAt
EfiEnd:
        .fill   256 - (EfiEnd - CodeStart)
FixAt:
        .equ    uart, 0x9000000
	movz x1, 0x900, lsl 16

        
        movz x0, #110
        str x0, [x1]

        movz x0, #111
        str x0, [x1]

        movz x0, #32
        str x0, [x1]

        movz x0, #102
        str x0, [x1]

        movz x0, #105
        str x0, [x1]

        movz x0, #120
        str x0, [x1]

        movz x0, #117
        str x0, [x1]

        movz x0, #112
        str x0, [x1]

        movz x0, #46
        str x0, [x1]

        movz x0, #10
        str x0, [x1]

//  Bus  0, device   2, function 0:
//    Display controller: PCI device 1234:1111
//      PCI subsystem 1af4:1100
//      BAR0: 32 bit prefetchable memory at 0x11000000 [0x11ffffff].
//      BAR2: 32 bit memory at 0x12000000 [0x12000fff].
//      BAR6: 32 bit memory at 0xffffffffffffffff [0x00007ffe].
//      id ""


          // bochs_display registers and values
        .equ    VBE_DISPI_INDEX_ID,               0x0
        .equ    VBE_DISPI_INDEX_XRES,             0x1
        .equ    VBE_DISPI_INDEX_YRES,             0x2
        .equ    VBE_DISPI_INDEX_BPP,              0x3
        .equ    VBE_DISPI_INDEX_ENABLE,           0x4
        .equ    VBE_DISPI_INDEX_BANK,             0x5
        .equ    VBE_DISPI_INDEX_VIRT_WIDTH,       0x6
        .equ    VBE_DISPI_INDEX_VIRT_HEIGHT,      0x7
        .equ    VBE_DISPI_INDEX_X_OFFSET,         0x8
        .equ    VBE_DISPI_INDEX_Y_OFFSET,         0x9
        .equ    VBE_DISPI_INDEX_VIDEO_MEMORY_64K, 0xa

        .equ    VBE_DISPI_ENABLED,                0x01
        .equ    VBE_DISPI_GETCAPS,                0x02
        .equ    VBE_DISPI_8BIT_DAC,               0x20
        .equ    VBE_DISPI_LFB_ENABLED,            0x40
        .equ    VBE_DISPI_NOCLEARMEM,             0x80

          // Offsets for accessing ioports via PCI BAR1 (MMIO) 
        .equ    VGA_MMIO_OFFSET, (0x400 - 0x3c0)
        .equ    VBE_MMIO_OFFSET, 0x500

        
        movz    x1, 0x1100, lsl 16
        movz    x2, 0x100, lsl 16
	sub	x2, x2, #2
	movz    w0, 0xBBBB
zz:	strh	w0, [x1]
	add	x1, x1, #2
	sub	x2, x2, #2
	cmp	x2, #0
	bne zz

        movz    x1, 0x1200, lsl 16
	add	x1, x1, 0x400
        movz    w0, 0x20             
        strh    w0, [x1]

	add	x1, x1, 0x100      // 0x12000500

        movz    w0, #0             // disable VBE
        strh    w0, [x1], #6
        movz    w0, 0xB0C5
        strh    w0, [x1]
        movz    w0, #800          // 800
        strh    w0, [x1], #2
        movz    w0, #600          // 600
        strh    w0, [x1], #4
        movz    w0, #32           // bpp
        strh    w0, [x1], #8
        movz    w0, 0x0041        // VBE lfb, enabled
        strh    w0, [x1], #6



loop:
        b               loop

CodeEnd:
                .fill 4096 - (CodeEnd - CodeStart)


//	.section data
DataStart:

//memory map goes here

DataEnd:
		.fill 8192 - (DataEnd - DataStart)
 
payload:     // 64 4k pages=262144 (256k)


		.fill 262144 //- 8 - 27  db 0

