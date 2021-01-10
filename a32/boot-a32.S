.section .text
.global _Reset
_Reset:

	b	Over
Under:
        .long 0

Over:
	.equ    uart, 0x9000000

	movw    r1, #:lower16:uart
	movt    r1, #:upper16:uart
	
	
 
	sub r0, r0, r0
 	add r0, #72
	str r0, [r1]	

	sub r0, r0, r0
 	add r0, #101
	str r0, [r1]	

	sub r0, r0, r0
 	add r0, #108
	str r0, [r1]	

	sub r0, r0, r0
 	add r0, #108
	str r0, [r1]	

	sub r0, r0, r0
 	add r0, #111
	str r0, [r1]	

	sub r0, r0, r0
 	add r0, #32
	str r0, [r1]	

	sub r0, r0, r0
 	add r0, #87
	str r0, [r1]	

	sub r0, r0, r0
 	add r0, #111
	str r0, [r1]	

	sub r0, r0, r0
 	add r0, #114
	str r0, [r1]	

	sub r0, r0, r0
 	add r0, #108
	str r0, [r1]	

	sub r0, r0, r0
 	add r0, #100
	str r0, [r1]	

	sub r0, r0, r0
 	add r0, #33
	str r0, [r1]	

	B .
heel:

        .fill 262144 + 8192 + 4096 
