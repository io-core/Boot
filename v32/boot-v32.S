.section .text
.globl _start

_start:

	.equ uart, 0x10000000
	li	a1, uart

        sub a0, a0, a0
        add a0, a0, 72
        sw a0, (a1)

        sub a0, a0, a0
        add a0, a0, 101
        sw a0, (a1)

        sub a0, a0, a0
        add a0, a0, 108
        sw a0, (a1)

        sub a0, a0, a0
        add a0, a0, 108
        sw a0, (a1)

        sub a0, a0, a0
        add a0, a0, 111
        sw a0, (a1)

        sub a0, a0, a0
        add a0, a0, 32
        sw a0, (a1)

        sub a0, a0, a0
        add a0, a0, 87
        sw a0, (a1)

        sub a0, a0, a0
        add a0, a0, 111
        sw a0, (a1)

        sub a0, a0, a0
        add a0, a0, 114
        sw a0, (a1)

        sub a0, a0, a0
        add a0, a0, 108
        sw a0, (a1)

        sub a0, a0, a0
        add a0, a0, 100
        sw a0, (a1)

        sub a0, a0, a0
        add a0, a0, 33
        sw a0, (a1)




    j  .


    .long 0x11223344

    li t0, 0x10012000
    li t1, 0x200000
    sw t1, 0x08(t0)
    sw t1, 0x0C(t0)
    sw t1, 0x40(t0)
