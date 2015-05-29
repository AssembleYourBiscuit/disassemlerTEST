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
*               - A2 STORES AN APPROPRIATE MEMORY REGION ADDRESS
*               - A6 STORES AN APPROPRIATE ADDRESS HAVING HEXADECIMLA INSTRUCTION TO BE DISASSEMBLED
* POSTCONDITION: - IF THE INSTRUCTION IS DEFINED IN THE REQUIREMENT, THE STRING OF THE RESULT WILL BE
*                  STORED IN OUTPUT MEMORY REGION POINTED BY A2
*                - IF THE INSTRUCTION IS NOT IN THE REQUIREMENT, "BAD DATA" WILL BE STORED IN OUTPUT
*                  MEMORY REGION POINTED BY A2
*----------------------------------------------------------------------------------------------------

DISASSEMBLE     CLR         D2              ;CLEAR BITS IN D2 AND D3 TO PREVENT INFORMATION OVERLAPED
                CLR         D3
                
                MOVE.W      (A6), D2        ;RETRIEVE ORIGINAL INSTRUCTION TO D2 (NO CHANGE ALLOWED)
                MOVE.W      D2, D3          ;COPY ORIGINAL INSTRUCTION TO D3 (CHANGE ALLOW)

                LSR         #8, D3          ;GET THE FIRST 4 BITS TO DETERMIND TYPE OF MNEMONIC
                LSR         #4, D3
                MULU        #6, D3
                LEA         MAINTABLE, A3   ;LOAD INDEX INTO THE TABLE
                JSR         0(A3, D3)       ;JUMP INDIRECT WITH INDEX TO MAINTABLE

                RTS                         ;FINISH DIASSEMBLING
            
                    
*----------------------------------------------------------------------------------------------------
* MAINTABLE: THIS IS A PRIMARY JUMP TABLE FOR DETERMINING TYPES OF OPCODES INSTRUCTION BY LOOKING AT
*            THE FIRST 4 BITS IN THE HEXADECIMAL INSTRUCTION
* PRECONDITION: - D2 MUST CONTAINS ORIGINAL INSTRUCTION FOR FUTHURE DETERMINING
*               - D3 MUST CONTAINS THE FIRST 4 BITS OF INSTRUCTION
* POSTCONDITION: - IF THE INSTRUCTION IS DEFINED IN THE REQUIREMENT, THE STRING OF THE RESULT WILL BE
*                  STORED IN OUTPUT MEMORY REGION POINTED BY A2
*                - IF THE INSTRUCTION IS NOT IN THE REQUIREMENT, "BAD DATA" WILL BE STORED IN OUTPUT
*                  MEMORY REGION POINTED BY A2
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
* CODE0000: DISASSEMBLE THE HEXADECIMAL INSTRUCTION STARTING WITH 0000
*----------------------------------------------------------------------------------------------------
CODE0000        MOVE.W      D2, D3
                LSL.L       #7, D3          ;GET THE 8TH BIT
                LSR.L       #8, D3
                LSR.L       #7, D3

                CMPI.B      #%1, D3         ;CHECK IF THE 8TH BIT IS EQUAL TO 1
                BEQ         IFBCLR_DY       ;IF IT IS EQUAL, THE INSTRUCTION IS "BCLR DN, <EA>"
                
                MOVE.W      D2, D3          ;OTHERWISE, GET BIT 11, 10, AND 9 FOR FUTHER DISASSEMBLING
                LSL.L       #4, D3
                LSR.L       #8, D3
                LSR.L       #5, D3
                MULU        #6, D3
                LEA         TABLEZERO, A3   ;LOAD INDEX INTO THE TABLE
                JSR         0(A3, D3)       ;JUMP INDIRECT WITH INDEX TO TABLEZERO
RETURN0000      BRA         FINISH          ;INSTRUCTION IS FINISHED DECODING


IFBCLR_DY       MOVE.W      D2, D3          ;GET BIT 7 AND 6
                LSL.L       #8, D3
                LSR.L       #8, D3
                LSR.L       #6, D3
                CMPI.B      #%10, D3        ;CHECK IF INSTRUCTION IS ACTUALLY BCLR WITH NUMBER DYNAMIC
                BNE         BADDATA         ;IF IT IS NOT, THEN THE OPCODE IS NOT DEFINED
                MOVE.B      #'B', (A2)+     ;OTHERWISE, IT IS ACTUALLY "BCLR DN, <EA>"    
                MOVE.B      #'C', (A2)+
                MOVE.B      #'L', (A2)+
                MOVE.B      #'R', (A2)+
                MOVE.B      #TAB, (A2)+
                JSR         ISBCLR         ;GET EFFECTIVE ADDRESS
                BRA         RETURN0000      ;RETURN BACK TO THE MAIN FUNCTION

*----------------------------------------------------------------------------------------------------
* CODE0001: DISASSEMBLE THE HEXADECIMAL INSTRUCTION STARTING WITH 0001
*----------------------------------------------------------------------------------------------------
CODE0001        MOVE.B      #'M', (A2)+     ;THE INSTRUCTION IS "MOVE.B"
                MOVE.B      #'O', (A2)+
                MOVE.B      #'V', (A2)+
                MOVE.B      #'E', (A2)+
                MOVE.B      #'.', (A2)+
                MOVE.B      #'B', (A2)+
                MOVE.B      #TAB, (A2)+
                JSR         ISMOVE          ;GET EFFECTIVE ADDRESS
                BRA         FINISH          ;RETURN BACK TO THE MAIN FUNCTION
           
*----------------------------------------------------------------------------------------------------
* CODE0010: DISASSEMBLE THE HEXADECIMAL INSTRUCTION STARTING WITH 0010
*----------------------------------------------------------------------------------------------------
CODE0010        MOVE.B      #'M', (A2)+     ;THE INSTRUCTION IS "MOVE..."
                MOVE.B      #'O', (A2)+
                MOVE.B      #'V', (A2)+
                MOVE.B      #'E', (A2)+
                JSR         IFMOVEA         ;CHECK IF THE INSTRUCTION IS MOVEA OR JUST MOVE
IFMOVEL         MOVE.B      #'.', (A2)+     ;PROVIDE SIZE OF THE INSTRUCTION
                MOVE.B      #'L', (A2)+
                MOVE.B      #TAB, (A2)+
                JSR         ISMOVEL        ;GET EFFECTIVE ADDRESS
                BRA         FINISH          ;RETURN BACK TO THE MAIN FUNCTION
          
IFMOVEA         MOVE.W      D2, D3
                LSL.L       #7, D3          ;GET BIT 8, 7 AND 6
                LSR.L       #8, D3
                LSR.L       #5, D3
                CMPI.W      #%001, D3       ;CHECK IF THIS INSTRUCTION IS MOVEA
                BNE         IFMOVEL         ;IF THE INSTRUCTION IS NOT MOVEA, IT MUST BE MOVE
                MOVE.B      #'A',(A2)+      ;OTHERWISE, IT IS "MOVEA.L"
                RTS

*----------------------------------------------------------------------------------------------------
* CODE0011: DISASSEMBLE THE HEXADECIMAL INSTRUCTION STARTING WITH 0011
*----------------------------------------------------------------------------------------------------
CODE0011        MOVE.B      #'M', (A2)+     ;THE INSTRUCTION IS "MOVE..."
                MOVE.B      #'O', (A2)+
                MOVE.B      #'V', (A2)+
                MOVE.B      #'E', (A2)+
                JSR         IFMOVEA         ;CHECK IF THE INSTRUCTION IS MOVEA OR JUST MOVE
IFMOVEW         MOVE.B      #'.', (A2)+     ;PROVIDE SIZE OF THE INSTRUCTION
                MOVE.B      #'W', (A2)+
                MOVE.B      #TAB, (A2)+
                JSR         ISMOVE         ;GET EFFECTIVE ADDRESS
                BRA         FINISH          ;RETURN BACK TO THE MAIN FUNCTION

*----------------------------------------------------------------------------------------------------
* CODE0100: DISASSEMBLE THE HEXADECIMAL INSTRUCTION STARTING WITH 0100
*----------------------------------------------------------------------------------------------------
CODE0100        MOVE.W      D2, D3
                LSL.L       #7, D3          ;GET THE 8TH BIT
                LSR.L       #8, D3
                LSR.L       #7, D3

                CMPI.B      #%1, D3         ;CHECK IF THE 8TH BIT IS EQUAL TO 1
                BEQ         IFLEA           ;IF IT IS EQUAL, THE INSTRUCTION MAY BE "LEA"

                LSL.L       #4, D3          ;IF NOT, GET BIT 11, 10, AND 9 FOR FUTHER DISASSEMBLING
                LSR.L       #8, D3
                LSR.L       #5, D3
                MULU        #6, D3
                LEA         TABLEFOUR, A3   ;LOAD INDEX INTO THE TABLE
                JSR         0(A3, D3)       ;JUMP INDIRECT WITH INDEX TO TABLEFOUR
RETURN0100      BRA         FINISH          ;RETURN BACK TO THE MAIN FUNCTION


IFLEA           MOVE.W      D2, D3
                LSL.L       #7, D3          ;GET BIT 8, 7 AND 6
                LSR.L       #8, D3
                LSR.L       #5, D3
                CMPI.B      #%111, D3       ;CHECK IF THE INSTRUCTION IS ACTUALLY "LEA"
                BNE         BADDATA         ;IF IT IS NOT, THEN THE OPCODE IS NOT DEFINED
                MOVE.B      #'L', (A2)+     ;OTHERWISE, IT IS ACTUALLY "LEA"
                MOVE.B      #'E', (A2)+
                MOVE.B      #'A', (A2)+
                MOVE.B      #TAB, (A2)+
                ;JSR         ISLEA          ;GET EFFECTIVE ADDRESS
                BRA         RETURN0100      ;RETURN TO CODE0100

*----------------------------------------------------------------------------------------------------
* CODE0101: DISASSEMBLE THE HEXADECIMAL INSTRUCTION STARTING WITH 0101
*----------------------------------------------------------------------------------------------------
CODE0101        MOVE.B      #'S', (A2)+     ;THE INSTRUCTION IS "SUBQ"
                MOVE.B      #'U', (A2)+
                MOVE.B      #'B', (A2)+
                MOVE.B      #'Q', (A2)+
                MOVE.B      #'.', (A2)+
                JSR         GET_SIZE        ;GET SIZE FOR THE INSTRUCTION
                MOVE.B      #TAB, (A2)+
                ;JSR         ISSUBQ         ;GET EFFECTIVE ADDRESS
                BRA         FINISH          ;RETURN BACK TO THE MAIN FUNCTION

*----------------------------------------------------------------------------------------------------
* CODE0110: DISASSEMBLE THE HEXADECIMAL INSTRUCTION STARTING WITH 0110
*----------------------------------------------------------------------------------------------------
CODE0110        MOVE.W      D2, D3
                LSL.L       #4, D3          ;GET BIT 11 TO 8
                LSR.L       #8, D3
                LSR.L       #4, D3

                MULU        #6, D3
                LEA         TABLESIX, A3    ;LOAD INDEX INTO THE TABLE
                JSR         0(A3, D3)       ;JUMP INDIRECT WITH INDEX TO TABLESIX
                
                MOVE.B      #TAB, (A2)+
                JSR         ISBRA           ;GET EFFECTIVE ADDRESS
                BRA         FINISH          ;RETURN BACK TO THE MAIN FUNCTION

*----------------------------------------------------------------------------------------------------
* CODE0111: HEXADECIMAL INSTRUCTION STARTING WITH 0111 IS NOT DEFINED
*----------------------------------------------------------------------------------------------------
CODE0111		BNE         BADDATA
                RTS

*----------------------------------------------------------------------------------------------------
* CODE1000: DISASSEMBLE THE HEXADECIMAL INSTRUCTION STARTING WITH 1000
*----------------------------------------------------------------------------------------------------
CODE1000        MOVE.W      D2, D3
                LSL.L       #7, D3          ;GET BIT 8, 7, AND 6
                LSR.L       #8, D3
                LSR.L       #5, D3
                CMPI.W      #%111, D3       ;CHECK IF BIT 8, 7, AND 6 IS EQUAL TO 111
                BEQ         IFDIVS          ;IF IT IS, THE INSTRUCTION IS "DIVS"
                BRA         IFOR            ;OTHERWISE, IT IS "OR"
RETURN1000      BRA         FINISH          ;RETURN BACK TO THE MAIN FUNCTION


IFDIVS          MOVE.B      #'D', (A2)+     ;THE INSTRUCTION IS "DIVS"
                MOVE.B      #'I', (A2)+
                MOVE.B      #'V', (A2)+
                MOVE.B      #'S', (A2)+
                MOVE.B      #TAB, (A2)+
                JSR         ISDIVS          ;GET EFFECTIVE ADDRESS
                BRA         RETURN1000      ;RETURN TO CODE1000

IFOR            MOVE.B      #'O', (A2)+     ;THE INSTRUCTION IS "OR"
                MOVE.B      #'R', (A2)+
                MOVE.B      #'.', (A2)+
                JSR         GET_OPMODE      ;GET OPMODE
                MOVE.B      #TAB, (A2)+
                JSR         ISOR            ;GET EFFECTIVE ADDRESS
                BRA         RETURN1000      ;RETURN TO CODE1000


*----------------------------------------------------------------------------------------------------
* CODE1001: DISASSEMBLE THE HEXADECIMAL INSTRUCTION STARTING WITH 1001
*----------------------------------------------------------------------------------------------------
CODE1001        MOVE.B      #'S', (A2)+     ;THE INSTRUCTION IS "SUB"
                MOVE.B      #'U', (A2)+
                MOVE.B      #'B', (A2)+
                MOVE.B      #'.', (A2)+
                JSR         GET_OPMODE      ;GET OPMODE
                MOVE.B      #TAB, (A2)+
                ;JSR        ISSUB           ;GET EFFECTIVE ADDRESS
                BRA         FINISH          ;RETURN BACK TO THE MAIN FUNCTION

*----------------------------------------------------------------------------------------------------
* CODE1010: HEXADECIMAL INSTRUCTION STARTING WITH 1010 IS NOT DEFINED
*----------------------------------------------------------------------------------------------------
CODE1010        BNE         BADDATA
                BRA         FINISH

*----------------------------------------------------------------------------------------------------
* CODE1011: DISASSEMBLE THE HEXADECIMAL INSTRUCTION STARTING WITH 1011
*----------------------------------------------------------------------------------------------------
CODE1011		MOVE.W      D2, D3
                LSL.L       #7, D3          ;GET BIT 8, 7, AND 6
                LSR.L       #8, D3
                LSR.L       #5, D3

                MULU        #6, D3
                LEA         TABLEELEVEN, A3 ;LOAD INDEX INTO THE TABLE
                JSR         0(A3, D3)       ;JUMP INDIRECT WITH INDEX TO TABLEELEVEN
                BRA         FINISH          ;RETURN BACK TO THE MAIN FUNCTION

*----------------------------------------------------------------------------------------------------
* CODE1100: DISASSEMBLE THE HEXADECIMAL INSTRUCTION STARTING WITH 1100
*----------------------------------------------------------------------------------------------------
CODE1100        MOVE.W      D2, D3
                LSL.L       #7, D3          ;GET BIT 8, 7, AND 6
                LSR.L       #8, D3
                LSR.L       #5, D3
                CMPI.W      #%111, D3       ;CHECK IF BIT 8, 7, AND 6 ARE EQUAL TO 111
                BNE         BADDATA         ;IF NOT, THEN THE INSTRUCTION IS NOT DEFINED
                
                MOVE.B      #'M', (A2)+     ;OTHERWISE, THE INSTRUCTION IS "MULS"
                MOVE.B      #'U', (A2)+
                MOVE.B      #'L', (A2)+
                MOVE.B      #'S', (A2)+
                JSR         ISMULS         ;GET EFFECTIVE ADDRESS
                BRA         FINISH          ;RETURN BACK TO THE MAIN FUNCTION
                
*----------------------------------------------------------------------------------------------------
* CODE1101: DISASSEMBLE THE HEXADECIMAL INSTRUCTION STARTING WITH 1101
*----------------------------------------------------------------------------------------------------
CODE1101		MOVE.B		#'A', (A2)+     ;THE INSTRUCTION IS "ADD"
				MOVE.B		#'D', (A2)+
				MOVE.B		#'D', (A2)+

                LSL.L       #7, D3          ;GET BIT 8, 7, AND 6 TO FOR FUTHER DISASSEMBLING
                LSR.L       #8, D3
                LSR.L       #5, D3

                MULU        #6, D3
                LEA         TABLETHIRTEEN, A3   ;LOAD INDEX INTO THE TABLE
                JSR         0(A3, D3)           ;JUMP INDIRECT WITH INDEX TO TABLETHIRTEEN

                MOVE.B      #TAB, (A2)+
                BRA         FINISH          ;RETURN BACK TO THE MAIN FUNCTION

*----------------------------------------------------------------------------------------------------
* CODE1110: DISASSEMBLE THE HEXADECIMAL INSTRUCTION STARTING WITH 1110
*----------------------------------------------------------------------------------------------------
CODE1110		MOVE.W		D2, D3
				LSL.L		#8, D3			;GET BIT 7 AND 6
				LSR.L		#6, D3
				LSR.L		#8, D3
				CMPI.W		#%11, D3		;CHECK IF BIT 7 AND 6 ARE EQUAL TO 11
				BEQ			FOURTEEN_MEM	;IF IT IS EQAUL, THE INSTRUCTION IS MEMORY SHIFT/ROTATION
				BRA			FOURTEEN_REG	;OTHERWISE, IT IS A REGISTER SHIFT/ROTATION
CODE1110_CONT   JSR			GET_DIRECTION   ;GET DIRECTION OF THE INSTRUCTION
                MOVE.B      #'.', (A2)+
                JSR         GETSIZE         ;GET SIZE OF THE INSTRUCTION
                MOVE.B      #TAB, (A2)+
                JSR         ISSHIFTYSTUFF
                BRA         FINISH          ;RETURN BACK TO THE MAIN FUNCTION
				
FOURTEEN_MEM	MOVE.W		D2, D3
				LSL.L		#4, D3			    ;GET BIT 11TH
				LSR.L		#8, D3
				LSR.L		#7, D3
				CMPI.B		#%0, D3			    ;CHECK IF THE INSTRUCTION IS ACTUALLY MEMORY SHIFT/ROTATION
				BNE			BADDATA             ;IF NOT, THE INSTRUCTION IS NOT DEFINED
				
				MOVE.W		D2, D3              ;OTHERWISE, SHIFT BITS TO GET BIT 10 AND 9 FOR FUTHER
				LSL.L		#5, D3              ;DISASSEMBLING
				LSR.L		#8, D3
				LSR.L		#6, D3
				
                MULU        #6, D3           
                LEA         TABLEFOURTEEN, A3   ;LOAD INDEX INTO THE TABLE
                JSR         0(A3, D3)           ;JUMP INDIRECT WITH INDEX TO TABLEFOURTEEN
				BRA         CODE1110_CONT       ;GO TO CODE1110_CONT FOR MORE DISASSEBMBLING
				
FOURTEEN_REG	MOVE.W		D2, D3
				LSL.L		#8, D3			    ;GET BIT 4 AND 3 FOR FUTHER DISASSEMBLING
				LSL.L		#3, D3
				LSR.L		#8, D3
				LSR.L		#6, D3
                MULU        #6, D3
                LEA         TABLEFOURTEEN, A3   ;LOAD INDEX INTO THE TABLE
                JSR         0(A3, D3)           ;JUMP INDIRECT WITH INDEX TO TABLEFOURTEEN
                BRA         CODE1110_CONT       ;GOES BACK TO CODE1110_CONT FOR MORE DISASSEBMBLING
								
*----------------------------------------------------------------------------------------------------
* CODE1111: HEXADECIMAL INSTRUCTION STARTING WITH 1111 IS NOT DEFINED
*----------------------------------------------------------------------------------------------------
CODE1111		BNE         BADDATA
                RTS




*----------------------------------------------------------------------------------------------------
* TABLEZERO: THIS IS SUBROUTINE JUMP TABLE. IT IS FOR DETERMINING OPMODE OF THE INSTRUCTION THAT IS
*            STARED WITH 0000
* PRECONDITION: - D2 MUST CONTAINS ORIGINAL INSTRUCTION FOR FUTHURE DETERMINING
*               - D3 MUST CONTAINS BIT 11, 10, AND 9 OF INSTRUCTION
* POSTCONDITION: - IF THE INSTRUCTION IS DEFINED IN THE REQUIREMENT, THE STRING OF THE RESULT WILL BE
*                  STORED IN OUTPUT MEMORY REGION POINTED BY A2
*                - IF THE INSTRUCTION IS NOT IN THE REQUIREMENT, "BAD DATA" WILL BE STORED IN OUTPUT
*                  MEMORY REGION POINTED BY A2
*----------------------------------------------------------------------------------------------------
TABLEZERO       JMP         ZERO000
                JMP         ZERO001
                JMP         ZERO010
                JMP         ZERO011
                JMP         ZERO100
                JMP         ZERO101
                JMP         ZERO110
                JMP         ZERO111
RETURN_ZERO     RTS                             ;RETURN BACK TO MAINTABLE

*----------------------------------------------------------------------------------------------------
* ZERO000: DISASSEMBLE THE HEXADECIMAL INSTRUCTION THAT HAS BIT 11, 10, AND 9 EQUAL TO 000
*----------------------------------------------------------------------------------------------------
ZERO000         MOVE.B      #'O', (A2)+         ;THE INSTRUCTION IS ORI
                MOVE.B      #'R', (A2)+
                MOVE.B      #'I', (A2)+
                MOVE.B      #'.', (A2)+
                JSR         GET_SIZE            ;GET SIZE OF THE INSTRUCTION
                MOVE.B      #TAB, (A2)+
                JSR         ISORI              ;GET EFFECTIVE ADDRESS
                BRA         RETURN_ZERO         ;RETURN TO TABLEZERO

*----------------------------------------------------------------------------------------------------
* ZERO001: HEXADECIMAL INSTRUCTION THAT HAS BIT 11, 10, AND 9 EQUAL TO 001 IS NOT DEFINED
*----------------------------------------------------------------------------------------------------
ZERO001         JSR         BADDATA
                BRA         RETURN_ZERO

*----------------------------------------------------------------------------------------------------
* ZERO010: HEXADECIMAL INSTRUCTION THAT HAS BIT 11, 10, AND 9 EQUAL TO 010 IS NOT DEFINED
*----------------------------------------------------------------------------------------------------
ZERO010         JSR         BADDATA
                BRA         RETURN_ZERO

*----------------------------------------------------------------------------------------------------
* ZERO011: HEXADECIMAL INSTRUCTION THAT HAS BIT 11, 10, AND 9 EQUAL TO 011 IS NOT DEFINED
*----------------------------------------------------------------------------------------------------
ZERO011         JSR         BADDATA
                BRA         RETURN_ZERO


*----------------------------------------------------------------------------------------------------
* ZERO100: DISASSEMBLE THE HEXADECIMAL INSTRUCTION THAT HAS BIT 11, 10, AND 9 EQUAL TO 100
*----------------------------------------------------------------------------------------------------
ZERO100         MOVE.W      D2, D3
                LSL.L       #7, D3          ;GET BIT 8, 7 AND 6
                LSR.L       #6, D3          
                LSR.L       #7, D3
                CMPI.B      #%010, D3       ;CHECK IF INSTRUCTION IS ACTUALLY "BCLF #<DATA>, <EA>"
                BNE         BADDATA         ;IF IT IS NOT, THEN THE OPCODE IS NOT DEFINED
                
                MOVE.B      #'B', (A2)+     ;OTHERWISE, IT IS ACTUALLY "BCLF #<DATA>, <EA>"
                MOVE.B      #'C', (A2)+
                MOVE.B      #'L', (A2)+
                MOVE.B      #'R', (A2)+
                MOVE.B      #TAB, (A2)+
                JSR         ISBCLR         ;GET EFFECTIVE ADDRESS
                BRA         RETURN_ZERO     ;RETURN TO TABLEZERO

*----------------------------------------------------------------------------------------------------
* ZERO101: HEXADECIMAL INSTRUCTION THAT HAS BIT 11, 10, AND 9 EQUAL TO 101 IS NOT DEFINED
*----------------------------------------------------------------------------------------------------
ZERO101         JSR         BADDATA
                BRA         RETURN_ZERO

*----------------------------------------------------------------------------------------------------
* ZERO110: DISASSEMBLE THE HEXADECIMAL INSTRUCTION THAT HAS BIT 11, 10, AND 9 EQUAL TO 110
*----------------------------------------------------------------------------------------------------
ZERO110         MOVE.B      #'C', (A2)+     ;THE INSTRUCTION IS CMPI
                MOVE.B      #'M', (A2)+
                MOVE.B      #'P', (A2)+
                MOVE.B      #'I', (A2)+
                MOVE.B      #'.', (A2)+
                JSR         GET_SIZE        ;GET SIZE OF THE INSTRUCTION
                MOVE.B      #TAB, (A2)+
                JSR         ISORI         ;GET EFFECTIVE ADDRESS
                BRA         RETURN_ZERO     ;RETURN TO TABLEZERO

*----------------------------------------------------------------------------------------------------
* ZERO111: HEXADECIMAL INSTRUCTION THAT HAS BIT 11, 10, AND 9 EQUAL TO 111 IS NOT DEFINED
*----------------------------------------------------------------------------------------------------
ZERO111         JSR         BADDATA
                BRA         RETURN_ZERO



*----------------------------------------------------------------------------------------------------
* TABLEFOUR: THIS IS SUBROUTINE JUMP TABLE. IT IS FOR DETERMINING OPMODE OF THE INSTRUCTION THAT IS
*            STARED WITH 0100
* PRECONDITION: - D2 MUST CONTAINS ORIGINAL INSTRUCTION FOR FUTHURE DETERMINING
*               - D3 MUST CONTAINS BIT 11, 10, AND 9 OF INSTRUCTION
* POSTCONDITION: - IF THE INSTRUCTION IS DEFINED IN THE REQUIREMENT, THE STRING OF THE RESULT WILL BE
*                  STORED IN OUTPUT MEMORY REGION POINTED BY A2
*                - IF THE INSTRUCTION IS NOT IN THE REQUIREMENT, "BAD DATA" WILL BE STORED IN OUTPUT
*                  MEMORY REGION POINTED BY A2
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

*----------------------------------------------------------------------------------------------------
* FOUR000: HEXADECIMAL INSTRUCTION THAT HAS BIT 11, 10, AND 9 EQUAL TO 000 IS NOT DEFINED
*----------------------------------------------------------------------------------------------------
FOUR000         JSR         BADDATA
                BRA         RETURN_FOUR

*----------------------------------------------------------------------------------------------------
* FOUR001: HEXADECIMAL INSTRUCTION THAT HAS BIT 11, 10, AND 9 EQUAL TO 001 IS NOT DEFINED
*----------------------------------------------------------------------------------------------------
FOUR001         JSR         BADDATA
                BRA         RETURN_FOUR

*----------------------------------------------------------------------------------------------------
* FOUR010: DISASSEMBLE THE HEXADECIMAL INSTRUCTION THAT HAS BIT 11, 10, AND 9 EQUAL TO 010
*----------------------------------------------------------------------------------------------------
FOUR010         MOVE.B      #'N', (A2)+     ;THE INSTRUCTION IS "NEG"
                MOVE.B      #'E', (A2)+
                MOVE.B      #'G', (A2)+
                MOVE.B      #TAB, (A2)+
                JSR         ISNEG          ;GET EFFECTIVE ADDRESS
                BRA         RETURN_FOUR     ;RETURN TO TABLEFOUR

*----------------------------------------------------------------------------------------------------
* FOUR011: HEXADECIMAL INSTRUCTION THAT HAS BIT 11, 10, AND 9 EQUAL TO 011 IS NOT DEFINED
*----------------------------------------------------------------------------------------------------
FOUR011         JSR         BADDATA
                BRA         RETURN_FOUR

*----------------------------------------------------------------------------------------------------
* FOUR100: DISASSEMBLE THE HEXADECIMAL INSTRUCTION THAT HAS BIT 11, 10, AND 9 EQUAL TO 100
*----------------------------------------------------------------------------------------------------
FOUR100         MOVE.B      #'M', (A2)+     ;INSTRUCTION IS "MOVEM"
                MOVE.B      #'O', (A2)+
                MOVE.B      #'V', (A2)+
                MOVE.B      #'E', (A2)+
                MOVE.B      #'M', (A2)+
                MOVE.B      #'.', (A2)+
                JSR         IFMOVEMW        ;CHECK SIZE OF THE THE INSTRUCTION
FOUR100_CONT    MOVE.B      #TAB, (A2)+
                JSR         ISMOVEM        ;GET EFFECTIVE ADDRESS
                BRA         RETURN_FOUR     ;RETURN TO TABLEFOUR

IFMOVEMW        MOVE.W      D2, D3
                LSL.L       #7, D3          ;GET BIT 8, 7 AND 6
                LSR.L       #6, D3
                LSR.L       #7, D3
                CMPI.B      #%010, D3       ;CHECK IF THE INSTRUCTION IS ACTUALLY "MOVEM.W"
                BNE         IFMOVEML        ;IF IT IS NOT, CHECK IF IT IS MOVEM.L
                MOVE.B      #'W', (A2)+     ;OTHEEWISE, IT IS "MOVEM.W"
                RTS                         ;RETURN BACK TO FOUR100 FOR MORE DISASSEMBLING

IFMOVEML        MOVE.W      D2, D3
                LSL.L       #7, D3          ;GET BIT 8, 7 AND 6
                LSR.L       #6, D3
                LSR.L       #7, D3
                CMPI.B      #%011, D3       ;CHECK IF THE INSTRUCTION IS ACTUALLY "MOVEM.L"
                BNE         BADDATA         ;IF IT IS NOT, THEN THE OPCODE IS NOT DEFINED
                MOVE.B      #'L', (A2)+     ;OTHEWISE, IT IS "MOVEM.L"
                BRA         FOUR100_CONT    ;GO TO FOUR100_CONT FOR MORE DISASSEBMBLING

*----------------------------------------------------------------------------------------------------
* FOUR001: HEXADECIMAL INSTRUCTION THAT HAS BIT 11, 10, AND 9 EQUAL TO 001 IS NOT DEFINED
*----------------------------------------------------------------------------------------------------
FOUR101         JSR         BADDATA
                BRA         RETURN_FOUR

*----------------------------------------------------------------------------------------------------
* FOUR110: DISASSEMBLE THE HEXADECIMAL INSTRUCTION THAT HAS BIT 11, 10, AND 9 EQUAL TO 110
*----------------------------------------------------------------------------------------------------
FOUR110         BRA         FOUR100         ;THE INSTRUCTION IS "MOVEM"

*----------------------------------------------------------------------------------------------------
* FOUR111: DISASSEMBLE THE HEXADECIMAL INSTRUCTION THAT HAS BIT 11, 10, AND 9 EQUAL TO 111
*----------------------------------------------------------------------------------------------------
FOUR111         MOVE.W      D2, D3
                LSL.L       #8, D3          ;GET BIT 7 TO 0
                LSR.L       #8, D3
                CMPI.B      #%01110101, D3  ;CHECK IF THE INSTRUCTION IS ACTUALLY "RTS"
                BNE         IFJSR
                BRA         IFRTS
RETURN_FOUR111  BRA         RETURN_FOUR     ;RETURN TO TABLEFOUR

IFRTS           MOVE.B      #'R', (A2)+     ;THE INSTRUCTION IS "RTS"
                MOVE.B      #'T', (A2)+
                MOVE.B      #'S', (A2)+
                BRA         RETURN_FOUR111  ;RETURN BACK TO FOUR111


IFJSR           MOVE.W      D2, D3
                LSL.L       #8, D3          ;GET BIT 7 AND 6
                LSR.L       #8, D3
                LSR.L       #6, D3
                CMPI.B      #10, D3         ;CHECK IF THE INSTRUCTION IS ACTUALLY "JSR"
                BNE         BADDATA
                
                MOVE.B      #'J', (A2)+     ;THE INSTRUCTION IS "JSR"
                MOVE.B      #'S', (A2)+
                MOVE.B      #'R', (A2)+
                MOVE.B      #TAB, (A2)+
                ;JSR        ISJSR           ;GET EFFECTIVE ADDRESS
                BRA         RETURN_FOUR111  ;RETURN BACK TO FOUR111


*----------------------------------------------------------------------------------------------------
* TABLEFOUR: THIS IS SUBROUTINE JUMP TABLE. IT IS FOR DETERMINING OPMODE OF THE INSTRUCTION THAT IS
*            STARED WITH 0110
* PRECONDITION: - D2 MUST CONTAINS ORIGINAL INSTRUCTION FOR FUTHURE DETERMINING
*               - D3 MUST CONTAINS BIT 11 TO 8 OF INSTRUCTION
* POSTCONDITION: - IF THE INSTRUCTION IS DEFINED IN THE REQUIREMENT, THE STRING OF THE RESULT WILL BE
*                  STORED IN OUTPUT MEMORY REGION POINTED BY A2
*                - IF THE INSTRUCTION IS NOT IN THE REQUIREMENT, "BAD DATA" WILL BE STORED IN OUTPUT
*                  MEMORY REGION POINTED BY A2
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

*----------------------------------------------------------------------------------------------------
* SIX0000: DISASSEMBLE THE HEXADECIMAL INSTRUCTION THAT HAS BIT 11 TO 8 EQUAL TO 0000
*----------------------------------------------------------------------------------------------------
SIX0000       	MOVE.B		#'B', (A2)+     ;THE INSTRUCTION IS "BRA"
				MOVE.B      #'R', (A2)+ 
                MOVE.B      #'A', (A2)+
                BRA         RETURN_SIX      ;RETURN TO TABLESIX

*----------------------------------------------------------------------------------------------------
* SIX0001: HEXADECIMAL INSTRUCTION THAT HAS BIT 11 TO 8 EQUAL TO 0001 IS NOT DEFINED
*----------------------------------------------------------------------------------------------------
SIX0001			JSR         BADDATA
                BRA	    	RETURN_SIX

*----------------------------------------------------------------------------------------------------
* SIX0010: HEXADECIMAL INSTRUCTION THAT HAS BIT 11 TO 8 EQUAL TO 0010 IS NOT DEFINED
*----------------------------------------------------------------------------------------------------
SIX0010			JSR         BADDATA
                BRA	    	RETURN_SIX

*----------------------------------------------------------------------------------------------------
* SIX0011: HEXADECIMAL INSTRUCTION THAT HAS BIT 11 TO 8 EQUAL TO 0011 IS NOT DEFINED
*----------------------------------------------------------------------------------------------------
SIX0011			JSR         BADDATA
                BRA	    	RETURN_SIX

*----------------------------------------------------------------------------------------------------
* SIX0100: DISASSEMBLE THE HEXADECIMAL INSTRUCTION THAT HAS BIT 11 TO 8 EQUAL TO 0100
*----------------------------------------------------------------------------------------------------
SIX0100       	MOVE.B      #'B', (A2)+     ;THE INSTRUCTION IS "BCC"
                MOVE.B      #'C', (A2)+
                MOVE.B      #'C', (A2)+
                BRA         RETURN_SIX      ;RETURN TO TABLESIX

*----------------------------------------------------------------------------------------------------
* SIX0101: DISASSEMBLE THE HEXADECIMAL INSTRUCTION THAT HAS BIT 11 TO 8 EQUAL TO 0101
*----------------------------------------------------------------------------------------------------
SIX0101       	MOVE.B      #'B', (A2)+     ;THE INSTRUCTION IS "BCS"
                MOVE.B      #'C', (A2)+
                MOVE.B      #'S', (A2)+
                BRA         RETURN_SIX      ;RETURN TO TABLESIX

*----------------------------------------------------------------------------------------------------
* SIX0110: HEXADECIMAL INSTRUCTION THAT HAS BIT 11 TO 8 EQUAL TO 0110 IS NOT DEFINED
*----------------------------------------------------------------------------------------------------
SIX0110			JSR         BADDATA
                BRA	    	RETURN_SIX

*----------------------------------------------------------------------------------------------------
* SIX0111: HEXADECIMAL INSTRUCTION THAT HAS BIT 11 TO 8 EQUAL TO 0111 IS NOT DEFINED
*----------------------------------------------------------------------------------------------------
SIX0111			JSR         BADDATA
                BRA	    	RETURN_SIX

*----------------------------------------------------------------------------------------------------
* SIX1000: DISASSEMBLE THE HEXADECIMAL INSTRUCTION THAT HAS BIT 11 TO 8 EQUAL TO 1000
*----------------------------------------------------------------------------------------------------
SIX1000      	MOVE.B      #'B', (A2)+     ;THE INSTRUCTION IS "BVC"
                MOVE.B      #'V', (A2)+ 
                MOVE.B      #'C', (A2)+
                BRA         RETURN_SIX      ;RETURN TO TABLESIX
                
*----------------------------------------------------------------------------------------------------
* SIX1001: HEXADECIMAL INSTRUCTION THAT HAS BIT 11 TO 8 EQUAL TO 1001 IS NOT DEFINED
*----------------------------------------------------------------------------------------------------
SIX1001			JSR         BADDATA
                BRA	   	 	RETURN_SIX

*----------------------------------------------------------------------------------------------------
* SIX1010: HEXADECIMAL INSTRUCTION THAT HAS BIT 11 TO 8 EQUAL TO 1010 IS NOT DEFINED
*----------------------------------------------------------------------------------------------------
SIX1010			JSR         BADDATA
                BRA	  	  	RETURN_SIX

*----------------------------------------------------------------------------------------------------
* SIX1011: HEXADECIMAL INSTRUCTION THAT HAS BIT 11 TO 8 EQUAL TO 1011 IS NOT DEFINED
*----------------------------------------------------------------------------------------------------
SIX1011			JSR         BADDATA
                BRA	  	  	RETURN_SIX

*----------------------------------------------------------------------------------------------------
* SIX1100: DISASSEMBLE THE HEXADECIMAL INSTRUCTION THAT HAS BIT 11 TO 8 EQUAL TO 1100
*----------------------------------------------------------------------------------------------------
SIX1100       	MOVE.B      #'B', (A2)+     ;THE INSTRUCTION IS "BEG"
                MOVE.B      #'G', (A2)+
                MOVE.B      #'E', (A2)+
                BRA         RETURN_SIX      ;RETURN TO TABLESIX

*----------------------------------------------------------------------------------------------------
* SIX1101: DISASSEMBLE THE HEXADECIMAL INSTRUCTION THAT HAS BIT 11 TO 8 EQUAL TO 1101
*----------------------------------------------------------------------------------------------------
SIX1101         MOVE.B      #'B', (A2)+     ;THE INSTUCTION IS "BLT"
                MOVE.B      #'L', (A2)+
                MOVE.B      #'T', (A2)+
                BRA         RETURN_SIX      ;RETURN TO TABLESIX

*----------------------------------------------------------------------------------------------------
* SIX1110: HEXADECIMAL INSTRUCTION THAT HAS BIT 11 TO 8 EQUAL TO 1110 IS NOT DEFINED
*----------------------------------------------------------------------------------------------------
SIX1110			JSR         BADDATA
                BRA	 	   	RETURN_SIX

*----------------------------------------------------------------------------------------------------
* SIX1111: HEXADECIMAL INSTRUCTION THAT HAS BIT 11 TO 8 EQUAL TO 1111 IS NOT DEFINED
*----------------------------------------------------------------------------------------------------
SIX1111         JSR         BADDATA
                BRA	  	  	RETURN_SIX


*----------------------------------------------------------------------------------------------------
* TABLEELEVEN: THIS IS SUBROUTINE JUMP TABLE. IT IS FOR DETERMINING OPMODE OF THE INSTRUCTION THAT IS
*              STARED WITH 0110
* PRECONDITION: - D2 MUST CONTAINS ORIGINAL INSTRUCTION FOR FUTHURE DETERMINING
*               - D3 MUST CONTAINS BIT 8, 7, AND 6 OF INSTRUCTION
* POSTCONDITION: - IF THE INSTRUCTION IS DEFINED IN THE REQUIREMENT, THE STRING OF THE RESULT WILL BE
*                  STORED IN OUTPUT MEMORY REGION POINTED BY A2
*                - IF THE INSTRUCTION IS NOT IN THE REQUIREMENT, "BAD DATA" WILL BE STORED IN OUTPUT
*                  MEMORY REGION POINTED BY A2
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
				JSR			ISOR
				BRA			RETURN_ELEVEN
				
ELEVEN001		MOVE.B		#'C', (A2)+
				MOVE.B		#'M', (A2)+
				MOVE.B		#'P', (A2)+
				MOVE.B		#'.', (A2)+
				MOVE.B		#'W', (A2)+
				MOVE.B		#TAB, (A2)+
				JSR			ISOR
				BRA			RETURN_ELEVEN
				
ELEVEN010		MOVE.B		#'C', (A2)+
				MOVE.B		#'M', (A2)+
				MOVE.B		#'P', (A2)+
				MOVE.B		#'.', (A2)+
				MOVE.B		#'B', (A2)+
				MOVE.B		#TAB, (A2)+
				JSR			ISOR
				BRA			RETURN_ELEVEN

*----------------------------------------------------------------------------------------------------
* ELEVEN011: HEXADECIMAL INSTRUCTION THAT HAS BIT 11 TO 8 EQUAL TO 1111 IS NOT DEFINED
*----------------------------------------------------------------------------------------------------	
ELEVEN011		JSR         BADDATA
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
				
ELEVEN111		JSR         BADDATA
                BRA			RETURN_ELEVEN

*----------------------------------------------------------------------------------------------------
* TABLETHIRTEEN: THIS IS FUNCTION FOR DETERMINING THE OPMODE OF THE INSTRUCTION
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
                JSR         ISOR
                BRA         RETURN_THIRTEEN

THIRTEEN001     MOVE.B		#'.', (A2)+
                MOVE.B		#'W', (A2)+
                JSR         ISOR
                BRA         RETURN_THIRTEEN

THIRTEEN010     MOVE.B		#'.', (A2)+
                MOVE.B		#'L', (A2)+
                JSR         ISORL
                BRA         RETURN_THIRTEEN

THIRTEEN011     MOVE.B      #'A', (A2)+
                MOVE.B		#'.', (A2)+
                MOVE.B		#'W', (A2)+
                JSR         ISADDA
                BRA         RETURN_THIRTEEN

THIRTEEN100     MOVE.B		#'.', (A2)+
                MOVE.B		#'B', (A2)+
                JSR         ISOR
                BRA         RETURN_THIRTEEN

THIRTEEN101     MOVE.B		#'.', (A2)+
                MOVE.B		#'W', (A2)+
                JSR         ISOR
                BRA         RETURN_THIRTEEN

THIRTEEN110     MOVE.B		#'.', (A2)+
                MOVE.B		#'L', (A2)+
                JSR         ISORL
                BRA         RETURN_THIRTEEN

THIRTEEN111     MOVE.B      #'A', (A2)+
                MOVE.B		#'.', (A2)+
                MOVE.B		#'L', (A2)+
                JSR         ISADDAL
                BRA         RETURN_THIRTEEN

*----------------------------------------------------------------------------------------------------
* TABLEFOUTEEN: 
*----------------------------------------------------------------------------------------------------             
TABLEFOURTEEN	JMP			FOURTEEN00
				JMP			FOURTEEN01
				JMP			FOURTEEN10
				JMP			FOURTEEN11
RETURN_FOURTEEN	RTS
				
FOURTEEN00		MOVE.B		#'A', (A2)+
				MOVE.B		#'S', (A2)+
				BRA			RETURN_FOURTEEN
				
FOURTEEN01		MOVE.B		#'L', (A2)+
				MOVE.B		#'S', (A2)+
				BRA			RETURN_FOURTEEN
				
FOURTEEN10		JSR			BADDATA
				BRA			RETURN_FOURTEEN
				
FOURTEEN11		MOVE.B		#'R', (A2)+
				MOVE.B		#'O', (A2)+
				BRA			RETURN_FOURTEEN


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
GET_DIRECTION	MOVE.W  	D2, D3
				LSL.L		#7, D3
				LSR.L		#8, D3
				LSR.L		#7, D3
				CMPI.B		#%0, D3
				BEQ			RIGHT
				BRA			LEFT
RETURN_DR		RTS
				
LEFT			MOVE.B		#'L', (A2)+
				BRA			RETURN_DR
				
RIGHT			MOVE.B		#'R', (A2)+
				BRA			RETURN_DR
				
*----------------------------------------------------------------------------------------------------
* BAD DATA: ILLEGAL ADDRESSING MODES USED, APPEND BAD DATA TO A2
*----------------------------------------------------------------------------------------------------
BADDATA         MOVE.B      #'B', (A2)+
                MOVE.B      #'A', (A2)+
                MOVE.B      #'D', (A2)+
                MOVE.B      #' ', (A2)+
                MOVE.B      #'D', (A2)+
                MOVE.B      #'A', (A2)+
                MOVE.B      #'T', (A2)+
                MOVE.B      #'A', (A2)+
                RTS
*----------------------------------------------------------------------------------------------------

TAB             EQU         $09

*----------------------------------------------------------------------------------------------------

                END    START        ; last line of source










*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
