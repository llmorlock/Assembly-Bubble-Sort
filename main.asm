;-------------------------------------------------------------------------------
; MSP430 Assembler Code Template for use with TI Code Composer Studio
;
;
;-------------------------------------------------------------------------------
            .cdecls C,LIST,"msp430.h"       ; Include device header file
            
;-------------------------------------------------------------------------------
            .def    RESET                   ; Export program entry-point to
                                            ; make it known to linker.
;-------------------------------------------------------------------------------
            .text                           ; Assemble into program memory.
            .retain                         ; Override ELF conditional linking
                                            ; and retain current section.
            .retainrefs                     ; And retain any sections that have
                                            ; references to current section.

;-------------------------------------------------------------------------------
;Memory allocation of Arrays must be done before the RESET and Stop WDT
ARY1 		.set 	0x0200					;Memory allocation ARY1
ARY1S 		.set 	0x0210 					;Memory allocation ARYS
ARY2 		.set 	0x0220 					;Memory allocation ARY2
ARY2S 		.set	0x0230 					;Memory allocation AR2S
RESET       mov.w   #__STACK_END,SP         ; Initialize stackpointer
StopWDT     mov.w   #WDTPW|WDTHOLD,&WDTCTL  ; Stop watchdog timer


;-------------------------------------------------------------------------------
; Main loop here
;-------------------------------------------------------------------------------
BEGIN		clr 	R4 				;clearing all register being use is a good
			clr 	R5 				;programming practice
			clr 	R6

SORT1 		mov.w 	#ARY1, R4 		;initialize R4 as a pointer to array1
 			mov.w 	#ARY1S, R6 		;initialize R6 as a pointer to array1 sorted
 			call 	#ArraySetup1	;then call subroutine ArraySetup1
 			call 	#COPY 			;Copy elements from ARY1 to ARY1S space
 			call 	#SORT 			;Sort elements in ARAY1

SORT2		mov.w 	#ARY2, R4 		;initialize R4 as a pointer to array2
			mov.w 	#ARY2S, R6 		;initialize R6 as a pointer to array2 sorted
 			call 	#ArraySetup2	;then call subroutine ArraySetup2
 			call 	#COPY 			;Copy elements from ARY2 to ARY2S space
 			call 	#SORT 			;Sort elements in ARAY2

Mainloop 	jmp 	Mainloop 		;Infinite Loop


ArraySetup1 mov.b 	#10, 0(R4) 		; Array element initialization Subroutine
 			mov.b 	#45, 1(R4) 		;First start with the number of elements
 			mov.b 	#-23, 2(R4) 	;and then fill in the 10 elements.
 			mov.b 	#-78, 3(R4)
 			mov.b 	#32, 4(R4)
 			mov.b 	#89, 5(R4)
 			mov.b 	#-19, 6(R4)
 			mov.b 	#-99, 7(R4)
 			mov.b 	#73, 8(R4)
 			mov.b 	#-18, 9(R4)
 			mov.b 	#56, 10(R4)
			ret

ArraySetup2 mov.b 	#10, 0(R4) 		;Similar to ArraySetup1 subroutine
			mov.b 	#22, 1(R4)
			mov.b 	#45, 2(R4)
			mov.b 	#21, 3(R4)
 			mov.b 	#-39, 4(R4)
 			mov.b 	#-63, 5(R4)
 			mov.b 	#69, 6(R4)
 			mov.b 	#72, 7(R4)
 			mov.b 	#41, 8(R4)
 			mov.b 	#28, 9(R4)
 			mov.b 	#-28, 10(R4)
 			ret

COPY		mov.b	0(R4), R10		;save n (number of elements) in R10
			inc.b	R10				;increment by 1 to account for the byte n to be copied as well
			mov.w	R4, R5			;copy R4 to R5 so we keep R4 unchanged for later use
			mov.w	R6, R7			;copy R6 to R7 so we keep R6 unchanged for later use
LP			mov.b	@R5+, 0(R7)		;copy elements using R5/R7 as pointers
			inc.w 	R7
			dec		R10
			jnz		LP
			ret

;Subroutine SORT sorts array from lowest to highest value
SORT 		clr		R7				;clear registers to be used for new purposes
			clr		R8
			clr		R9
			clr		R10
			mov.b	@R6, R8			;copy n to R8 (R8 is outer loop counter)

OUTER		dec.b	R8				;decrement R8, will scan (n-1) times
			jz		DONE			;if outer loop fully decremented, return
			mov.b	R8, R9			;copy outer loop value to inner loop (R9 is inner loop counter)
			mov.w	R6, R7			;R7 points to n, R6 is preserved

INNER		inc		R7				;R7 points to next loop element
			cmp.b	@R7, 1(R7)		;DST - SRC
			jge		NOSWAP			;if DST > SRC, do not swap
			mov.b	@R7, R10		;else swap (R10 is a temporary holder)
			mov.b	1(R7), 0(R7)
			mov.b	R10, 1(R7)

NOSWAP		dec.b	R9				;decrement inner loop counter
			jz		OUTER			;if ==0, jump to outer loop
			jmp		INNER			;else repeat inner loop

DONE		ret

;-------------------------------------------------------------------------------
; Stack Pointer definition
;-------------------------------------------------------------------------------
            .global __STACK_END
            .sect   .stack
            
;-------------------------------------------------------------------------------
; Interrupt Vectors
;-------------------------------------------------------------------------------
            .sect   ".reset"                ; MSP430 RESET Vector
            .short  RESET
            
