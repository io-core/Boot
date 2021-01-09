bits 64
org 0x8000000
section .header

DOS:
    dd 0x00005a4d
    times 14 dd 0
    dd 0x00000080
    times 16 dd 0

PECOFF:
    dd `PE\0\0`     ; sig
                    ; i386 / IA32      BOOTIA32.EFI  0x14c
                    ; x86_64 / AMD64   BOOTX64.EFI   0x8664
                    ; IA64 / Itanium   BOOTIA64.EFI  0x200
                    ; ARM / AArch32    BOOTARM.EFI   0x1c2
                    ; AArch64          BOOTAA64.EFI  0xaa64
    dw 0x8664       ; type
    dw 3            ; sections
    dd 0x5cba52f6       ; timestamp
    dq 0            ; * symbol table + # symbols
    dw osize        ; oheader size
    dw 0x202e       ; characteristics

OHEADER:
    dd 0x0000020b       ; oheader + 0000 linker sig
    dd 8192 ;codesize       ; code size
    dd 270336 ;was 8192 ;datasize       ; data size
    dd 0            ; uninitialized data size
    dd 4096         ; * entry
    dd 4096         ; * code base
    dq 0x8000000        ; * image base 
    dd 4096         ; section alignment
    dd 4096         ; file alignment
    dq 0            ; os maj, min, image maj, min
    dq 0            ; subsys maj, min, reserved
    dd 282624 ; was  0x5000        image size
    dd 4096         ; headers size
    dd 0            ; checksum
    dd 0x0040000A       ; dll characteristics & subsystem
    dq 0x10000      ; stack reserve size
    dq 0x10000      ; stack commit size
    dq 0x10000      ; heap reserve size
    dq 0            ; heap reserve commit
    dd 0            ; loader flags
    dd 0x10         ; rva count

DIRS:
    times 5 dq 0        ; unused
    dd 0x8005000        ; virtual address .reloc
    dd 0            ; size .reloc
        times 10 dq 0       ; unused
OEND:
osize equ OEND - OHEADER

SECTS:
.1:
    dq  `.text`     ; name
    dd  8192 ;codesize      ; virtual size
    dd  4096        ; virtual address
    dd  8192        ; raw data size
    dd  4096        ; * raw data
    dq  0           ; * relocations, * line numbers
    dd  0           ; # relocations, # line numbers
    dd  0x60000020      ; characteristics

.2:
        dq  `.data`
        dd  270336 ; was 8192 datasize
        dd  12288
        dd  270336 ; was 8192
        dd  12288
        dq  0
        dd  0
        dd  0xC0000040


.3:
    dq  `.reloc`
    dd  0
    dd  282624; was 20480
    dd  0
    dd  282624; was 20480
    dq  0
    dd  0
    dd  0x02000040

    times 4096 - ($-$$) db 0  ;align the text section on a 4096 byte boundary

section .text follows=.header

EFI_SUCCESS                                 equ 0
EFI_SYSTEM_TABLE_SIGNATURE                  equ 0x5453595320494249
EFI_SYSTEM_TABLE_CONOUT                         equ 64
EFI_SYSTEM_TABLE_RUNTIMESERVICES                equ 88
EFI_SYSTEM_TABLE_BOOTSERVICES                   equ 96

EFI_SIMPLE_TEXT_OUTPUT_PROTOCOL_RESET           equ 0
EFI_SIMPLE_TEXT_OUTPUT_PROTOCOL_OUTPUTSTRING        equ 8

EFI_BOOT_SERVICES_GETMEMORYMAP              equ 56
EFI_BOOT_SERVICES_LOCATEHANDLE              equ 176
EFI_BOOT_SERVICES_LOADIMAGE             equ 200
EFI_BOOT_SERVICES_EXIT                  equ 216
EFI_BOOT_SERVICES_EXITBOOTSERVICES          equ 232
EFI_BOOT_SERVICES_LOCATEPROTOCOL            equ 320

EFI_RUNTIME_SERVICES_RESETSYSTEM            equ 104

	jmp over

msg		db __utf16__ `OK.\r\n\0`
memmapsize:     dq 4096             
memmapkey:      dq 0                
memmapdescsize: dq 48               
memmapdescver:  dq 0                
Handle          dq 0     
SystemTable     dq 0     
ick		db __utf16__ `ick\r\n\0`
non		db 'no payload\n'

over:

	sub rsp, 6*8+8    ; Stack is misaligned by 8 when control is transferred to
                          ; the EFI entry point. In addition to the shadow space
                          ; (32 bytes) and space for stack based paramaters to be
                          ; saved - we also have to allocate an additional
                          ; 8 bytes to ensure stack alignment on a 16-byte boundary
                          ; 8+(6*8+8)=64, 64 is evenly divisible by 16 at this point

	mov [Handle], rcx
	mov [SystemTable], rdx

	mov rax, [SystemTable]
	mov rax, [rax + EFI_SYSTEM_TABLE_BOOTSERVICES]
	mov [BS], rax

	lea rdx, [msg]
	mov rcx, [SystemTable]
	mov rcx, [rcx + EFI_SYSTEM_TABLE_CONOUT]
	call [rcx + EFI_SIMPLE_TEXT_OUTPUT_PROTOCOL_OUTPUTSTRING]

; get the memory map

	mov qword [memmapsize], 4096
	lea rcx, [memmapsize]
	lea rdx, [memmap]
	lea r8, [memmapkey]
	lea r9, [memmapdescsize]
	lea r10, [memmapdescver]
	mov [rsp+32], r10         ; Don't push R10 on the stack, move it directly to
	                           ; the stack immediately above the shadow space
	mov rbx, [BS]
	call [rbx + EFI_BOOT_SERVICES_GETMEMORYMAP]
	cmp rax, EFI_SUCCESS
	jne oops

; exit boot services
	mov rcx, [Handle]
	mov rdx, [memmapkey]
	mov rbx, [SystemTable]
	mov rbx, [rbx + EFI_SYSTEM_TABLE_BOOTSERVICES]
	call [rbx + EFI_BOOT_SERVICES_EXITBOOTSERVICES]
	cmp rax, EFI_SUCCESS
	
	je fillframe

oops:
        lea rdx, [ick]
        mov rcx, [SystemTable]
        mov rcx, [rcx + EFI_SYSTEM_TABLE_CONOUT]
        call [rcx + EFI_SIMPLE_TEXT_OUTPUT_PROTOCOL_OUTPUTSTRING]

	jmp $

fillframe:

SERIAL equ 0x3f8
PORT equ SERIAL + 5

;   outb(PORT + 1, 0x00);    // Disable all interrupts
	mov al, 0
	mov dx, SERIAL + 1
	out dx, al
;   outb(PORT + 3, 0x80);    // Enable DLAB (set baud rate divisor)
	mov al, 0x80
	mov dx, SERIAL + 3
	out dx, al
;   outb(PORT + 0, 0x01);    // Set divisor to 0 (lo byte) 115200 baud
	mov al, 1
	mov dx, SERIAL + 0
	out dx, al
;   outb(PORT + 1, 0x00);    //                  (hi byte)
	mov al, 0
	mov dx, SERIAL + 1
	out dx, al
;   outb(PORT + 3, 0x03);    // 8 bits, no parity, one stop bit
	mov al, 3
	mov dx, SERIAL + 3
	out dx, al
;   outb(PORT + 2, 0xC7);    // Enable FIFO, clear them, with 14-byte threshold
	mov al, 0xC7
	mov dx, SERIAL + 2
	out dx, al
;   outb(PORT + 4, 0x0B);    // IRQs enabled, RTS/DSR set
	mov al, 0x0B
	mov dx, SERIAL + 4
	out dx, al
;   outb(PORT + 1, 0x0);    // Disable interrupts
	mov al, 0x0
	mov dx, SERIAL + 1
	out dx, al


;   inportb(device + 5) & 0x20; // check if clear to send
tp:
	mov dx, SERIAL + 5
	in  al, dx
	and al, 0x20	
	cmp al, 0
	je  tp
	
        mov al, 110
	mov dx, SERIAL
	out dx, al

        mov al, 111
	mov dx, SERIAL
	out dx, al

        mov al, 32
	mov dx, SERIAL
	out dx, al

        mov al, 102
	mov dx, SERIAL
	out dx, al

        mov al, 105
	mov dx, SERIAL
	out dx, al

        mov al, 120
	mov dx, SERIAL
	out dx, al

        mov al, 117
	mov dx, SERIAL
	out dx, al

        mov al, 112
	mov dx, SERIAL
	out dx, al

        mov al, 46
	mov dx, SERIAL
	out dx, al

        mov al, 10
	mov dx, SERIAL
	out dx, al



	jmp $

waits:

jmp payload

    times 8192-($-$$) db 0

codesize equ $ - $$

section .data follows=.text

dmagic		dq 0x1122334455667788 ;0
xHandle          dq 0     ;8
xSystemTable     dq 0     ;16
Interface       dq 0     ;24
BS              dq 0     ;32
RTS             dq 0     ;40
STK             dq 0     ;48
FB              dq 0     ;56
FBS             dq 0     ;64
HR		dq 0
VR		dq 0
PPS		dq 0
xmemmapsize      dq 4096
xmemmapkey       dq 0
xmemmapdescsize  dq 48
xmemmapdescver   dq 0

_EFI_GRAPHICS_OUTPUT_PROTOCOL_GUID db 0xde, 0xa9, 0x42, 0x90, 0xdc, 0x23, 0x38, 0x4a
                                  db 0x96, 0xfb, 0x7a, 0xde, 0xd0, 0x80, 0x51, 0x6a
fail     db __utf16__ `fail.\r\n\0`
nok      db __utf16__ `Not OK.\r\n\0`
yok      db __utf16__ `OK.\r\n\0`
herewego db __utf16__ `here we go\r\n\0`
_Hex     db '0123456789ABCDEF'
_Num     dw 0,0
_Nl      dw 13,10,0

    times 4096-($-$$) db 0

memmap:
    times 4096 db 0
payload:     ;64 4k pages=262144 (256k)

mov rcx, [FB]
mov rax, [FBS]
Qz:
dec rax
mov byte[rcx+rax],0xBB
jnz Qz

jmp $
magic          dq 0x9988776655443322

    times 262144 - 8 - 27  db 0
datasize equ $ - $$


section .reloc follows=.data
