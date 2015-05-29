*----------------------------------------------------------------------------------------------------
* Title      : OP-CODE PROGRAM
* Written by : KUNLAKAN (JEEN) CHERDCHUSILP
* Date       : 
* Description: CSS422 DISASSEMBLR GROUP PROJECT
*----------------------------------------------------------------------------------------------------
                ORG         $1000
    
START:          MOVE.L      #$7000, A6      ;THESE ARE FOR TESTING! (NEED TO BE REMOVED AFTER DONE)
                MOVE.L      #$5B40, (A6)
                MOVEA.L     #$10000, A2
                
*----------------------------------------------------------------------------------------------------
* DISASSEMBLE: DISASSEMBLE HEXADECIMAL INSTRUCTION CODE TO MNEMONIC INSTRUCTION
* PRECONDITION: - D2 AND D3 MUST NOT BE IN USED
*				- A2 STORES AN APPROPRIATE MEMORY REGION ADDRESS
*               - A6 STORES AN APPROPRIATE STARTING ADDRESS
* POSTCONDITION: - IF THE INSTRUCTION IS DEFINED IN THE REQUIREMENT, THE STRING OF THE RESULT WILL BE
*                  STORED IN OUTPUT MEMORY REGION POINTED BY A2
*                - IF THE INSTRUCTION IS NOT IN THE REQUIREMENT, FOR NOW IT WILL BE IGNORED
*----------------------------------------------------------------------------------------------------

DISASSEMBLE     MOVE.W      (A6), D2        ;RETRIEVE ORIGINAL INSTRUCTION TO D2 (NO CHANGE ALLOWED)
                MOVE.W      D2, D3          ;COPY ORIGINAL INSTRUCTION TO D3 (CHANGE ALLOW)

                MOVE.L      A6, (A2)+       ;STORE THE ADDRESS OF THE INSTRUCTION
                MOVE.B      #TAB, (A2)+      ;STORE A TAB AFTER THE ADDRESS

                LSR         #8, D3          ;GET THE FIRST 4 BITS
                LSR         #4, D3

                MULU        #6, D3
                LEA         MAINTABLE, A3   ;LOAD INDEX INTO THE TABLE
                JSR         0(A3, D3)       ;JUMP INDIRECT WITH INDEX

                RTS                         ;FINISH DIASSEMBLING
                                
*----------------------------------------------------------------------------------------------------
* MAINTABLE: THIS IS A PRIMARY JUMP TABLE FOR DETERMINING TYPES OF OPCODES INSTRUCTION BY LOOKING  AT
*            THE FIRST 4 BITS IN THE HEXADECIMAL INSTRUCTION 
*----------------------------------------------------------------------------------------------------
MAINTABLE       JMP         CODE0000
                JMP         CODE0001
                JMP         CODE0010
                JMP         CODE0011
                JMP         CODE0100
                JMP         CODE0101
                JMP         CODE0110
				JMP         CODE0111
                JMP         CODE1000
                JMP         CODE1001
				JMP         CODE1010
                JMP         CODE1011
                JMP         CODE1100
                JMP         CODE1101
                JMP         CODE1110
				JMP         CODE1111
FINISH          RTS

*----------------------------------------------------------------------------------------------------
* CODE0000: DISASSEMBLE THE HEXADECIMAL INSTRUCTION STARTING WITH 0000 INTO BCLR, ORI, OR CMPI
*           INSTRUCTION
*----------------------------------------------------------------------------------------------------
CODE0000        MOVE.L      D2, D3
                LSL.L       #7, D3          ;SHIFT BITS TO GET THE 8TH BIT
                LSR.L       #8, D3
                LSR.L       #7, D3

                CMPI.B      #%1, D3         ;CHECK IF THE 8TH BIT IS EQUAL TO 1
                BEQ         IFBCLR_DN       ;IF IT IS EQUAL, THE INSTRUCTION IS "BCLR DN, <EA>"

                LSL.L       #4, D3          ;IF NOT, SHIFT BITS TO GET BIT 11, 10, AND 9 FOR FUTHER
                LSR.L       #8, D3          ;DISASSEMBLING
                LSR.L       #5, D3
                MULU        #6, D3
                LEA         TABLEZERO, A3   ;LOAD INDEX INTO THE TABLE
                JSR         0(A3, D3)       ;JUMP INDIRECT WITH INDEX
RETURN0000      BRA         FINISH


IFBCLR_DN       MOVE.L      D2, D3
                LSL.L       #7, D3          ;SHIFT BITS TO GET BIT 8, 7 AND 6
                LSR.L       #8, D3
                LSR.L       #5, D3
                CMPI.B      #%110, D3       ;CHECK IF THE INSTRUCTION IS ACTUALLY "BCLR DN, <EA>"
                BNE         INVALID_OPCODE  ;IF IT IS NOT, THEN THE OPCODE IS NOT DEFINED
                MOVE.B      #'B', (A2)+     ;OTHERWISE, IT IS ACTUALLY "BCLR DN, <EA>"
                MOVE.B      #'C', (A2)+
                MOVE.B      #'L', (A2)+
                MOVE.B      #'R', (A2)+
                MOVE.B      #TAB, (A2)+
                ;JSR         ISBCLR_DN
                BRA         RETURN0000

*----------------------------------------------------------------------------------------------------
* CODE0001: DISASSEMBLE THE HEXADECIMAL INSTRUCTION STARTING WITH 0001 INTO MOVE.B INSTRUCTION
*----------------------------------------------------------------------------------------------------
CODE0001        MOVE.B      #'M', (A2)+     ;THE INSTRUCTION IS MOVE.B
                MOVE.B      #'O', (A2)+
                MOVE.B      #'V', (A2)+
                MOVE.B      #'E', (A2)+
                MOVE.B      #'.', (A2)+
                MOVE.B      #'B', (A2)+
                MOVE.B      #TAB, (A2)+
                ;JSR         ISMOVEB        ;CALL ISMOVEB TO DISASSEMBLE EFFECTIVE ADDRESS
                BRA         FINISH
           
*----------------------------------------------------------------------------------------------------
* CODE0010: DISASSEMBLE THE HEXADECIMAL INSTRUCTION STARTING WITH 0010 INTO MOVE.L OR MOVEA.L
*           INSTRUCTION
*----------------------------------------------------------------------------------------------------
CODE0010        MOVE.B      #'M', (A2)+
                MOVE.B      #'O', (A2)+
                MOVE.B      #'V', (A2)+
                MOVE.B      #'E', (A2)+
                JSR         IFMOVEA
IFMOVEL         MOVE.B      #'.', (A2)+
                MOVE.B      #'L', (A2)+
                MOVE.B      #TAB, (A2)+
                ;JSR         ISMOVEL
                BRA         FINISH
          
IFMOVEA         MOVE.L      D2, D3          ;MAKE A COPY OF ORIGINAL INSTRUCTION TO D3
                LSL.L       #7, D3          ;SHIFT BITS TO GET BIT 8, 7 AND 6
                LSR.L       #8, D3
                LSR.L       #5, D3
                CMPI.W      #%001, D3       ;CHECK IF THIS INSTRUCTION IS MOVEA
                BNE         IFMOVEL         ;IF THE INSTRUCTION IS NOT MOVEA, IT MUST BE MOVE
                MOVE.B      #'A',(A2)+      ;OTHERWISE, IT IS MOVEA.
                RTS

*----------------------------------------------------------------------------------------------------
* CODE0011: DISASSEMBLE THE HEXADECIMAL INSTRUCTION STARTING WITH 0011 INTO MOVE.W OR MOVEA.W
*           INSTRUCTION
*----------------------------------------------------------------------------------------------------
CODE0011        MOVE.B      #'M', (A2)+
                MOVE.B      #'O', (A2)+
                MOVE.B      #'V', (A2)+
                MOVE.B      #'E', (A2)+
                JSR         IFMOVEA
IFMOVEW         MOVE.B      #'.', (A2)+
                MOVE.B      #'W', (A2)+
                MOVE.B      #TAB, (A2)+
                ;JSR         ISMOVEB
                BRA         FINISH

*----------------------------------------------------------------------------------------------------
* CODE0100: DISASSEMBLE THE HEXADECIMAL INSTRUCTION STARTING WITH 0100 INTO MOVEM, DIVS, LEA, NEG,
*           JSR, OR RTS INSTRUCTION
*----------------------------------------------------------------------------------------------------
CODE0100        MOVE.L      D2, D3
                LSL.L       #7, D3          ;SHIFT BITS TO GET THE 8TH BIT
                LSR.L       #8, D3
                LSR.L       #7, D3

                CMPI.B      #%1, D3         ;CHECK IF THE 8TH BIT IS EQUAL TO 1
                BEQ         ISLEA             ;IF IT IS EQUAL, THE INSTRUCTION IS "LEA"

                LSL.L       #4, D3          ;IF NOT, SHIFT BITS TO GET BIT 11, 10, AND 9 FOR FUTHER
                LSR.L       #8, D3          ;DISASSEMBLING
                LSR.L       #5, D3
                MULU        #6, D3
                LEA         TABLEFOUR, A3   ;LOAD INDEX INTO THE TABLE
                JSR         0(A3, D3)       ;JUMP INDIRECT WITH INDEX
RETURN0100      BRA         FINISH


IFLEA           MOVE.L      D2, D3
                LSL.L       #7, D3          ;SHIFT BITS TO GET BIT 8, 7 AND 6
                LSR.L       #8, D3
                LSR.L       #5, D3
                CMPI.B      #%111, D3       ;CHECK IF THE INSTRUCTION IS ACTUALLY "LEA"
                BNE         INVALID_OPCODE  ;IF IT IS NOT, THEN THE OPCODE IS NOT DEFINED
                MOVE.B      #'L', (A2)+     ;OTHERWISE, IT IS ACTUALLY "LEA"
                MOVE.B      #'E', (A2)+
                MOVE.B      #'A', (A2)+
                MOVE.B      #TAB, (A2)+
                ;JSR         ISLEA
                BRA         RETURN0100

*----------------------------------------------------------------------------------------------------
* CODE0101: DISASSEMBLE THE HEXADECIMAL INSTRUCTION STARTING WITH 0101 INTO SUBQ INSTRUCTION
*----------------------------------------------------------------------------------------------------
CODE0101        MOVE.B      #'S', (A2)+
                MOVE.B      #'U', (A2)+
                MOVE.B      #'B', (A2)+
                MOVE.B      #'Q', (A2)+
                MOVE.B      #'.', (A2)+
                JSR         GET_SIZE
                MOVE.B      #TAB, (A2)+
                ;JSR         EASUBQ
                BRA         FINISH

*----------------------------------------------------------------------------------------------------
* CODE0110: DISASSEMBLE THE HEXADECIMAL INSTRUCTION STARTING WITH 0110 INTO OR BCC, BCS, BGE, BLT,
*	    BVC, OR BRA INSTRUCTION
*----------------------------------------------------------------------------------------------------
CODE0110        MOVE.L      D2, D3          ;MAKE A COPY OF INSTRUCTION TO D3
                LSL.L       #4, D3          ;SHIFT BITS TO GET BIT 11 TO 8
                LSR.L       #8, D3
                LSR.L       #4, D3

                MULU        #6, D3
                LEA         TABLESIX, A3
                JSR         0(A3, D3)
                BRA         FINISH

*----------------------------------------------------------------------------------------------------
* CODE0111: HEXADECIMAL INSTRUCTION STARTING WITH 0111 IS NOT DEFINED
*----------------------------------------------------------------------------------------------------
CODE0111		BNE         INVALID_OPCODE  ;THE OPCODE IS NOT DEFINED
                RTS

*----------------------------------------------------------------------------------------------------
* CODE1000: DISASSEMBLE THE HEXADECIMAL INSTRUCTION STARTING WITH 1000 INTO OR INSTRUCTION
*----------------------------------------------------------------------------------------------------
CODE1000        MOVE.W      D2, D3          ;MAKE A COPY OF ORIGINAL INSTRUCTION TO D3
                LSL.L       #7, D3          ;SHIFT BITS TO GET BIT 8, 7, AND 6
                LSR.L       #8, D3
                LSR.L       #5, D3
                CMPI.W      #%111, D3       ;CHECK IF THIS INSTRUCTION IS DIVS
                BEQ         IFDIVS
                BRA         IFOR
RETURN1000      BRA         FINISH


IFDIVS          MOVE.B      #'D', (A2)+
                MOVE.B      #'I', (A2)+
                MOVE.B      #'V', (A2)+
                MOVE.B      #'S', (A2)+
                MOVE.B      #TAB, (A2)+
                ;JSR        ISDIVS
                BRA         RETURN1000

IFOR            MOVE.B      #'O', (A2)+
                MOVE.B      #'R', (A2)+
                MOVE.B      #'.', (A2)+
                JSR         GET_OPMODE
                MOVE.B      #TAB, (A2)+
                ;JSR        ISOR
                BRA         RETURN1000


*----------------------------------------------------------------------------------------------------
* CODE1001: DISASSEMBLE THE HEXADECIMAL INSTRUCTION STARTING WITH 1001 INTO SUB INSTRUCTION
*----------------------------------------------------------------------------------------------------
CODE1001        MOVE.B      #'S', (A2)+
                MOVE.B      #'U', (A2)+
                MOVE.B      #'B', (A2)+
                MOVE.B      #'.', (A2)+
                JSR         GET_OPMODE
                MOVE.B      #TAB, (A2)+
                ;JSR        ISSUB      
                BRA         FINISH

*----------------------------------------------------------------------------------------------------
* CODE1010: HEXADECIMAL INSTRUCTION STARTING WITH 1010 IS NOT DEFINED
*----------------------------------------------------------------------------------------------------
CODE1010		BNE         INVALID_OPCODE  ;THE OPCODE IS NOT DEFINED
                BRA         FINISH

*----------------------------------------------------------------------------------------------------
* CODE1011: DISASSEMBLE THE HEXADECIMAL INSTRUCTION STARTING WITH 1011 INTO EOR OR CMP INSTRUCTION
*----------------------------------------------------------------------------------------------------
CODE1011		MOVE.L      D2, D3          ;MAKE A COPY OF INSTRUCTION TO D3
                LSL.L       #7, D3          ;SHIFT BITS TO GET BIT 8, 7, AND 6
                LSR.L       #8, D3
                LSR.L       #5, D3

                MULU        #6, D3
                LEA         TABLEELEVEN, A3
                JSR         0(A3, D3)
                BRA         FINISH

*----------------------------------------------------------------------------------------------------
* CODE1100: DISASSEMBLE THE HEXADECIMAL INSTRUCTION STARTING WITH 1100 INTO MULS INSTRUCTION
*----------------------------------------------------------------------------------------------------
CODE1100        MOVE.W      D2, D3          ;MAKE A COPY OF ORIGINAL INSTRUCTION TO D3
                LSL.L       #7, D3          ;SHIFT BITS TO GET BIT 8, 7, AND 6
                LSR.L       #8, D3
                LSR.L       #5, D3
                CMPI.W      #%111, D3       ;CHECK IF THIS INSTRUCTION IS MULS
                BNE         INVALID_OPCODE
                MOVE.B      #'M', (A2)+
                MOVE.B      #'U', (A2)+
                MOVE.B      #'L', (A2)+
                MOVE.B      #'S', (A2)+
                ;JSR         ISMULS
                BRA         FINISH


*----------------------------------------------------------------------------------------------------
* CODE1101: DISASSEMBLE THE HEXADECIMAL INSTRUCTION STARTING WITH 1101 INTO ADDA INSTRUCTION
*----------------------------------------------------------------------------------------------------
CODE1101		MOVE.B		#'A', (A2)+
				MOVE.B		#'D', (A2)+
				MOVE.B		#'D', (A2)+

                LSL.L       #7, D3          ;SHIFT BITS TO GET BIT 8, 7, AND 6
                LSR.L       #8, D3
                LSR.L       #5, D3

                MULU        #6, D3
                LEA         TABLETHIRTEEN, A3
                JSR         0(A3, D3)

                MOVE.B      #TAB, (A2)+

                BRA         FINISH

*----------------------------------------------------------------------------------------------------
* CODE1110: DISASSEMBLE THE HEXADECIMAL INSTRUCTION STARTING WITH 1110 INTO LSR, LSL, ASR, ASL, ROL,
*           OR ROR INSTRUCTION
*----------------------------------------------------------------------------------------------------
CODE1110
; LSR
; LSL
; ASR
; ASL
; ROL
; ROR

TABLEFOURTEEN
*----------------------------------------------------------------------------------------------------
* CODE1111: HEXADECIMAL INSTRUCTION STARTING WITH 1111 IS NOT DEFINED
*----------------------------------------------------------------------------------------------------
CODE1111		BNE         INVALID_OPCODE  ;THE OPCODE IS NOT DEFINED
                RTS



*----------------------------------------------------------------------------------------------------
* TABLEZERO: THIS IS FUNCTION FOR DETERMINING OPMODE OF THE HEXADECIMAL INSTRUCTION THAT STARED WITH
*            0000
*----------------------------------------------------------------------------------------------------
TABLEZERO       JMP         ZERO000
                JMP         ZERO001
                JMP         ZERO010
                JMP         ZERO011
                JMP         ZERO100
                JMP         ZERO101
                JMP         ZERO110
                JMP         ZERO111
RETURN_ZERO     RTS

            
ZERO000         MOVE.B      #'O', (A2)+
                MOVE.B      #'R', (A2)+
                MOVE.B      #'I', (A2)+
                MOVE.B      #'.', (A2)+
                JSR         GET_SIZE
                MOVE.B      #TAB, (A2)+
                ;JSR         ISORI
                BRA         RETURN_ZERO


ZERO001         JSR         INVALID_OPCODE
                BRA         RETURN_ZERO

ZERO010         JSR         INVALID_OPCODE
                BRA         RETURN_ZERO


ZERO011         JSR         INVALID_OPCODE
                BRA         RETURN_ZERO


ZERO100         MOVE.W      D2, D3
                LSL.L       #7, D3          ;SHIFT BITS TO GET BIT 8, 7 AND 6
                LSR.L       #6, D3
                LSR.L       #7, D3
                CMPI.B      #%010, D3       ;CHECK IF THE INSTRUCTION IS ACTUALLY "BCLF #<DATA>, <EA>"
                BNE         INVALID_OPCODE  ;IF IT IS NOT, THEN THE OPCODE IS NOT DEFINED
                MOVE.B      #'B', (A2)+     ;OTHERWISE, IT IS ACTUALLY "BCLF #<DATA>, <EA>"
                MOVE.B      #'C', (A2)+
                MOVE.B      #'L', (A2)+
                MOVE.B      #'R', (A2)+
                MOVE.B      #TAB, (A2)+
                ;JSR         ISBCLR
                BRA         RETURN_ZERO


ZERO101         JSR         INVALID_OPCODE
                BRA         RETURN_ZERO


ZERO110         MOVE.B      #'C', (A2)+
                MOVE.B      #'M', (A2)+
                MOVE.B      #'P', (A2)+
                MOVE.B      #'I', (A2)+
                MOVE.B      #'.', (A2)+
                JSR         GET_SIZE
                MOVE.B      #TAB, (A2)+
                ;JSR         ISCMPI
                BRA         RETURN_ZERO

ZERO111         JSR         INVALID_OPCODE
                BRA         RETURN_ZERO

*----------------------------------------------------------------------------------------------------
* TABLEFOUR:
*----------------------------------------------------------------------------------------------------
TABLEFOUR       JMP         FOUR000
                JMP         FOUR001
                JMP         FOUR010
                JMP         FOUR011
                JMP         FOUR100
                JMP         FOUR101
                JMP         FOUR110
                JMP         FOUR111
RETURN_FOUR     RTS


FOUR000         JSR         INVALID_OPCODE
                BRA         RETURN_FOUR


FOUR001         JSR         INVALID_OPCODE
                BRA         RETURN_FOUR


FOUR010         MOVE.B      #'N', (A2)+     ;OTHERWISE, IT IS ACTUALLY "BCLF #<DATA>, <EA>"
                MOVE.B      #'E', (A2)+
                MOVE.B      #'G', (A2)+
                MOVE.B      #TAB, (A2)+
                ;JSR         ISNEG
                BRA         RETURN_FOUR


FOUR011         JSR         INVALID_OPCODE
                BRA         RETURN_FOUR


FOUR100         MOVE.B      #'M', (A2)+     ;OTHERWISE, IT IS ACTUALLY "BCLF #<DATA>, <EA>"
                MOVE.B      #'O', (A2)+
                MOVE.B      #'V', (A2)+
                MOVE.B      #'E', (A2)+
                MOVE.B      #'M', (A2)+
                MOVE.B      #'.', (A2)+
                JSR         IFMOVEMW
FOUR100_CONT    MOVE.B      #TAB, (A2)+
                JSR         ISMOVEM
                BRA         RETURN_FOUR

IFMOVEMW        MOVE.W      D2, D3
                LSL.L       #7, D3          ;SHIFT BITS TO GET BIT 8, 7 AND 6
                LSR.L       #6, D3
                LSR.L       #7, D3
                CMPI.B      #%010, D3       ;CHECK IF THE INSTRUCTION IS ACTUALLY "MOVEM.W"
                BNE         IFMOVEML        ;IF IT IS NOT, CHECK IF IT IS MOVEM.L
                MOVE.B      #'W', (A2)+
                RTS

IFMOVEML        MOVE.W      D2, D3
                LSL.L       #7, D3          ;SHIFT BITS TO GET BIT 8, 7 AND 6
                LSR.L       #6, D3
                LSR.L       #7, D3
                CMPI.B      #%011, D3       ;CHECK IF THE INSTRUCTION IS ACTUALLY "MOVEM.L"
                BNE         INVALID_OPCODE  ;IF IT IS NOT, THEN THE OPCODE IS NOT DEFINED
                MOVE.B      #'L', (A2)+
                BRA         FOUR100_CONT


FOUR101         JSR         INVALID_OPCODE
                BRA         RETURN_FOUR


FOUR110         BRA         FOUR1000


FOUR111         MOVE.W      D2, D3
                LSL.L       #8, D3          ;SHIFT BITS TO GET BIT 7 TO 0
                LSR.L       #8, D3
                CMPI.B      #%01110101, D3  ;CHECK IF THE INSTRUCTION IS ACTUALLY "RTS"
                BNE         IFJSR
                BRA         IFRTS
                BRA         FOUR100_CONT

IFRTS           MOVE.B      #'R', (A2)+
                MOVE.B      #'T', (A2)+
                MOVE.B      #'S', (A2)+
                MOVE.B      #TAB, (A2)+
                ;JSR        ISRTS
                BRA         RETURN_FOUR


IFJSR           MOVE.W      D2, D3
                LSL.L       #8, D3          ;SHIFT BITS TO GET BIT 7 AND 6
                LSR.L       #8, D3
                LSR.L       #6, D3
                CMPI.B      #10, D3         ;CHECK IF THE INSTRUCTION IS ACTUALLY "JSR"
                BNE         INVALID_OPCODE
                MOVE.B      #'J', (A2)+
                MOVE.B      #'S', (A2)+
                MOVE.B      #'R', (A2)+
                MOVE.B      #TAB, (A2)+
                ;JSR        ISJSR
                BRA         RETURN_FOUR

*----------------------------------------------------------------------------------------------------
* TABLESIX:
*----------------------------------------------------------------------------------------------------
TABLESIX  		JMP         SIX0000
				JMP	    	SIX0001
				JMP	    	SIX0010
				JMP	    	SIX0011
                JMP         SIX0100
                JMP         SIX0101
				JMP	    	SIX0110
				JMP	    	SIX0111
                JMP         SIX1000
				JMP	    	SIX1001
				JMP	    	SIX1010
				JMP	    	SIX1011
                JMP         SIX1100
                JMP         SIX1101
				JMP	    	SIX1110
				JMP	    	SIX1111
RETURN_SIX    	RTS


SIX0000       	MOVE.B		#'B', (A2)+
				MOVE.B      #'R', (A2)+
                MOVE.B      #'A', (A2)+
                MOVE.B      #TAB, (A2)+
                ;JSR        ISBRA
                BRA         RETURN_SIX


SIX0001			JSR         INVALID_OPCODE
                BRA	    	RETURN_SIX


SIX0010			JSR         INVALID_OPCODE
                BRA	    	RETURN_SIX


SIX0011			JSR         INVALID_OPCODE
                BRA	    	RETURN_SIX


SIX0100       	MOVE.B      #'B', (A2)+
                MOVE.B      #'C', (A2)+
                MOVE.B      #'C', (A2)+
                MOVE.B      #TAB, (A2)+
                ;JSR        ISBRA
                BRA         RETURN_SIX


SIX0101       	MOVE.B      #'B', (A2)+
                MOVE.B      #'C', (A2)+
                MOVE.B      #'S', (A2)+
                MOVE.B      #TAB, (A2)+
                ;JSR        ISBRA
                BRA         RETURN_SIX


SIX0110			JSR         INVALID_OPCODE
                BRA	    	RETURN_SIX


SIX0111			JSR         INVALID_OPCODE
                BRA	    	RETURN_SIX


SIX1000      	MOVE.B      #'B', (A2)+
                MOVE.B      #'V', (A2)+
                MOVE.B      #'C', (A2)+
                MOVE.B      #TAB, (A2)+
                ;JSR        ISBRA
                BRA         RETURN_SIX
                

SIX1001			JSR         INVALID_OPCODE
                BRA	   	 	RETURN_SIX


SIX1010			JSR         INVALID_OPCODE
                BRA	  	  	RETURN_SIX


SIX1011			JSR         INVALID_OPCODE
                BRA	  	  	RETURN_SIX


SIX1100       	MOVE.B      #'B', (A2)+
                MOVE.B      #'G', (A2)+
                MOVE.B      #'E', (A2)+
                MOVE.B      #TAB, (A2)+
                ;JSR        ISBRA
                BRA         RETURN_SIX


SIX1101         MOVE.B      #'B', (A2)+
                MOVE.B      #'L', (A2)+
                MOVE.B      #'T', (A2)+
                MOVE.B      #TAB, (A2)+
                ;JSR        ISBRA


SIX1110			JSR         INVALID_OPCODE
                BRA	 	   	RETURN_SIX


SIX1111         JSR         INVALID_OPCODE
                BRA	  	  	RETURN_SIX


*----------------------------------------------------------------------------------------------------
* TABLEELEVEN: THIS IS FUNCTION FOR DETERMINING THE OPMODE OF THE INSTRUCTION
*----------------------------------------------------------------------------------------------------
TABLEELEVEN		JMP			ELEVEN000
				JMP			ELEVEN001
				JMP			ELEVEN010
				JMP			ELEVEN011
				JMP			ELEVEN100
				JMP			ELEVEN101
				JMP			ELEVEN110
				JMP			ELEVEN111
RETURN_ELEVEN	RTS
				
ELEVEN000		MOVE.B		#'C', (A2)+
				MOVE.B		#'M', (A2)+
				MOVE.B		#'P', (A2)+
				MOVE.B		#'.', (A2)+
				MOVE.B		#'B', (A2)+
				MOVE.B		#TAB, (A2)+
				;JSR			ISCMP
				BRA			RETURN_ELEVEN
				
ELEVEN001		MOVE.B		#'C', (A2)+
				MOVE.B		#'M', (A2)+
				MOVE.B		#'P', (A2)+
				MOVE.B		#'.', (A2)+
				MOVE.B		#'W', (A2)+
				MOVE.B		#TAB, (A2)+
				;JSR			ISCMP
				BRA			RETURN_ELEVEN
				
ELEVEN010		MOVE.B		#'C', (A2)+
				MOVE.B		#'M', (A2)+
				MOVE.B		#'P', (A2)+
				MOVE.B		#'.', (A2)+
				MOVE.B		#'B', (A2)+
				MOVE.B		#TAB, (A2)+
			;	JSR			ISCMP
				BRA			RETURN_ELEVEN
				
ELEVEN011		JSR         INVALID_OPCODE
                BRA			RETURN_ELEVEN

ELEVEN100		MOVE.B		#'E', (A2)+
				MOVE.B		#'O', (A2)+
				MOVE.B		#'R', (A2)+
				MOVE.B		#'.', (A2)+
				MOVE.B		#'B', (A2)+
				MOVE.B		#TAB, (A2)+
				;JSR			ISEOR
				BRA			RETURN_ELEVEN
				
ELEVEN101		MOVE.B		#'E', (A2)+
				MOVE.B		#'O', (A2)+
				MOVE.B		#'R', (A2)+
				MOVE.B		#'.', (A2)+
				MOVE.B		#'W', (A2)+
				MOVE.B		#TAB, (A2)+
				;JSR			ISEOR
				BRA			RETURN_ELEVEN
				
ELEVEN110		MOVE.B		#'E', (A2)+
				MOVE.B		#'O', (A2)+
				MOVE.B		#'R', (A2)+
				MOVE.B		#'.', (A2)+
				MOVE.B		#'L', (A2)+
				MOVE.B		#TAB, (A2)+
				;JSR			ISEOR
				BRA			RETURN_ELEVEN
				
ELEVEN111		JSR         INVALID_OPCODE
                BRA			RETURN_ELEVEN

*----------------------------------------------------------------------------------------------------
* TABLETHIRTEEEN: THIS IS FUNCTION FOR DETERMINING THE OPMODE OF THE INSTRUCTION
*----------------------------------------------------------------------------------------------------X
TABLETHIRTEEN   JMP         THIRTEEN000
                JMP         THIRTEEN001
                JMP         THIRTEEN010
                JMP         THIRTEEN011
                JMP         THIRTEEN100
                JMP         THIRTEEN101
                JMP         THIRTEEN110
                JMP         THIRTEEN111
RETURN_THIRTEEN RTS


THIRTEEN000     MOVE.B		#'.', (A2)+
                MOVE.B		#'B', (A2)+
                ;JSR         ISADD
                BRA         RETURN_THIRTEEN

THIRTEEN001     MOVE.B		#'.', (A2)+
                MOVE.B		#'W', (A2)+
                ;JSR         ISADD
                BRA         RETURN_THIRTEEN

THIRTEEN010     MOVE.B		#'.', (A2)+
                MOVE.B		#'L', (A2)+
                ;JSR         ISADD
                BRA         RETURN_THIRTEEN

THIRTEEN011     MOVE.B      #'A', (A2)+
                MOVE.B		#'.', (A2)+
                MOVE.B		#'W', (A2)+
                ;JSR         ISADDA
                BRA         RETURN_THIRTEEN

THIRTEEN100     MOVE.B		#'.', (A2)+
                MOVE.B		#'B', (A2)+
                ;JSR         ISADD
                BRA         RETURN_THIRTEEN

THIRTEEN101     MOVE.B		#'.', (A2)+
                MOVE.B		#'W', (A2)+
                ;JSR         ISADD
                BRA         RETURN_THIRTEEN

THIRTEEN110     MOVE.B		#'.', (A2)+
                MOVE.B		#'L', (A2)+
                ;JSR         ISADD
                BRA         RETURN_THIRTEEN

THIRTEEN111     MOVE.B      #'A', (A2)+
                MOVE.B		#'.', (A2)+
                MOVE.B		#'L', (A2)+
                ;JSR         ISADDA
                BRA         RETURN_THIRTEEN

*----------------------------------------------------------------------------------------------------
* GET_OPMODE: THIS IS FUNCTION FOR DETERMINING THE OPMODE OF THE INSTRUCTION
*----------------------------------------------------------------------------------------------------
GET_OPMODE      MOVE.W      D2, D3          ;MAKE A COPY OF INSTRUCTION TO D3
                LSL         #7, D3          ;SHIFT TO THE LEFT 7 BITS
                LSR         #4, D3          ;SHIFT TO THE RIGHT 4 BITS
                LSR         #7, D3          ;SHIFT TO THE RIGHT 7 BITS
                MULU        #6, D3
                
                LEA         TABLEOPMODE, A3
                JSR         0(A3, D3)
                RTS
  
TABLEOPMODE     JMP         MODE000
                JMP         MODE001
                JMP         MODE010
                JMP         MODE011
                JMP         MODE100
                JMP         MODE101
                JMP         MODE110
                JMP         MODE111
RETURN_OPMODE   RTS
                
MODE000      	MOVE.B      #'B', (A2)+
                BRA         RETURN_OPMODE
				
MODE001      	MOVE.B      #'W', (A2)+
                BRA         RETURN_OPMODE
				
MODE010      	MOVE.B      #'L', (A2)+
                BRA         RETURN_OPMODE

MODE011			BRA			RETURN_OPMODE

MODE100			MOVE.B      #'B', (A2)+
                BRA         RETURN_OPMODE

MODE101      	MOVE.B      #'W', (A2)+
                BRA         RETURN_OPMODE
				
MODE110      	MOVE.B      #'L', (A2)+
                BRA         RETURN_OPMODE
				
MODE111			BRA			RETURN_OPMODE
                
*----------------------------------------------------------------------------------------------------
* GET_SIZE: THIS IS A FUNCTION FOR DETERMINING THE SIZE OF THE INSTRUCTION
*----------------------------------------------------------------------------------------------------
GET_SIZE        MOVE.W      D2, D3          ;MAKE A COPY OF ORIGINAL INSTRUCTION TO D3
                LSL         #8, D3          ;SHIFT TO THE LEFT 8 BITS
                LSR         #6, D3          ;SHIFT TO THE RIGHT 6 BITS
                LSR         #8, D3          ;SHIFT TO THE RIGHT 8 BITS
                MULU        #6, D3
                
                LEA         TABLESIZE, A3
                JSR         0(A3, D3)
                RTS

TABLESIZE       JMP         SIZE00
                JMP         SIZE01
                JMP         SIZE10
                JMP         SIZE11
RETURN_SIZE     RTS
                
SIZE00 	        MOVE.B      #'B', (A2)+
                BRA         RETURN_SIZE
                                
SIZE01			MOVE.B      #'W', (A2)+
                BRA         RETURN_SIZE
				
SIZE10      	MOVE.B      #'L', (A2)+
                BRA         RETURN_SIZE
                
SIZE11			BRA			RETURN_SIZE

*----------------------------------------------------------------------------------------------------
* GET_DIRECTION: THIS IS A FUNCTION FOR DETERMINING THE DIRECTION OF THE INSTRUCTION (LEFT OR RIGHT)
*----------------------------------------------------------------------------------------------------


*----------------------------------------------------------------------------------------------------
INVALID_OPCODE:
*----------------------------------------------------------------------------------------------------
INVALID_OPCODE  MOVE.B      #'I', (A2)+
                MOVE.B      #'N', (A2)+
                MOVE.B      #'V', (A2)+
                MOVE.B      #'A', (A2)+
                MOVE.B      #'L', (A2)+
                MOVE.B      #'I', (A2)+
                MOVE.B      #'D', (A2)+
                MOVE.B      #' ', (A2)+
                MOVE.B      #'O', (A2)+
                MOVE.B      #'P', (A2)+
                MOVE.B      #'C', (A2)+
                MOVE.B      #'O', (A2)+
                MOVE.B      #'D', (A2)+
                MOVE.B      #'E', (A2)+
                RTS

*----------------------------------------------------------------------------------------------------

TAB             EQU         $09

*----------------------------------------------------------------------------------------------------

                END    START        ; last line of source






*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
