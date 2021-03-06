
.global	DisplayData

.global	DisplayPrimaryFirstHourDigit
.global	DisplayPrimarySecondHourDigit
.global	DisplayPrimaryFirstMinuteDigit
.global	DisplayPrimarySecondMinuteDigit
.global	DisplayPrimaryFirstSecondsDigit
.global	DisplayPrimarySecondSecondsDigit
.global DisplayPrimaryAMPM

.global	DisplayRealFirstHourDigit
.global	DisplayRealSecondHourDigit
.global	DisplayRealFirstMinuteDigit
.global	DisplayRealSecondMinuteDigit
.global	DisplayRealFirstSecondsDigit
.global	DisplayRealSecondSecondsDigit
.global DisplayRealAMPM

.global	DisplayAlarmFirstHourDigit
.global	DisplayAlarmSecondHourDigit
.global	DisplayAlarmFirstMinuteDigit
.global	DisplayAlarmSecondMinuteDigit
.global	DisplayAlarmFirstSecondsDigit
.global	DisplayAlarmSecondSecondsDigit
.global DisplayAlarmAMPM
.global	DisplayAlarmStatus

.global	Display12To24Instructions
.global	DisplayRealTime
.global	DisplayAlarmTime

.global	FlashLED


.equ	Clear_LCD, 0x206

.equ 	SEG_A,0x80
.equ 	SEG_B,0x40
.equ 	SEG_C,0x20
.equ 	SEG_D,0x08
.equ 	SEG_E,0x04
.equ 	SEG_F,0x02
.equ 	SEG_G,0x01
.equ 	SEG_P,0x10
.equ	Display_Seg, 0x200

.equ	Light_LED, 0x201
.equ	Off_LED, 0x00
.equ	Left_LED, 0x02
.equ	Right_LED, 0x01
.equ	Both_LED, 0x03

.equ	Display_String, 0x204
.equ	Display_Integer, 0x205
.equ	Display_Character, 0x207

.equ	Set_Time_State, 0
.equ	Display_Time_State, 1
.equ	Toggle_Alarm_State, 2
.equ	Set_Alarm_Time_State, 3
.equ	Alarm_State, 4

.equ	Digits_Y, 4
.equ	First_Hour_Digit_X, 8
.equ	Second_Hour_Digit_X, First_Hour_Digit_X+4
.equ	Colon_Digit_X, Second_Hour_Digit_X+4
.equ	First_Minute_Digit_X, Colon_Digit_X+4
.equ	Second_Minute_Digit_X, First_Minute_Digit_X+4
.equ	First_Seconds_Digit_X, Second_Minute_Digit_X+4
.equ	Second_Seconds_Digit_X, First_Seconds_Digit_X+1
.equ	Seconds_Digit_Y, Digits_Y+4
.equ	AMPM_X, Second_Seconds_Digit_X+2
.equ	AMPM_Y, Seconds_Digit_Y

.equ	Secondary_Digits_Y, 1
.equ	Secondary_First_Hour_Digit_X, 32
.equ	Secondary_Second_Hour_Digit_X, Secondary_First_Hour_Digit_X+1
.equ	Secondary_Colon_Digit_X, Secondary_Second_Hour_Digit_X+1
.equ	Secondary_First_Minute_Digit_X, Secondary_Colon_Digit_X+1
.equ	Secondary_Second_Minute_Digit_X, Secondary_First_Minute_Digit_X+1
.equ	Secondary_AMPM_X, Secondary_Second_Minute_Digit_X+2
.equ	Secondary_AMPM_Y, Secondary_Digits_Y

.equ	Alarm_Status_X, Secondary_First_Hour_Digit_X
.equ	Alarm_Status_Y, 0

.equ	Instruction_Y, 10

.text


	FlashLED:
		stmfd	sp!, {r0-r3, lr}
		ldr	r1, =ledFlasherState
		ldr	r2, [r1]
		cmp	r2, #1
		beq	displayLEDs
		mov	r0, #Off_LED
		b	exitFlash
	displayLEDs:
		mov	r0, #Both_LED
	exitFlash:
		swi	Light_LED
		eor	r2, r2, #1
		str	r2, [r1]
		ldmfd	sp!, {r0-r3, pc}

@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@	Instruction Display
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
	DisplayData:
		stmfd	sp!, { r0-r8, lr}
		swi	Clear_LCD
		cmp	r9, #Set_Time_State
		bleq	DisplaySetTimeInstructions
		cmp	r9, #Set_Alarm_Time_State
		bleq	DisplaySetAlarmTimeInstructions
		cmp	r9, #Display_Time_State
		bleq	DisplayDisplayTimeInstructions
		cmp	r9, #Toggle_Alarm_State
		bleq	DisplayToggleAlarmInstructions
		cmp	r9, #Alarm_State
		bleq	DisplayAlarmInstructions
		
		bl	DisplayAlarmStatus
		bl	Display12To24Instructions
		bl	DisplayAlarmTime
		bl	DisplayRealTime
		
		ldmfd	sp!, { r0-r8, pc}

	DisplaySetAlarmTimeInstructions:
		stmfd	sp!, { r0-r2, lr}
		
		mov	r0, #Left_LED
		swi	Light_LED
		ldr	r0, =setAlarmDisplay
		ldr	r0, [r0]
		swi	Display_Seg
		
		mov	r0, #0
		mov	r1, #0
		ldr	r2, =setAlarmTimeDesc
		swi	Display_String
		
		ldr	r2, =changeTimeInstr
		bl	displayInstructions
		
		ldmfd	sp!, { r0-r2, pc}
		
	DisplaySetTimeInstructions:
		stmfd	sp!, { r0-r2, lr}
		
		mov	r0, #Off_LED
		swi	Light_LED
		ldr	r0, =setTimeDisplay
		ldr	r0, [r0]
		swi	Display_Seg
		
		mov	r0, #0
		mov	r1, #0
		ldr	r2, =setTimeDesc
		swi	Display_String
		
		ldr	r2, =changeTimeInstr
		bl	displayInstructions
		
		ldmfd	sp!, { r0-r2, pc}
		
	DisplayDisplayTimeInstructions:
		stmfd	sp!, { r0, r1, r2, lr}
		mov	r0, #Right_LED
		swi	Light_LED
		ldr	r0, =displayTimeDisplay
		ldr	r0, [r0]
		swi	Display_Seg
		
		mov	r0, #0
		mov	r1, #0
		ldr	r2, =displayTimeDesc
		swi	Display_String
		
		
		ldr	r2, =displayTimeInstr
		bl	displayInstructions
		
		ldmfd	sp!, { r0, r1, r2, pc}
		
	DisplayToggleAlarmInstructions:
		stmfd	sp!, { r0, r1, r2, lr}
		mov	r0, #Off_LED
		swi	Light_LED
		ldr	r0, =toggleAlarmDisplay
		ldr	r0, [r0]
		swi	Display_Seg
		
		mov	r0, #0
		mov	r1, #0
		ldr	r2, =toggleAlarmDesc
		swi	Display_String
		
		ldmfd	sp!, { r0, r1, r2, pc}
		
	DisplayAlarmInstructions:
		stmfd	sp!, { r0, r1, r2, lr}
		mov	r0, #Both_LED
		swi	Light_LED
		ldr	r0, =alarmDisplay
		ldr	r0, [r0]
		swi	Display_Seg
		
		mov	r0, #0
		mov	r1, #0
		ldr	r2, =alarmDesc
		swi	Display_String
		
		
		ldr	r2, =alarmInstr
		bl	displayInstructions
		
		ldmfd	sp!, { r0, r1, r2, pc}
		
		
	displayInstructions:
		stmfd	sp!, {r0, r1, r3, lr}
		mov	r0, #0
		mov	r1, #Instruction_Y
		mov	r3, #5
	displayInstrLoop:
		cmp	r3, #0
		beq	exitDisplayInstrLoop
		swi	Display_String
		add	r2, r2, #41
		add	r1, r1, #1
		sub	r3, r3, #1
		b	displayInstrLoop
	exitDisplayInstrLoop:
		ldmfd	sp!, {r0, r1, r3, pc}
		
	Display12To24Instructions:
		stmfd	sp!, {r0-r8, lr}
		bl	GetMaxHours
		ldr	r0, [r0]
		cmp	r0, #12
		bne	displayTo12
	displayTo24:
		ldr	r2, =toggleTo24Instr
		b	displayToggle12To24
	displayTo12:
		ldr	r2, =toggleTo12Instr
	displayToggle12To24:
		mov	r0, #0
		mov	r1, #1
		swi	Display_String
		ldmfd	sp!, {r0-r8, pc}
		
		
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@	Alarm Time Display
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
	DisplayAlarmTime:
		stmfd	sp!, {r0-r8, lr}
		bl	GetAlarmHours
		mov	r1, r0
		bl	GetAlarmMinutes
		mov	r2, r0
		bl	GetAlarmSeconds
		mov	r3, r0
		bl	GetAlarmAMPM
		mov	r4, r0

		bl	AlarmPrimary
		cmp	r0, #1
		bleq	DisplaySecondaryTime
		cmp	r0, #0
		bleq	DisplayPrimaryTime
	
		ldmfd	sp!, {r0-r8, pc}
		
		
	DisplayAlarmFirstHourDigit:
		stmfd	sp!, {r0-r8, lr}
		bl	GetAlarmHours
		mov	r1, r0
		bl	AlarmPrimary
		cmp	r0, #1
		bleq	DisplaySecondaryFirstHourDigit
		cmp	r0, #0
		bleq	DisplayPrimaryFirstHourDigit
		ldmfd	sp!, {r0-r8, pc}
		
	DisplayAlarmSecondHourDigit:
		stmfd	sp!, {r0-r8, lr}
		bl	GetAlarmHours
		mov	r1, r0
		bl	AlarmPrimary
		cmp	r0, #1
		bleq	DisplaySecondarySecondHourDigit
		cmp	r0, #0
		bleq	DisplayPrimarySecondHourDigit
		ldmfd	sp!, {r0-r8, pc}
	
	DisplayAlarmFirstMinuteDigit:
		stmfd	sp!, {r0-r8, lr}
		bl	GetAlarmMinutes
		mov	r2, r0
		bl	AlarmPrimary
		cmp	r0, #1
		bleq	DisplaySecondaryFirstMinuteDigit
		cmp	r0, #0
		bleq	DisplayPrimaryFirstMinuteDigit
		ldmfd	sp!, {r0-r8, pc}
	
	DisplayAlarmSecondMinuteDigit:
		stmfd	sp!, {r0-r8, lr}
		bl	GetAlarmMinutes
		mov	r2, r0
		bl	AlarmPrimary
		cmp	r0, #1
		bleq	DisplaySecondarySecondMinuteDigit
		cmp	r0, #0
		bleq	DisplayPrimarySecondMinuteDigit
		ldmfd	sp!, {r0-r8, pc}
	
	DisplayAlarmFirstSecondsDigit:
		stmfd	sp!, {r0-r8, lr}
		bl	GetAlarmSeconds
		mov	r3, r0
		bl	AlarmPrimary
		cmp	r0, #0
		bleq	DisplayPrimaryFirstSecondsDigit
		ldmfd	sp!, {r0-r8, pc}
	
	DisplayAlarmSecondSecondsDigit:
		stmfd	sp!, {r0-r8, lr}
		bl	GetAlarmSeconds
		mov	r3, r0
		bl	AlarmPrimary
		cmp	r0, #0
		bleq	DisplayPrimarySecondSecondsDigit
		ldmfd	sp!, {r0-r8, pc}
	
	DisplayAlarmAMPM:
		stmfd	sp!, {r0-r8, lr}
		bl	GetAlarmAMPM
		mov	r4, r0
		bl	AlarmPrimary
		cmp	r0, #1
		bleq	DisplaySecondaryAMPM
		cmp	r0, #0
		bleq	DisplayPrimaryAMPM
		ldmfd	sp!, {r0-r8, pc}
	
	
	
	@	returns r0 - 0 if primary  |  1 if secondary  | -1 Neither
	AlarmPrimary:
		mov	r0, #-1
	alarmPrimaryTestSetTime:
		cmp	r9, #Set_Time_State
		bne	alarmPrimaryTestDisplayTime
		mov	r0, #1
		b	exitAlarmPrimary
	alarmPrimaryTestDisplayTime:
		cmp	r9, #Display_Time_State
		bne	alarmPrimaryTestSetAlarmTime
		mov	r0, #1
		b	exitAlarmPrimary
	alarmPrimaryTestSetAlarmTime:
		cmp	r9, #Set_Alarm_Time_State
		bne	alarmPrimaryTestToggleAlarm
		mov	r0, #0
		b	exitAlarmPrimary
	alarmPrimaryTestToggleAlarm:
		cmp	r9, #Toggle_Alarm_State
		bne	exitAlarmPrimary
		mov	r0, #0
	exitAlarmPrimary:
		mov	pc, lr
		
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@	Real Time Display
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
	DisplayRealTime:
		stmfd	sp!, {r0-r8, lr}
		bl	GetRealHours
		mov	r1, r0
		bl	GetRealMinutes
		mov	r2, r0
		bl	GetRealSeconds
		mov	r3, r0
		bl	GetRealAMPM
		mov	r4, r0
		
		bl	RealPrimary
		cmp	r0, #1
		bleq	DisplaySecondaryTime
		cmp	r0, #0
		bleq	DisplayPrimaryTime
		ldmfd	sp!, {r0-r8, pc}

				
	DisplayRealFirstHourDigit:
		stmfd	sp!, {r0-r8, lr}
		bl	GetRealHours
		mov	r1, r0
		bl	RealPrimary
		cmp	r0, #1
		bleq	DisplaySecondaryFirstHourDigit
		cmp	r0, #0
		bleq	DisplayPrimaryFirstHourDigit
		ldmfd	sp!, {r0-r8, pc}
		
	DisplayRealSecondHourDigit:
		stmfd	sp!, {r0-r8, lr}
		bl	GetRealHours
		mov	r1, r0
		bl	RealPrimary
		cmp	r0, #1
		bleq	DisplaySecondarySecondHourDigit
		cmp	r0, #0
		bleq	DisplayPrimarySecondHourDigit
		ldmfd	sp!, {r0-r8, pc}
	
	DisplayRealFirstMinuteDigit:
		stmfd	sp!, {r0-r8, lr}
		bl	GetRealMinutes
		mov	r2, r0
		bl	RealPrimary
		cmp	r0, #1
		bleq	DisplaySecondaryFirstMinuteDigit
		cmp	r0, #0
		bleq	DisplayPrimaryFirstMinuteDigit
		ldmfd	sp!, {r0-r8, pc}
	
	DisplayRealSecondMinuteDigit:
		stmfd	sp!, {r0-r8, lr}
		bl	GetRealMinutes
		mov	r2, r0
		bl	RealPrimary
		cmp	r0, #1
		bleq	DisplaySecondarySecondMinuteDigit
		cmp	r0, #0
		bleq	DisplayPrimarySecondMinuteDigit
		ldmfd	sp!, {r0-r8, pc}
	
	DisplayRealFirstSecondsDigit:
		stmfd	sp!, {r0-r8, lr}
		bl	GetRealSeconds
		mov	r3, r0
		bl	RealPrimary
		cmp	r0, #0
		bleq	DisplayPrimaryFirstSecondsDigit
		ldmfd	sp!, {r0-r8, pc}
	
	DisplayRealSecondSecondsDigit:
		stmfd	sp!, {r0-r8, lr}
		bl	GetRealSeconds
		mov	r3, r0
		bl	RealPrimary
		cmp	r0, #0
		bleq	DisplayPrimarySecondSecondsDigit
		ldmfd	sp!, {r0-r8, pc}
	
	DisplayRealAMPM:
		stmfd	sp!, {r0-r8, lr}
		bl	GetRealAMPM
		mov	r4, r0
		bl	RealPrimary
		cmp	r0, #1
		bleq	DisplaySecondaryAMPM
		cmp	r0, #0
		bleq	DisplayPrimaryAMPM
		ldmfd	sp!, {r0-r8, pc}
	
	
	
	@	returns r0 - 0 if primary  |  1 if secondary
	RealPrimary:
		mov	r0, #1
	realPrimaryTestSetTime:
		cmp	r9, #Set_Time_State
		bne	realPrimaryTestDisplayTime
		mov	r0, #0
		b	exitRealPrimary
	realPrimaryTestDisplayTime:
		cmp	r9, #Display_Time_State
		bne	exitRealPrimary
		mov	r0, #0
		b	exitRealPrimary
	exitRealPrimary:
		mov	pc, lr
	
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@	Secondary Time Display
@	r1 - Hours Address
@	r2 - Minutes Address
@	r3 - Seconds Address
@	r4 - AMPM Address
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@	
	DisplaySecondaryTime:
		stmfd	sp!, {r0-r9, lr}
		
		bl	DisplaySecondaryFirstHourDigit
		bl	DisplaySecondarySecondHourDigit
		bl	DisplaySecondaryColonDigit
		bl	DisplaySecondaryFirstMinuteDigit
		bl	DisplaySecondarySecondMinuteDigit
		
		bl	DisplaySecondaryAMPM
		
		ldmfd	sp!, {r0-r9, pc}
		
	DisplaySecondaryFirstHourDigit:
		stmfd	sp!, {r0-r9, lr}
		ldr	r7, [r1]
		bl	SplitNumbers
		mov	r2, r8
		mov	r0, #Secondary_First_Hour_Digit_X
		mov	r1, #Secondary_Digits_Y
		swi	Display_Integer
		ldmfd	sp!, {r0-r9, pc}
		
	DisplaySecondarySecondHourDigit:
		stmfd	sp!, {r0-r9, lr}
		ldr	r7, [r1]
		bl	SplitNumbers
		mov	r2, r7
		mov	r0, #Secondary_Second_Hour_Digit_X
		mov	r1, #Secondary_Digits_Y
		swi	Display_Integer
		ldmfd	sp!, {r0-r9, pc}
		
	DisplaySecondaryColonDigit:
		stmfd	sp!, {r0-r9, lr}
		mov	r2, #58	@ :
		mov	r0, #Secondary_Colon_Digit_X
		mov	r1, #Secondary_Digits_Y
		swi	Display_Character
		ldmfd	sp!, {r0-r9, pc}
		
		
	DisplaySecondaryFirstMinuteDigit:
		stmfd	sp!, {r0-r9, lr}
		ldr	r7, [r2]
		bl	SplitNumbers
		mov	r2, r8
		mov	r0, #Secondary_First_Minute_Digit_X
		mov	r1, #Secondary_Digits_Y
		swi	Display_Integer
		ldmfd	sp!, {r0-r9, pc}
	DisplaySecondarySecondMinuteDigit:
		stmfd	sp!, {r0-r9, lr}
		ldr	r7, [r2]
		bl	SplitNumbers
		mov	r2, r7
		mov	r0, #Secondary_Second_Minute_Digit_X
		mov	r1, #Secondary_Digits_Y
		swi	Display_Integer
		ldmfd	sp!, {r0-r9, pc}
		
	DisplaySecondaryAMPM:
		stmfd	sp!, {r0-r9, lr}
		mov	r0, #Secondary_AMPM_X
		mov	r1, #Secondary_AMPM_Y
		bl	DisplayAMPM
		ldmfd	sp!, {r0-r9, pc}
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@	Primary Time Display
@	r1 - Hours Address
@	r2 - Minutes Address
@	r3 - Seconds Address
@	r4 - AMPM Address
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
	DisplayPrimaryTime:
		stmfd	sp!, {r0-r9, lr}
		
		bl	DisplayPrimaryFirstHourDigit
		bl	DisplayPrimarySecondHourDigit
		bl	DisplayPrimaryColonDigit
		bl	DisplayPrimaryFirstMinuteDigit
		bl	DisplayPrimarySecondMinuteDigit
		
		bl	DisplayPrimaryFirstSecondsDigit
		bl	DisplayPrimarySecondSecondsDigit
		
		bl	DisplayPrimaryAMPM
		
		ldmfd	sp!, {r0-r9, pc}
		
	DisplayPrimaryFirstHourDigit:
		stmfd	sp!, {r0-r9, lr}
		ldr	r7, [r1]
		bl	SplitNumbers
		mov	r2, r8
		mov	r0, #First_Hour_Digit_X
		mov	r1, #Digits_Y
		bl	displayNextDigit
		ldmfd	sp!, {r0-r9, pc}
		
	DisplayPrimarySecondHourDigit:
		stmfd	sp!, {r0-r9, lr}
		ldr	r7, [r1]
		bl	SplitNumbers
		mov	r2, r7
		mov	r0, #Second_Hour_Digit_X
		mov	r1, #Digits_Y
		bl	displayNextDigit
		ldmfd	sp!, {r0-r9, pc}
		
	DisplayPrimaryColonDigit:
		stmfd	sp!, {r0-r9, lr}
		mov	r0, #Colon_Digit_X
		mov	r1, #Digits_Y
		bl	DisplayColon
		ldmfd	sp!, {r0-r9, pc}
		
	DisplayPrimaryFirstMinuteDigit:
		stmfd	sp!, {r0-r9, lr}
		ldr	r7, [r2]
		bl	SplitNumbers
		mov	r2, r8
		mov	r0, #First_Minute_Digit_X
		mov	r1, #Digits_Y
		bl	displayNextDigit
		ldmfd	sp!, {r0-r9, pc}
		
	DisplayPrimarySecondMinuteDigit:
		stmfd	sp!, {r0-r9, lr}
		ldr	r7, [r2]
		bl	SplitNumbers
		mov	r2, r7
		mov	r0, #Second_Minute_Digit_X
		mov	r1, #Digits_Y
		bl	displayNextDigit
		ldmfd	sp!, {r0-r9, pc}
	
	DisplayPrimaryFirstSecondsDigit:
		stmfd	sp!, {r0-r9, lr}
		ldr	r7, [r3]
		bl	SplitNumbers
		mov	r2, r8
		mov	r0, #First_Seconds_Digit_X
		mov	r1, #Seconds_Digit_Y
		swi	Display_Integer
		ldmfd	sp!, {r0-r9, pc}
		
	DisplayPrimarySecondSecondsDigit:
		stmfd	sp!, {r0-r9, lr}
		ldr	r7, [r3]
		bl	SplitNumbers
		mov	r2, r7
		mov	r0, #Second_Seconds_Digit_X
		mov	r1, #Seconds_Digit_Y
		swi	Display_Integer
		ldmfd	sp!, {r0-r9, pc}
		
	DisplayPrimaryAMPM:
		stmfd	sp!, {r0-r9, lr}
		mov	r0, #AMPM_X
		mov	r1, #AMPM_Y
		bl	DisplayAMPM
		ldmfd	sp!, {r0-r9, pc}
		
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@

	@ r0 - X
	@ r1 - Y
	@ r3 - AMPM
	@ r4 - AMPM Address
	DisplayAMPM:
		stmfd	sp!, {r0-r8, lr}
		ldr	r3, [r4]
		mov	r5, r0
		bl	GetMaxHours
		ldr	r4, [r0]
		cmp	r4, #12
		bne	printBlank
		cmp	r3, #0
		beq	displayAM
	displayPM:
		ldr	r2, =pm
		b	printAMPM
	displayAM:
		ldr	r2, =am
		b	printAMPM
	printBlank:
		ldr	r2, =blanc
	printAMPM:
		mov	r0, r5
		swi	Display_String
		ldmfd	sp!, {r0-r8, pc}
		
		
	DisplayAlarmStatus:
		stmfd	sp!, {r0-r8, lr}
		bl	GetAlarmStatus
		ldr	r0, [r0]
		cmp	r0, #0
		bne	alarmOff
	alarmOn:
		ldr	r2, =on
		b	displayAlarmStatusInfo
	alarmOff:
		ldr	r2, =off
	displayAlarmStatusInfo:
		mov	r0, #Alarm_Status_X
		mov	r1, #Alarm_Status_Y
		swi	Display_String
		ldmfd	sp!, {r0-r8, pc}
		
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@	For All Digit Values
@	All Digits Are 5 x 3
@	r0	-	X Position To Start At (Left Most Position)
@	r1	-	Y Position To Start At (Top Most Position)
@	r2	-	Number To Print
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
	displayNextDigit:
		stmfd	sp!, {r0-r9, lr}
		cmp	r2, #0
		bleq	DisplayZero
		cmp	r2, #1
		bleq	DisplayOne
		cmp	r2, #2
		bleq	DisplayTwo
		cmp	r2, #3
		bleq	DisplayThree
		cmp	r2, #4
		bleq	DisplayFour
		cmp	r2, #5
		bleq	DisplayFive
		cmp	r2, #6
		bleq	DisplaySix
		cmp	r2, #7
		bleq	DisplaySeven
		cmp	r2, #8
		bleq	DisplayEight
		cmp	r2, #9
		bleq	DisplayNine
		ldmfd	sp!, {r0-r9, pc}


	DisplayColon:
		stmfd	sp!, {r0-r9, lr}
		
		mov	r2, #42
		add	r0, r0, #1
		add	r1, r1, #1
		swi	Display_Character
		add	r1, r1, #2
		swi	Display_Character
		
		
		ldmfd	sp!, {r0-r9, pc}

	DisplayZero:
		stmfd	sp!, {r2,lr}
		ldr	r2, =ZERO
		bl	DisplayNumber
		ldmfd	sp!, {r2, pc}
	
	DisplayOne:
		stmfd	sp!, {r2,lr}
		ldr	r2, =ONE
		bl	DisplayNumber
		ldmfd	sp!, {r2, pc}
		
	DisplayTwo:
		stmfd	sp!, {r2,lr}
		ldr	r2, =TWO
		bl	DisplayNumber
		ldmfd	sp!, {r2, pc}
		
	DisplayThree:
		stmfd	sp!, {r2,lr}
		ldr	r2, =THREE
		bl	DisplayNumber
		ldmfd	sp!, {r2, pc}
		
	DisplayFour:
		stmfd	sp!, {r2,lr}
		ldr	r2, =FOUR
		bl	DisplayNumber
		ldmfd	sp!, {r2, pc}
		
	DisplayFive:
		stmfd	sp!, {r2,lr}
		ldr	r2, =FIVE
		bl	DisplayNumber
		ldmfd	sp!, {r2, pc}
		
	DisplaySix:
		stmfd	sp!, {r2,lr}
		ldr	r2, =SIX
		bl	DisplayNumber
		ldmfd	sp!, {r2, pc}
		
	DisplaySeven:
		stmfd	sp!, {r2,lr}
		ldr	r2, =SEVEN
		bl	DisplayNumber
		ldmfd	sp!, {r2, pc}
		
	DisplayEight:
		stmfd	sp!, {r2,lr}
		ldr	r2, =EIGHT
		bl	DisplayNumber
		ldmfd	sp!, {r2, pc}
		
	DisplayNine:
		stmfd	sp!, {r2,lr}
		ldr	r2, =NINE
		bl	DisplayNumber
		ldmfd	sp!, {r2, pc}
		
		
	DisplayNumber:
		stmfd	sp!, {r1, r3, lr}
		mov	r3, #4
		swi	Display_String	
	numberLoop:
		cmp	r3, #0
		beq	numberExit
		sub	r3, r3, #1
		add	r1, r1, #1
		add	r2, r2, #4
		swi	Display_String
		b	numberLoop
	numberExit:
		ldmfd	sp!, {r1, r3, pc}
		
		
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@


.data	
.align
	ledFlasherState:	.word	0	@ (1 Off  | 0 On)
	setTimeDisplay:		.word 	SEG_A|SEG_G|SEG_F|SEG_C|SEG_D @S
	displayTimeDisplay:	.word 	SEG_A|SEG_B|SEG_C|SEG_D|SEG_E|SEG_G @D
	toggleAlarmDisplay:	.word 	SEG_A|SEG_G|SEG_E @T
	setAlarmDisplay:	.word 	SEG_A|SEG_G|SEG_F|SEG_C|SEG_D|SEG_P @S.
	alarmDisplay:		.word 	SEG_A|SEG_B|SEG_C|SEG_E|SEG_F|SEG_G @A
	
.align	
	ZERO:	.asciz	"000"
		.asciz	"0 0"
		.asciz	"0 0"
		.asciz	"0 0"
		.asciz	"000"
	
.align	
	ONE:	.asciz	"11 "
		.asciz	" 1 "
		.asciz	" 1 "
		.asciz	" 1 "
		.asciz	"111"
	
.align	
	TWO:	.asciz	"222"
		.asciz	"  2"
		.asciz	"222"
		.asciz	"2  "
		.asciz	"222"
	
.align	
	THREE:	.asciz	"333"
		.asciz	"  3"
		.asciz	"333"
		.asciz	"  3"
		.asciz	"333"
	
.align	
	FOUR:	.asciz	"4 4"
		.asciz	"4 4"
		.asciz	"444"
		.asciz	"  4"
		.asciz	"  4"
	
.align	
	FIVE:	.asciz	"555"
		.asciz	"5  "
		.asciz	"555"
		.asciz	"  5"
		.asciz	"555"
	
.align	
	SIX:	.asciz	"66 "
		.asciz	"6  "
		.asciz	"666"
		.asciz	"6 6"
		.asciz	"666"
	
.align	
	SEVEN:	.asciz	"777"
		.asciz	"  7"
		.asciz	"  7"
		.asciz	"  7"
		.asciz	"  7"
	
.align	
	EIGHT:	.asciz	"888"
		.asciz	"8 8"
		.asciz	"888"
		.asciz	"8 8"
		.asciz	"888"
	
.align	
	NINE:	.asciz	"999"
		.asciz	"9 9"
		.asciz	"999"
		.asciz	"  9"
		.asciz	" 99"
			
.align
	setTimeDesc:		.asciz	"Set Time      "
.align	
	setAlarmTimeDesc:	.asciz 	"Set Alarm Time"
.align	
	displayTimeDesc:	.asciz 	"Display Time  "
.align	
	toggleAlarmDesc:	.asciz 	"Toggle Alarm  "
.align	
	alarmDesc:		.asciz 	"Alarm         "
.align	
	toggleTo24Instr:	.asciz 	"Blue 8 - To 24"
.align	
	toggleTo12Instr:	.asciz 	"Blue 8 - To 12"
	
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@	Set Time/Alarm Time Instructions

.align			
	changeTimeInstr:	.asciz	"Blue 0/4 Inc/Dec Hours                  "
				.asciz	"Blue 1/5 - Inc/Dec Minutes              "
				.asciz	"Blue 2/6 - Inc/Dec Seconds              "
				.asciz	"Blue 3/7 - Toggle AM/PM                 "
				.asciz	"Right Button - Display Time             "
@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@	Display Time Instructions

.align	
	displayTimeInstr:	.asciz	"                                        "
				.asciz	"                                        "
				.asciz	"Blue 12 - Set Time                      "
				.asciz	"Blue 13 - Set Alarm Time                "
				.asciz	"Left Button - Toggle Alarm              "
@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@	Alarm Instructions

.align
	alarmInstr:		.asciz	"                                        "
				.asciz	"                                        "
				.asciz	"                                        "
				.asciz	"                                        "
				.asciz	"Right Button - Display Time             "
@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@	
		
.align
	am:			.asciz	"AM"
.align
	pm:			.asciz	"PM"
.align
	blanc:			.asciz	"  "
	
.align
	on:			.asciz	"ALM: ON "
.align
	off:			.asciz	"ALM: OFF"
