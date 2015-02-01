
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@	r0-r2	- Use Only For Swi Commands
@	r3-r8	- Open For Any Use
@	r9 	- State
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@

.equ	Set_Time_State, 0
.equ	Display_Time_State, 1
.equ	Toggle_Alarm_State, 2
.equ	Set_Alarm_Time_State, 3
.equ	Alarm_State, 4


.text
.global _start

	_start:
		bl	INIT
	run:
		cmp	r9, #Set_Time_State
		bleq	SetTime
		cmp	r9, #Display_Time_State
		bleq	DisplayTime
		cmp	r9, #Toggle_Alarm_State
		bleq	ToggleAlarm
		cmp	r9, #Set_Alarm_Time_State
		bleq	SetAlarmTime
		cmp	r9, #Alarm_State
		bleq	Alarm
		
		cmp	r9, #Set_Time_State
		blne	UpdateTimer
		
		cmp	r9, #Toggle_Alarm_State
		bleq	UpdateTimerTogAlarm
		
		cmp	r9, #Alarm_State
		bleq	UpdateTimerAlarm
		cmp	r9, #Alarm_State
		bleq	UpdateTimerAnimation
		
		b	run
		swi	0x11
		
	
	INIT:
		stmfd	sp!, {lr}
		@bl	StartTimerAlarm
		@bl	StartTimerAnimation
		@mov	r9, #Alarm_State
		mov	r9, #Set_Time_State
		bl	DisplayData
		ldmfd	sp!, {pc}
		
.end
