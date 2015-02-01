.global	DisplayAnimation

.equ	Display_String, 0x204

.equ	Animation_Height, 7
.equ	Animation_Width, 22
.equ	Max_Frames, 4

.equ	Animation_X, 5
.equ	Animation_Y, 2
.text

	DisplayAnimation:
		stmfd	sp!, {r0-r8, lr}
		ldr	r0, =animationFrame
		ldr	r1, [r0]
		bl	loadFrameAddress
		bl	saveNextFrame
		bl	displayAnim
		ldmfd	sp!, {r0-r8, pc}

	
	saveNextFrame:
		add	r1, r1, #1
		cmp	r1, #Max_Frames
		ble	exitSaveNextFrame
		mov	r1, #1
	exitSaveNextFrame:
		str	r1, [r0]
		mov	pc, lr
		
		
	@	r1 - Frame
	@	Returns r2 - Frame Address
	loadFrameAddress:
	
	test1:
		cmp	r1, #1
		bne	test2
		ldr	r2, =Frame1
		b	exitLoadFrameAddress
	test2:
		cmp	r1, #2
		bne	test3
		ldr	r2, =Frame2
		b	exitLoadFrameAddress
	test3:
		cmp	r1, #3
		bne	test4
		ldr	r2, =Frame3
		b	exitLoadFrameAddress
	test4:
		cmp	r1, #4
		bne	exitLoadFrameAddress
		ldr	r2, =Frame4
	exitLoadFrameAddress:
		mov	pc, lr
		
		
	displayAnim:
		stmfd	sp!, {r0-r8, lr}
		mov	r0, #Animation_X
		mov	r1, #Animation_Y
		mov	r3, #Animation_Height
		swi	Display_String	
	displayAnimLoop:
		cmp	r3, #0
		beq	exitDisplayAnim
		sub	r3, r3, #1
		add	r1, r1, #1
		add	r2, r2, #Animation_Width
		swi	Display_String
		b	displayAnimLoop
	exitDisplayAnim:
		ldmfd	sp!, {r0-r8, pc}
		
		
.data
.align

	animationFrame:	.word	2
	
	.align			
	Frame1:		.asciz	"Ding   0  0          "
			.asciz	"     0  0            "
			.asciz	"0  0  0  0           "
			.asciz	" 0  0  0             "
			.asciz	"  0  0               "
			.asciz	"   0                 "
			.asciz	"    0                "

.align
	Frame4:
	Frame2:		.asciz	"          0          "
			.asciz	"        0 0 0        "
			.asciz	"        0 0 0        "
			.asciz	"        0 0 0        "
			.asciz	"        0 0 0        "
			.asciz	"      0 0 0 0 0      "
			.asciz	"                     "
.align
	Frame3:		.asciz	"          0  0   Dong"
			.asciz	"            0  0     "
			.asciz	"           0  0  0  0"
			.asciz	"             0  0  0 "
			.asciz	"               0  0  "
			.asciz	"                 0   "
			.asciz	"                0    "
                                                

.end
