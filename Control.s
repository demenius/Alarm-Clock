
.global	SetTime
.global DisplayTime
.global	ToggleAlarm
.global SetAlarmTime
.global Alarm

.global	UpdateTimer
.global	UpdateTimerAlarm
.global	UpdateTimerTogAlarm
.global	UpdateTimerAnimation

.global	SplitNumbers

.global GetMaxHours

.global GetRealHours
.global GetRealMinutes
.global GetRealSeconds
.global GetRealAMPM

.global GetAlarmHours
.global GetAlarmMinutes
.global GetAlarmSeconds
.global GetAlarmAMPM
.global GetAlarmStatus

.global	StartTimerAnimation
.global	StartTimerAlarm			@@@@@@@@@@@@@@@

.equ	Set_Time_State, 0
.equ	Display_Time_State, 1
.equ	Toggle_Alarm_State, 2
.equ	Set_Alarm_Time_State, 3
.equ	Alarm_State, 4

.equ	GetTimer, 0x6d

.equ	Check_Black_Buttons, 0x202
.equ	Right_Button, 10
.equ	Left_Button, 20
.equ	Alarm_Button, 30

.equ	Check_Blue_Buttons, 0x203
.equ	Blue_12, 4096
.equ	Blue_13, 8192

.equ	Blue_0, 1
.equ	Blue_4, 16

.equ	Blue_1, 2
.equ	Blue_5, 32

.equ	Blue_2, 4
.equ	Blue_6, 64

.equ	Blue_3, 8
.equ	Blue_7, 128

.equ	Blue_8, 256

.text
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@	Changes State If Proper Key Pressed
@	r0 - Button
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
	ChangeState:
		stmfd	sp!, {r0-r8, lr}
		
	checkSetTimeState:
		cmp	r9, #Set_Time_State
		bne	checkDisplayTimeState
		bl	changeStateSetTime
		b	exitChangeState
	checkDisplayTimeState:
		cmp	r9, #Display_Time_State
		bne	checkToggleAlarmState
		bl	changeStateDisplayTime
		b	exitChangeState
	checkToggleAlarmState:
		cmp	r9, #Toggle_Alarm_State
		bne	checkSetAlarmTimeState
		bl	changeStateToggleAlarm
		b	exitChangeState
	checkSetAlarmTimeState:
		cmp	r9, #Set_Alarm_Time_State
		bne	checkAlarmState
		bl	changeStateSetAlarmTime
		b	exitChangeState
	checkAlarmState:
		cmp	r9, #Alarm_State
		bl	changeStateAlarm
	exitChangeState:
		ldmfd	sp!, {r0-r8, pc}

	changeStateSetTime:
		stmfd	sp!, {r0-r8, lr}
		bl	changeStateTime
		ldmfd	sp!, {r0-r8, pc}
		
	changeStateSetAlarmTime:
		stmfd	sp!, {r0-r8, lr}
		bl	changeStateTime
		cmp	r8, #0
		bleq	DisplayRealTime
		cmp	r8, #0
		bleq	DisplayAlarmTime
		ldmfd	sp!, {r0-r8, pc}
	
	changeStateTime:
		stmfd	sp!, {r0-r7, lr}
		mov	r8, #1
		cmp	r0, #Right_Button
		bne	exitChangeStateTime
		mov	r9, #Display_Time_State
		bl	StartTimer
		bl	DisplayData
		mov	r8, #0
	exitChangeStateTime:
		ldmfd	sp!, {r0-r7, pc}
		
		
	changeStateDisplayTime:
		stmfd	sp!, {r0-r8, lr}
	checkForSetTimeChange:
		cmp	r0, #Blue_12
		bne	checkForSetAlarmTimeChange
		mov	r9, #Set_Time_State
		bl	DisplayData
		b	exitChangeStateDisplayTime
	checkForSetAlarmTimeChange:
		cmp	r0, #Blue_13
		bne	checkForToggleAlarmChange
		mov	r9, #Set_Alarm_Time_State
		bl	DisplayData
		b	exitChangeStateDisplayTime
	checkForToggleAlarmChange:
		cmp	r0, #Left_Button
		bne	checkForAlarmChange
		mov	r9, #Toggle_Alarm_State
		bl	StartTimerTogAlarm
		bl	ToggleAlarmStatus
		bl	DisplayData
		b	exitChangeStateDisplayTime
	checkForAlarmChange:
		cmp	r0, #Alarm_Button
		bne	exitChangeStateDisplayTime
		mov	r9, #Alarm_State
		bl	StartTimerAlarm
		bl	StartTimerAnimation
		bl	DisplayData
		
	exitChangeStateDisplayTime:
		ldmfd	sp!, {r0-r8, pc}
		
		
	changeStateToggleAlarm:
		stmfd	sp!, {r0-r8, lr}
		cmp	r0, #Right_Button
		bne	exitChangeStateToggleAlarm
		mov	r9, #Display_Time_State
		bl	DisplayData
	exitChangeStateToggleAlarm:
		ldmfd	sp!, {r0-r8, pc}
		
		
	changeStateAlarm:
		stmfd	sp!, {r0-r8, lr}
		cmp	r0, #Right_Button
		bne	exitChangeStateAlarm
		mov	r9, #Display_Time_State
		bl	DisplayData
	exitChangeStateAlarm:
		ldmfd	sp!, {r0-r8, pc}
		
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
	
	ToggleAlarmStatus:
		stmfd	sp!, {r0-r8, lr}
		ldr	r0, =alarmStatus
		ldr	r1, [r0]
		eor	r1, r1, #1
		str	r1, [r0]
		bl	DisplayAlarmStatus
		ldmfd	sp!, {r0-r8, pc}
		

@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@

	SplitNumbers:
		mov	r8, #0
	snLoop:	
		cmp	r7, #10
		blt	snExit
		sub	r7, r7, #10
		add	r8, r8, #1
		b	snLoop
	snExit:		
		mov	pc, lr

@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
	DisplayTime:
		stmfd	sp!, {r0-r8, lr}
		
		bl	checkButtonPressed
		cmp	r0, #0
		beq	checkForAlarm
		
		bl	ChangeState
	checkForAlarm:
		bl	ShouldAlarmGoOff
		cmp	r0, #0
		bne	exitDisplayTime
		mov	r0, #Alarm_Button
		bl	ChangeState
	exitDisplayTime:
		ldmfd	sp!, {r0-r8, pc}
		
		
	ToggleAlarm:
		stmfd	sp!, {r0-r8, lr}
		
		bl	checkButtonPressed
		cmp	r0, #0
		beq	exitToggleAlarm
		
	exitToggleAlarm:
		ldmfd	sp!, {r0-r8, pc}
		
		
	Alarm:
		stmfd	sp!, {r0-r8, lr}
		
		bl	checkButtonPressed
		cmp	r0, #0
		beq	exitAlarm
		
		bl	ChangeState
	exitAlarm:
		ldmfd	sp!, {r0-r8, pc}

		
	SetTime:
		stmfd	sp!, {r0-r8, lr}
		
		bl	checkButtonPressed
		cmp	r0, #0
		beq	exitSetTime
		
		ldr	r1, =realHours
		ldr	r2, =realMin
		ldr	r3, =realSec
		ldr	r4, =realAMPM
		bl	checkTimeChange
		
		bl	ChangeState
	exitSetTime:
		ldmfd	sp!, {r0-r8, pc}
		
	SetAlarmTime:
		stmfd	sp!, {r0-r8, lr}
		
		bl	checkButtonPressed
		cmp	r0, #0
		beq	exitSetAlarmTime
		
		ldr	r1, =alarmHours
		ldr	r2, =alarmMin
		ldr	r3, =alarmSec
		ldr	r4, =alarmAMPM
		bl	checkTimeChange
		
		bl	ChangeState
	exitSetAlarmTime:
		ldmfd	sp!, {r0-r8, pc}
		
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@	
	checkButtonPressed:
		stmfd	sp!, {r1-r8, lr}
		swi	Check_Black_Buttons
		mov	r1, #10
		mul	r0, r1, r0
		cmp	r0, #0
		bne	exitCheckButtonPressed
		swi	Check_Blue_Buttons
		cmp	r0, #Blue_8
		bne	exitCheckButtonPressed
		bl	Toggle12To24
		mov	r0, #0
	exitCheckButtonPressed:
		ldmfd	sp!, {r1-r8, pc}
		
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@	Returns r0 - 0 If Alarm Should Go Off, Else 1
@	Compares AMPM If In 12 Hour Time
@	Then Hours, Then Minutes, Then Seconds
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
	ShouldAlarmGoOff:
		stmfd	sp!, {r1-r8, lr}
		mov	r0, #1
		ldr	r1, =alarmStatus
		ldr	r1, [r1]
		cmp	r1, #0
		bne	exitShouldAlarmGoOff
	checkMaxHours:
		ldr	r1, =maxHours
		ldr	r1, [r1]
		cmp	r1, #12
		bne	checkHours
	checkAMPM:
		ldr	r1, =realAMPM
		ldr	r2, =alarmAMPM
		bl	compareValues
		cmp	r0, #0
		bne	exitShouldAlarmGoOff
	checkHours:
		ldr	r1, =realHours
		ldr	r2, =alarmHours
		bl	compareValues
		cmp	r0, #0
		bne	exitShouldAlarmGoOff
	checkMinutes:
		ldr	r1, =realMin
		ldr	r2, =alarmMin
		bl	compareValues
		cmp	r0, #0
		bne	exitShouldAlarmGoOff
	checkSeconds:
		ldr	r1, =realSec
		ldr	r2, =alarmSec
		bl	compareValues
		cmp	r0, #0
		bne	exitShouldAlarmGoOff
		mov	r0, #0
	exitShouldAlarmGoOff:
		ldmfd	sp!, {r1-r8, pc}
		
	@	cmp r1 & r2
	@	returns r0 - 0 If Equal, Else 1
	compareValues:
		mov	r0, #1
		ldr	r1, [r1]
		ldr	r2, [r2]
		cmp	r1, r2
		bne	exitCompareValues
		mov	r0, #0
	exitCompareValues:
		mov	pc, lr

@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@	Time Change Check
@	r0 - Button
@	r1 - Hours Address
@	r2 - Minutes Address
@	r3 - Seconds Address
@	r4 - AMPM Address
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
	checkTimeChange:
		stmfd	sp!, {r0-r8, lr}
	checkHoursChangeInc:
		cmp	r0, #Blue_0
		bne	checkHoursChangeDec
		mov	r0, #1
		ldr	r7, =minHours
		ldr	r8, =maxHours
		bl	checkTimeChangeWrap
		cmp	r8, #0
		blne	DisplayPrimaryFirstHourDigit
		bl	DisplayPrimarySecondHourDigit
		b	exitCheckTimeChange
	checkHoursChangeDec:
		cmp	r0, #Blue_4
		bne	checkMinutesChangeInc
		mov	r0, #-1
		ldr	r7, =minHours
		ldr	r8, =maxHours
		bl	checkTimeChangeWrap
		cmp	r8, #0
		blne	DisplayPrimaryFirstHourDigit
		bl	DisplayPrimarySecondHourDigit
		b	exitCheckTimeChange
	checkMinutesChangeInc:
		cmp	r0, #Blue_1
		bne	checkMinutesChangeDec
		mov	r0, #1
		mov	r1, r2
		ldr	r7, =minMinSec
		ldr	r8, =maxMinSec
		bl	checkTimeChangeWrap
		cmp	r8, #0
		blne	DisplayPrimaryFirstMinuteDigit
		bl	DisplayPrimarySecondMinuteDigit
		b	exitCheckTimeChange
	checkMinutesChangeDec:
		cmp	r0, #Blue_5
		bne	checkSecondsChangeInc
		mov	r0, #-1
		mov	r1, r2
		ldr	r7, =minMinSec
		ldr	r8, =maxMinSec
		bl	checkTimeChangeWrap
		cmp	r8, #0
		blne	DisplayPrimaryFirstMinuteDigit
		bl	DisplayPrimarySecondMinuteDigit
		b	exitCheckTimeChange
	checkSecondsChangeInc:
		cmp	r0, #Blue_2
		bne	checkSecondsChangeDec
		mov	r0, #1
		mov	r1, r3
		ldr	r7, =minMinSec
		ldr	r8, =maxMinSec
		bl	checkTimeChangeWrap
		cmp	r8, #0
		blne	DisplayPrimaryFirstSecondsDigit
		bl	DisplayPrimarySecondSecondsDigit
		b	exitCheckTimeChange
	checkSecondsChangeDec:
		cmp	r0, #Blue_6
		bne	checkAMPMChangeAM
		mov	r0, #-1
		mov	r1, r3
		ldr	r7, =minMinSec
		ldr	r8, =maxMinSec
		bl	checkTimeChangeWrap
		cmp	r8, #0
		blne	DisplayPrimaryFirstSecondsDigit
		bl	DisplayPrimarySecondSecondsDigit
		b	exitCheckTimeChange
	checkAMPMChangeAM:
		cmp	r0, #Blue_3
		bne	checkAMPMChangePM
		mov	r0, #0
		mov	r1, r4
		bl	changeAMPM
		bl	DisplayPrimaryAMPM
		b	exitCheckTimeChange
	checkAMPMChangePM:
		cmp	r0, #Blue_7
		bne	exitCheckTimeChange
		mov	r0, #1
		mov	r1, r4
		bl	changeAMPM
		bl	DisplayPrimaryAMPM
		
		
	exitCheckTimeChange:
		ldmfd	sp!, {r0-r8, pc}
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
	checkTimeChangeWrap:
		stmfd	sp!, {r1-r7, lr}
		mov	r3, r7
		mov	r4, r8
		ldr	r7, [r1]
		bl	SplitNumbers
		mov	r6, r8
		bl	changeTime
		ldr	r7, [r1]
		bl	SplitNumbers
		sub	r8, r8, r6
		ldmfd	sp!, {r1-r7, pc}

@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@	Time Change
@	Returns r0 - Wrapped (0 - Yes | 1 - No)
@
@		Values Passed
@	r0 - Time To Change By
@	r1 - Time Address
@	r3 - Min Time Address
@	r4 - Max Time Address
@
@		Values Used
@	r2 - Time
@	r7 - Min Time
@	r8 - Max Time
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
	changeTime:
		stmfd	sp!, {r1-r8, lr}
		
		ldr	r2, [r1]
		ldr	r7, [r3]
		ldr	r8, [r4]
		add	r2, r2, r0
		sub	r3, r2, r8
		mov	r0, #1
	changeTimeCheckMaximum:
		cmp	r2, r8
		ble	changeTimeCheckMin
		mov	r0, #0	@Max Hit, Wrap
		cmp	r3, #1
		bgt	changeTimeToMid
		mov	r2, r7	@Change Time To Min Time
		b	exitChangeTime
	changeTimeToMid:
		mov	r2, r3
		b	exitChangeTime
	changeTimeCheckMin:
		cmp	r2, r7
		bge	exitChangeTime
		mov	r2, r8	@Change Time To Max Time
	exitChangeTime:
		str	r2, [r1]
		ldmfd	sp!, {r1-r8, pc}
		
	changeAMPM:
		stmfd	sp!, {r0-r8, lr}
		str	r0, [r1]
		ldmfd	sp!, {r0-r8, pc}
		
		
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@	Time Change
@
@		Values Passed
@	r0 - Time To Change By
@	r1 - Time Address
@	r3 - Min Time Address
@	r4 - Max Time Address
@
@		Values Used
@	r2 - Time
@	r7 - Min Time
@	r8 - Max Time
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
	
	Toggle12To24:
		stmfd	sp!, {r0-r8, lr}
		ldr	r4, =maxHours
		ldr	r3, =minHours
		ldr	r0, [r4]
		cmp	r0, #12
		bne	toggleTo12
	
	toggleTo24:
		mov	r0, #23
		str	r0, [r4]
		mov	r0, #0
		str	r0, [r3]
	@Change Real Time
		ldr	r6, =realAMPM
		ldr	r1, =realHours
		bl	changeTo24
		
	@Change Alarm Time
		ldr	r6, =alarmAMPM
		ldr	r1, =alarmHours
		bl	changeTo24
		
		b	exitToggle12To24
	toggleTo12:
		mov	r0, #12
		str	r0, [r4]
		mov	r0, #1
		str	r0, [r3]
	@Change Real Time
		ldr	r6, =realAMPM
		ldr	r1, =realHours
		bl	changeTo12
		
	@Change Alarm Time
		ldr	r6, =alarmAMPM
		ldr	r1, =alarmHours
		bl	changeTo12
		
	exitToggle12To24:
		bl	DisplayRealFirstHourDigit
		bl	DisplayRealSecondHourDigit
		bl	DisplayRealAMPM
		
		bl	DisplayAlarmFirstHourDigit
		bl	DisplayAlarmSecondHourDigit
		bl	DisplayAlarmAMPM
		
		bl	Display12To24Instructions
		ldmfd	sp!, {r0-r8, pc}
		
		
	changeTo24:
		stmfd	sp!, {r0-r8, lr}
		ldr	r0, [r6]
		cmp	r0, #0	@AM
		beq	check12AM
		ldr	r0, [r1]
		cmp	r0, #12
		beq	exitChangeTo24
		mov	r0, #12
		bl	changeTime
		b	exitChangeTo24
	check12AM:
		ldr	r0, [r1]
		cmp	r0, #12
		bne	exitChangeTo24
		mov	r0, #12
		bl	changeTime
	exitChangeTo24:
		ldmfd	sp!, {r0-r8, pc}
		
		
	changeTo12:
		stmfd	sp!, {r0-r8, lr}
		mov	r5, #0	@AM
		str	r5, [r6]
		ldr	r5, [r1]
		cmp	r5, #0
		bne	check12PM
	@00:00 To 12AM
		mov	r0, #12
		bl	changeTime
		b	exitChangeTo12
	check12PM:
		cmp	r5, #12
		bne	change12Hour
		mov	r5, #1	@PM
		str	r5, [r6]
	change12Hour:
		mov	r0, #0
		bl	changeTime
		cmp	r0, #0
		bne	exitChangeTo12
		mov	r5, #1	@PM
		str	r5, [r6]
		
	exitChangeTo12:
		ldmfd	sp!, {r0-r8, pc}

@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@	TIME CHANGER
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@

	ChangeRealSeconds:
		stmfd	sp!, {r0-r9, lr}
		mov	r0, #1
		ldr	r1, =realSec
		ldr	r7, =minMinSec
		ldr	r8, =maxMinSec
		bl	checkTimeChangeWrap
		cmp	r8, #0
		ldr	r3, =realSec
		blne	DisplayRealFirstSecondsDigit
		bl	DisplayRealSecondSecondsDigit
		cmp	r0, #0
		bleq	ChangeRealMinutes
		ldmfd	sp!, {r0-r9, pc}
		
	ChangeRealMinutes:
		stmfd	sp!, {r0-r9, lr}
		mov	r0, #1
		ldr	r1, =realMin
		ldr	r7, =minMinSec
		ldr	r8, =maxMinSec
		bl	checkTimeChangeWrap
		cmp	r8, #0
		ldr	r2, =realMin
		blne	DisplayRealFirstMinuteDigit
		bl	DisplayRealSecondMinuteDigit
		cmp	r0, #0
		bleq	ChangeRealHours
		
		ldmfd	sp!, {r0-r9, pc}
		
	ChangeRealHours:
		stmfd	sp!, {r0-r9, lr}
		mov	r0, #1
		ldr	r1, =realHours
		ldr	r7, =minHours
		ldr	r8, =maxHours
		bl	checkTimeChangeWrap
		cmp	r8, #0
		ldr	r1, =realHours
		blne	DisplayRealFirstHourDigit
		bl	DisplayRealSecondHourDigit
		bl	getRealHourWrap
		cmp	r0, #0
		bleq	ChangeRealAMPM
		
		ldmfd	sp!, {r0-r9, pc}
		
	ChangeRealAMPM:
		stmfd	sp!, {r0-r9, lr}
		ldr	r1, =realAMPM
		ldr	r0, [r1]
		eor	r0, r0, #1
		bl	changeAMPM
		bl	DisplayRealAMPM
		ldmfd	sp!, {r0-r9, pc}
		
	getRealHourWrap:
		ldr	r0, =realHours
		ldr	r0, [r0]
		ldr	r1, =maxHours
		ldr	r1, [r1]
		cmp	r1, #12
		bne	exitGetRealHourWrap
		cmp	r0, r1
		bne	exitGetRealHourWrap
		mov	r0, #0
	exitGetRealHourWrap:
		mov	pc, lr
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@	TIMER STARTER
@	r1 - last timer tick (Address)
@	r2 - time passed (Address)
@	r3 - max time (Address)
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
	StartTimer:
		stmfd	sp!, {r0-r4, lr}
		ldr	r1, =lastTimerTick
		ldr	r2, =timePassed
		bl	startTickTimer
		ldmfd	sp!, {r0-r4, pc}

	StartTimerAlarm:
		stmfd	sp!, {r0-r4, lr}
		ldr	r1, =lastTimerTickAlarm
		ldr	r2, =timePassedAlarm
		bl	startTickTimer
		ldmfd	sp!, {r0-r4, pc}
	StartTimerTogAlarm:
		stmfd	sp!, {r0-r4, lr}
		ldr	r1, =lastTimerTickTogAlarm
		ldr	r2, =timePassedTogAlarm
		bl	startTickTimer
		ldmfd	sp!, {r0-r4, pc}
		
	StartTimerAnimation:
		stmfd	sp!, {r0-r4, lr}
		ldr	r1, =lastTimerTickAnimation
		ldr	r2, =timePassedAnimation
		bl	startTickTimer
		ldmfd	sp!, {r0-r4, pc}

	startTickTimer:
		swi	GetTimer
		ldr	r4, =0x00007FFF @15-bit mask
		and	r0, r0, r4	@adjust to 15-bits
		str	r0, [r1]
		mov	r0, #0
		str	r0, [r2]
		mov	pc, lr

@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@	TIMER UPDATER
@	r0 - returns 0 if over max ticks / 1 if under
@	r0 - current tick
@	r1 - last timer tick (Address)
@	r2 - max time (Address)
@	r3 - time passed (Address)
@	r4 - 15 bit mask
@	r5 - last timer tick
@	r6 - max time
@	r7 - time passed
@	r8 - elapsed ticks
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
	UpdateTimer:
		stmfd	sp!, {r0-r8, lr}
		ldr	r1, =lastTimerTick
		ldr	r2, =maxTime
		ldr	r3, =timePassed
		bl	updateTickTimer
		
		cmp	r0, #0
		mov	r1, #0
		mov	r2, #1
		bleq	ChangeRealSeconds
		
		ldmfd	sp!, {r0-r8, pc}
		
	UpdateTimerAlarm:
		stmfd	sp!, {r0-r8, lr}
		ldr	r1, =lastTimerTickAlarm
		ldr	r2, =maxTimeAlarm
		ldr	r3, =timePassedAlarm
		bl	updateTickTimer
		
		cmp	r0, #0
		bne	exitUTA
		mov	r0, #Right_Button
		bl	ChangeState
	exitUTA:
		ldmfd	sp!, {r0-r8, pc}
		
	UpdateTimerTogAlarm:
		stmfd	sp!, {r0-r8, lr}
		ldr	r1, =lastTimerTickTogAlarm
		ldr	r2, =maxTimeTogAlarm
		ldr	r3, =timePassedTogAlarm
		bl	updateTickTimer
		
		cmp	r0, #0
		bne	exitUTTA
		mov	r0, #Right_Button
		bl	ChangeState
	exitUTTA:
		ldmfd	sp!, {r0-r8, pc}
		
	UpdateTimerAnimation:
		stmfd	sp!, {r0-r8, lr}
		ldr	r1, =lastTimerTickAnimation
		ldr	r2, =maxTimeAnimation
		ldr	r3, =timePassedAnimation
		bl	updateTickTimer
		
		cmp	r0, #0
		bne	exitUTAnim
		bl	DisplayAnimation
		bl	FlashLED
	exitUTAnim:
		ldmfd	sp!, {r0-r8, pc}

	
	@	Returns r0 - 0 Max Time Hit
	@	r0 - Current Time
	@	r1 - LastTick Address
	@	r2 - MaxTime Address
	@	r3 - TimePassed Address
	@	r4 - 15-bit Mask
	@	r5 - LastTicks
	@	r6 - MaxTime
	@	r7 - TimePassed
	@	r8 - Elapsed Time
	updateTickTimer:
		stmfd	sp!, {r1-r8, lr}
		swi	GetTimer	@ puts time in r0
		ldr	r5, [r1]
		ldr	r6, [r2]
		ldr	r7, [r3]
		ldr	r4, =0x00007FFF @15-bit mask
		and	r0, r0, r4	@adjust to 15-bits
		
		cmp	r0, r5
		blt	roll
		sub	r8, r0, r5
		b	checkTicks
	roll:
		sub	r8, r4, r5
		add	r8, r8, r0
	checkTicks:
		str	r0, [r1]
		
		add	r8, r8, r7
		cmp	r8, r6
		mov	r0, #1
		blt	exitUpdate
		mov	r0, #0
		sub	r8, r8, r6
	exitUpdate:
		str	r8, [r3]
		ldmfd	sp!, {r1-r8, pc}

@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
	GetMaxHours:
		ldr	r0, =maxHours
		mov	pc, lr
		
	GetRealHours:
		ldr	r0, =realHours
		mov	pc, lr
		
	GetRealMinutes:
		ldr	r0, =realMin
		mov	pc, lr
		
	GetRealSeconds:
		ldr	r0, =realSec
		mov	pc, lr
		
	GetRealAMPM:
		ldr	r0, =realAMPM
		mov	pc, lr
		
	GetAlarmHours:
		ldr	r0, =alarmHours
		mov	pc, lr
		
	GetAlarmMinutes:
		ldr	r0, =alarmMin
		mov	pc, lr
		
	GetAlarmSeconds:
		ldr	r0, =alarmSec
		mov	pc, lr
		
	GetAlarmAMPM:
		ldr	r0, =alarmAMPM
		mov	pc, lr
		
	GetAlarmStatus:
		ldr	r0, =alarmStatus
		mov	pc, lr
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
		
.data
.align
	
	alarmStatus:		.word	1	@( 0 - ON / 1 - OFF )

@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@	Time Data
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@

	maxHours:		.word	12
	minHours:		.word	1
	maxMinSec:		.word	59
	minMinSec:		.word	0
	
	realHours:		.word	12
	realMin:		.word	00
	realSec:		.word	00
	realAMPM:		.word	0	@( 0 - AM  /  1 - PM )
	
	alarmHours:		.word	12
	alarmMin:		.word	00
	alarmSec:		.word	00
	alarmAMPM:		.word	0	@( 0 - AM  /  1 - PM )
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@	Timer Data
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@

	lastTimerTickAnimation:	.word	0
	timePassedAnimation:	.word 	0
	maxTimeAnimation:	.word	500

	lastTimerTick:		.word	0
	timePassed:		.word 	0
	maxTime:		.word	1000
	
	lastTimerTickAlarm:	.word	0
	timePassedAlarm:	.word 	0
	maxTimeAlarm:		.word	120000
	
	lastTimerTickTogAlarm:	.word	0
	timePassedTogAlarm:	.word 	0
	maxTimeTogAlarm:	.word	3000
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
.end
