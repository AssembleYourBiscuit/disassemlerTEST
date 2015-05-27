<<<<<<< Updated upstream
=======
<<<<<<< HEAD
*-----------------------------------------------------------
* Title      :
* Written by :
* Date       :
* Description:
*-----------------------------------------------------------

*-----------------------------------------------------------
* Title      :
* Written by :
* Date       :
* Description:
*-----------------------------------------------------------

=======
>>>>>>> origin/master
>>>>>>> Stashed changes
CR          EQU     $0D
LF          EQU     $0A
starting    EQU     $00000400
ending      EQU     $00FFFFFE
outData     EQU     $10000
TAB         EQU         $09




    ORG    $1000
<<<<<<< Updated upstream
=======
<<<<<<< HEAD
START:                  ; first instruction of program
* Put program code here
            MOVEA.L #outData, A2        ;This location is where disassembled instruction is stored

=======
>>>>>>> Stashed changes
    
    
START:                  ; first instruction of program
* Put program code here
            
            MOVEA.L #outData, A2        ;This location is where disassembled instruction is stored
            BRA     WELCOME
<<<<<<< Updated upstream
=======
>>>>>>> origin/master
>>>>>>> Stashed changes
    
welcome     LEA     WelcomeMsg,A1       ;Load welcome message
            MOVE.B  #14,D0              ;Display the welcome message
            TRAP    #15                 ;to the user
            LEA     WrtBy,A1            ;Load the Writen by message
            MOVE.B  #14,D0              ;Display the authority
            TRAP    #15                 ;
            MOVEA   #$0,A1              ;Clear register A1
            LEA     note1,A1            ;Load precondition messages 
            MOVE.B  #14,D0              ;
            TRAP    #15                 ;and
            LEA     note2,A1            ;Display
            MOVE.B  #14,D0              ;the
            TRAP    #15                 ;preconditions
            LEA     note3,A1            ;message
            MOVE.B  #14,D0              ;
            TRAP    #15                 ;
            LEA     note4,A1            ;
            MOVE.B  #14,D0              ;
            TRAP    #15                 ;
<<<<<<< Updated upstream
            
=======
<<<<<<< HEAD
=======
            
>>>>>>> origin/master
>>>>>>> Stashed changes

main        JSR     getStart
            JSR     getEnd              ;After done dealing with starting address, call getEnd
            JSR     LOOPDYDOOP
            JMP     promptCont
*-----------------------------------------------------------------
* GET THE STARTING ADDRESS
*-----------------------------------------------------------------         
getStart    LEA     startLoc,A1         ;Load the prompting message startLoc
            MOVE.B  #14,D0              ;Display the prompt message for the starting location
            TRAP    #15                 ;for the user to enter the starting location
            MOVEA   #$0,A1              ;Clear A1 
            CLR     D6                  ;Clear D6 before using it
            MOVEA.W startAddr,A1        ;Make a pointer point to A1 access data to decode
            MOVE.L  #2,d0               ;Get the user input (user input will store in (A1))
            TRAP    #15                 ;(The length of the user input will store in D1)
            JSR     validate            ;Validate and decode the user input and save the address in D6
            CMP.B   #0,D3               ;Check if the input is invalid (while validating) 0=good,1=bad
            BEQ     checkRangeS         ;If yes (good), check the if the address is within the range
errMsgS     LEA     error,A1            ;Load the error message
            MOVE.B  #14,D0              ;Display the error message
            TRAP    #15                 ;for the user to enter the starting location
            JSR     getStart           

checkRangeS JSR     checkOdd            ;Check if the STARTING address is odd (bad)
            CMP.B   #1,D3               ;Check if the input is not odd (0=even, 1=odd)
            BEQ     errMsgS             ;If =1, then print the input error message
            MOVE.L  #starting,D2        ;Check if the address is less than the 
            CMP.L   D2,D6               ;  specified starting address
            BLT     errMsgS             ;If yes, then print error message and prompt again
            MOVE.L  #ending,D2          ;Check if the address is greater than the 
            CMP.L   D2,D6               ;  specified ending address
            BGT     errMsgS             ;If yes, print input error msg and prompt for input again
            MOVEA.L D6,A6               ;THE STARTING ADDRESS IS VALID, SAVE IT IN A6

checkOdd    CLR.L   D5                  ;Clear D2 
            MOVE.W  D6,D5               ;Copy the address over to D5
            MOVE.L  #$00000002,D2       ;Put #2 into D2
            DIVU    D2,D5               ;Divide the address by 2
            SWAP    D5                  ;Swap the remainder and quotient (to access the remainder)
            CMP.B   #$01,D5             ;Check if the remainder is 1 
            BEQ     badInput            ;If remainder=1, it means the address is odd
            RTS 
*--------------------------------------------------------------
* GET THE ENDING ADDRESS
*--------------------------------------------------------------
getEnd      LEA     endLoc,A1           ;Load the prompting message endLoc
            MOVE.B  #14,D0              ;Display the prompt message for the ending location
            TRAP    #15                 ;for the user to enter the ending location
            MOVEA   #$0,A1              ;clear A1
            CLR     D6                  ;Clear D6 before using it
            MOVEA.W endAddr,A1          ;Make a pointer point to A1 for access data to decode
            MOVE.L  #2,d0               ;Get the user input 
            TRAP    #15                 ;(user input will store in (A1))
            JSR     validate            ;Validate and decode the user input and save decoded addr in D6
            CMP.B   #0,D3               ;Check if the input is invalid (while validating) 0=good,1=bad
            BEQ     checkRangeE         ;If yes (good), check the if the address is within the range
checkRangeE JSR     checkOdd            ;Check if the ENDING address is odd (bad)
            CMP.B   #1,D3               ;Check if the input is not odd (0=even, 1=odd)
            BEQ     errMsgE             ;If =1, then print the input error message
            MOVE.L  #starting,D2        ;Check if the address is less than the 
            CMP.L   D2,D6               ;  specified starting address
            BLT     errMsgE             ;If yes, then print error message and prompt again
            MOVE.L  #ending,D2          ;Check if the address is greater than the 
            CMP.L   D2,D6               ;  specified ending address
            BGT     errMsgE             ;If yes, print input error msg and prompt for input again
            MOVE.L  A6,D2               ;Move the given (user) starting addr to D2 to compare with ending
            CMP.L   D2,D6               ;Check if the address is less than the given starting address
            BLT     errMsgE             ;If yes, print the input error msg and prompt for input again
            MOVEA.L D6,A5               ;THE ENDING ADDRESS IS VALID, SAVE IT IN A5
            RTS            
errMsgE     LEA     error,A1            ;Load the error message
            MOVE.B  #14,D0              ;Display the error message
            TRAP    #15                 ;for the user to enter the starting location
            JSR     getEnd 
*---------------------------------------------------------------------
* VALIDATE EACH DIGITS OF THE USER INPUT AND DECODE INTO ACTUAL VALUE
* -- Check if the user input is not NULL or greater than 8 digits
* -- Check each character if it is valid. If valid, decode it.
* NOTE:
*   --Using D5 to temporary store each digit to validate
*   --Using D6 to store the converted address
*   --Using D3 to store the good(0) and bad(1) inputs
*---------------------------------------------------------------------
validate    MOVEQ   #$0,D2              ;Set D2 to 0 to compare if the input is null 
            CMP.B   D2,D0               ;Is the length of the user input = 0?
            BEQ     badInput            ;If yes return badInput
            CMPI    #$8,D0              ;Check if the length of the user input is 
            BGT     badInput            ;greater than 8 character. If yes, badInput
valLoop     MOVE.B  (A1),D5             ;Validation Loop, validate character by character
            CMP.B   D2,D5               ;Check if the next character is null
            BEQ     badInput            ;If null, return bad input
            CMP.B   #$66,D5             ;66 is ascii value of character 'f', highest in the valid range 
            BGT     badInput            ;If this digit is greater than 66
            CMP.B   #$60,D5             ;
            BGT     conLCase            ;
            CMP.B   #$46,D5             ;greater than 46?
            BGT     badInput            ;yes, then it's bad b/c it's between 'F' and 'a'
            CMP.B   #$40,D5             ;greater than 40?
            BGT     conUCase
            CMP.B   #$39,D5             ;is this number is geater than 9?
            BGT     badInput
            CMP.B   #$29,D5
            BGT     conNum
            
conLCase    SUB.B   #$57,D5              ;Convert the ASCII value of lower-case to actual value
            BRA     converted           ;After converted branch to converted to save
conUCase    SUB.B   #$37,D5              ;Convert the ASCII value of Upper-case to actual value
converted   ASL.L   #4,D6               ;Arithmetic Shift Left, shif the 4 bits to the left (4zeros added at the end)
            ADD.B   D5,D6               ;Now replace the 4 bits (0000) with the actual value
            ADDQ    #1,A1               ;Increment the address pointer, point to the next digit
            SUB.B   #1,D1               ;Decrement the length of the user input string
            CMP.B   #0,D1               ;Check if the length is 0 (done with all the digits?)
            BEQ     goodInput           ;If yes, give signal as good input
            BRA     valLoop             ;Else, keep validating the next digit
conNum      SUB.B   #$30,D5             ;Convert the ASCII value of number to actual number
            ASL.L   #4,D6               ;Arithmetic Shift Left, shif the 4 bits to the left (4zeros added at the end)
            ADD.B   D5,D6               ;Now replace the 4 bits (0000) with the actual number
            ADDQ    #1,A1               ;Increment the address pointer, point to the locatin of the next digit
            SUB.B   #1,D1               ;Decrement the length of the user input string
            CMP.B   #0,D1               ;Check if the length is 0 (done with all the digits?)
            BEQ     goodInput           ;If yes, give signal as good input
            BRA     valLoop             ;Else, keep validating the next digit
badInput    MOVEQ   #$1,D3              ;Give bad signal by
            RTS                         ;Put #1 into D3 to represent the bad input
goodInput   MOVEQ   #$0,D3              ;Give good signal by
            RTS                         ;Put #0 into D3 to represent the good input
*----------------------END VALIDATION/DECODING------------------------------------


promptCont  LEA     AskToCont,A1
            MOVE.B  #14,D0
            TRAP    #15
            MOVEA.w string,A1           ;put 800 in register to use to point to the memory
            MOVE.B  #2, d0
            TRAP    #15
            CMP.B   #$79, (A1)          ;Check if the user enter 'y'
            BEQ     main                ;If yes, branch to getaddress
            CMP.B   #$59, (A1)          ;Check if the user enter 'Y'
            BEQ     main                ;If yes, branch to getaddress
            CMP.B   #$6e, (A1)          ;Check if the user input is 'n'
            BEQ     end                 ;If yes, brach to end
            CMP.B   #$4e, (A1)          ;Check if the user input is 'N'
            BEQ     end                 ;If yes, branch to end        
    

end         LEA     ThxMsg,A1           ;Load the Thank-you message
            MOVE.B  #14,D0              ;Print it out
            TRAP    #15    
            MOVE.B  #9, d0          
            TRAP    #15

           



*******************************************************************************************************************************************************
LOOPDYDOOP          MOVEA.L A2, A1
                    JSR     DISASSEMBLE 
                    MOVE.B  #$0D, (A2)+
                    MOVE.B  #$0A, (A2)+
                    MOVE.B  #$0, (A2)+
                    MOVE.B  #14, D0
                    TRAP    #15
                    CMP.L   A5, A6
                    BNE     LOOPDYDOOP
                    RTS





                    



*----------------------------------------------------------------------------------------------------
* DISASSEMBLE: DISASSEMBLE HEXADECIMAL INSTRUCTION CODE TO MNEMONIC INSTRUCTION
* PRECONDITION: - D2 AND D3 MUST NOT BE IN USED
- A2 STORES AN APPROPRIATE MEMORY REGION ADDRESS
*               - A6 STORES AN APPROPRIATE STARTING ADDRESS
* POSTCONDITION: - IF THE INSTRUCTION IS DEFINED IN THE REQUIREMENT, THE STRING OF THE RESULT WILL BE
*                  STORED IN OUTPUT MEMORY REGION POINTED BY A2
*                - IF THE INSTRUCTION IS NOT IN THE REQUIREMENT, FOR NOW IT WILL BE IGNORED
*----------------------------------------------------------------------------------------------------

DISASSEMBLE     MOVE.M      (A6), D2        ;RETRIEVE ORIGINAL INSTRUCTION TO D2 (NO CHANGE ALLOWED)
MOVE.M      D2, D3          ;COPY ORIGINAL INSTRUCTION TO D3 (CHANGE ALLOW)

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
;JSR         ISBCLR
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
;JSR         ISMOVE          ;CALL ISMOVEB TO DISASSEMBLE EFFECTIVE ADDRESS
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
;JSR         ISMOVE
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
BEQ         LEA             ;IF IT IS EQUAL, THE INSTRUCTION IS "LEA"

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
;JSR         ISSUBQ
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
CODE1101		MOVE.B		#$'A', (A2)+
MOVE.B		#$'D', (A2)+
MOVE.B		#$'D', (A2)+

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
TABLETHIRTEEEN  JMP         THIRTEEN000
JMP         THIRTEEN001
JMP         THIRTEEN010
JMP         THIRTEEN011
JMP         THIRTEEN100
JMP         THIRTEEN101
JMP         THIRTEEN110
JMP         THIRTEEN111
RETURN_THIRTEEN RTS


THIRTEEN000     MOVE.B		#$'.', (A2)+
MOVE.B		#$'B', (A2)+
;JSR         ISADD
BRA         RETURN_THIRTEEN

THIRTEEN001     MOVE.B		#$'.', (A2)+
MOVE.B		#$'W', (A2)+
;JSR         ISADD
BRA         RETURN_THIRTEEN

THIRTEEN010     MOVE.B		#$'.', (A2)+
MOVE.B		#$'L', (A2)+
;JSR         ISADD
BRA         RETURN_THIRTEEN

THIRTEEN011     MOVE.B      #$'A', (A2)+
MOVE.B		#$'.', (A2)+
MOVE.B		#$'W', (A2)+
;JSR         ISADDA
BRA         RETURN_THIRTEEN

THIRTEEN100     MOVE.B		#$'.', (A2)+
MOVE.B		#$'B', (A2)+
;JSR         ISADD
BRA         RETURN_THIRTEEN

THIRTEEN101     MOVE.B		#$'.', (A2)+
MOVE.B		#$'W', (A2)+
;JSR         ISADD
BRA         RETURN_THIRTEEN

THIRTEEN110     MOVE.B		#$'.', (A2)+
MOVE.B		#$'L', (A2)+
;JSR         ISADD
BRA         RETURN_THIRTEEN

THIRTEEN111     MOVE.B      #$'A', (A2)+
MOVE.B		#$'.', (A2)+
MOVE.B		#$'L', (A2)+
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

<<<<<<< Updated upstream
=======
<<<<<<< HEAD


*-----------------------------------------------------------
* Title      :EA
* Written by :Nicolas Michael
* Date       :5/19/2015
* Description:Completed EA codes for testing
*-----------------------------------------------------------
=======
>>>>>>> Stashed changes

*---------------------------------------------------------------------------------------------------------
*IS MULS           TO BE CALLED IF CURRENT INSTRUCTION POINTED TO BY A6 IS A KNOWN MULS COMMAND. APPENDS
*                  ADDRESSING MODES TO END OF CURRENT COMMAND STRING
*
*PRE CONDITIONS -  A6 POINTS TO START OF MOVE COMMAND. A2 POINTS TO LOCATION AFTER MOVE STRING AND TAB
*
*POST CONDITIONS - A6 POINTS TO NEXT COMMAND TO BE DISASSEMBLED. A2 POINTS TO NEXT LOCATION TO BE APPENDED,
*                  DELIMETER SHOULD BE ADDED TO THIS LOCATION IMMEDIATELY. ALL OTHER ADDRESS AND DATA
*                  REGISTERS ARE PRESERVED
*---------------------------------------------------------------------------------------------------------
ISMULS      MOVEM.L     D0-D7/A0/A1/A3-A5, $400          *SAVE JEENS REGISTERS AT $400
            JSR         CLRALLDREG                       *CLEAR REGISTERS FOR USE
            MOVE.W      (A6)+, D0
            JSR         GETMOVEREG
            JSR         ERRORCHECK                       *CHECK FOR ERRORS, $BEEF AT $456 IF ERRORS EXISTS
            MOVE.B      #0, D3
            JSR         SWAP
            JSR         ERRORCHECK
            CMP.W       #$BEEF, $456                     *IF $BEEF, APPEND BAD DATA STRING TO A2
            BEQ         BADMULDATA
            JSR         SWAP
            JSR         APPENDEA
            JSR         SWAP                             *ELSE APPEND SRC AE
            MOVE.B      #',', (A2)+
            MOVE.B      #' ', (A2)+
            JSR         APPENDEA                         *APPEND DESTINATION EA
RTN_BADMUL  MOVEM.L     $400, D0-D7/A0/A1/A3-A5          *RESTORE JEENS REGISTERS
            MOVE.L      #0, D6
            MOVE.L      #0, D7
            RTS

*---------------------------------------------------------------------------------------------------------
*MOVE BAD DATA - BAD DATA FOUND, CLEANUP AND RETURN
*---------------------------------------------------------------------------------------------------------
BADMULDATA  JSR         BADDATA
            JMP         RTN_BADMUL

*---------------------------------------------------------------------------------------------------------
*IS SUBQ           TO BE CALLED IF CURRENT INSTRUCTION POINTED TO BY A6 IS A KNOWN SUBQ COMMAND. APPENDS
*                  ADDRESSING MODES TO END OF CURRENT COMMAND STRING
*
*PRE CONDITIONS -  A6 POINTS TO START OF MOVE COMMAND. A2 POINTS TO LOCATION AFTER MOVE STRING AND TAB
*
*POST CONDITIONS - A6 POINTS TO NEXT COMMAND TO BE DISASSEMBLED. A2 POINTS TO NEXT LOCATION TO BE APPENDED,
*                  DELIMETER SHOULD BE ADDED TO THIS LOCATION IMMEDIATELY. ALL OTHER ADDRESS AND DATA
*                  REGISTERS ARE PRESERVED
*---------------------------------------------------------------------------------------------------------
ISSUBQ      MOVEM.L     D0-D7/A0/A1/A3-A5, $400          *SAVE JEENS REGISTERS AT $400
            JSR         CLRALLDREG                       *CLEAR REGISTERS FOR USE
            MOVE.W      (A6)+, D0
            JSR         GETMOVEREG
            JSR         ERRORCHECK                       *CHECK FOR ERRORS, $BEEF AT $456 IF ERRORS EXISTS
            CMP.W       #$BEEF, $456                     *IF $BEEF, APPEND BAD DATA STRING TO A2
            BEQ         BADQDATA
            JSR         SWAP
            MOVE.B      #'#', (A2)+
            JSR         APPENDDISPLACE
            JSR         SWAP                             *ELSE APPEND SRC AE
            MOVE.B      #',', (A2)+
            MOVE.B      #' ', (A2)+
            JSR         APPENDEA                         *APPEND DESTINATION EA
RTN_BADQ    MOVEM.L     $400, D0-D7/A0/A1/A3-A5          *RESTORE JEENS REGISTERS
            MOVE.L      #0, D6
            MOVE.L      #0, D7
            RTS

*---------------------------------------------------------------------------------------------------------
*MOVE BAD DATA - BAD DATA FOUND, CLEANUP AND RETURN
*---------------------------------------------------------------------------------------------------------
BADQDATA    JSR         BADDATA
            JMP         RTN_BADQ

*---------------------------------------------------------------------------------------------------------
*IS ADDA           TO BE CALLED IF CURRENT INSTRUCTION POINTED TO BY A6 IS A KNOWN ADDA COMMAND. APPENDS
*                  ADDRESSING MODES TO END OF CURRENT COMMAND STRING
*
*PRE CONDITIONS -  A6 POINTS TO START OF MOVE COMMAND. A2 POINTS TO LOCATION AFTER MOVE STRING AND TAB
*
*POST CONDITIONS - A6 POINTS TO NEXT COMMAND TO BE DISASSEMBLED. A2 POINTS TO NEXT LOCATION TO BE APPENDED,
*                  DELIMETER SHOULD BE ADDED TO THIS LOCATION IMMEDIATELY. ALL OTHER ADDRESS AND DATA
*                  REGISTERS ARE PRESERVED
*---------------------------------------------------------------------------------------------------------
ISADDAL     MOVE.L      #1, D6                           *INDICATES LONG DATA
            JSR         ISADDA
            RTS
ISADDA      MOVEM.L     D0-D7/A0/A1/A3-A5, $400          *SAVE JEENS REGISTERS AT $400
            JSR         CLRALLDREG                       *CLEAR REGISTERS FOR USE
            MOVE.W      (A6)+, D0
            JSR         GETMOVEREG
            MOVE.B      #1, D3                           *SET DESTINATION TO ADDRESS REGISTER
            JSR         ERRORCHECK                       *CHECK FOR ERRORS, $BEEF AT $456 IF ERRORS EXISTS
            JSR         SWAP
            JSR         ERRORCHECK
            JSR         SWAP
            CMP.W       #$BEEF, $456                     *IF $BEEF, APPEND BAD DATA STRING TO A2
            BEQ         ADDABADDATA
            JSR         APPENDEA
            JSR         SWAP                             *ELSE APPEND SRC AE
            MOVE.B      #',', (A2)+
            MOVE.B      #' ', (A2)+
            JSR         APPENDEA                         *APPEND DESTINATION EA
RTN_BADA    MOVEM.L     $400, D0-D7/A0/A1/A3-A5          *RESTORE JEENS REGISTERS
            MOVE.L      #0, D6
            MOVE.L      #0, D7
            RTS

*---------------------------------------------------------------------------------------------------------
*MOVE BAD DATA - BAD DATA FOUND, CLEANUP AND RETURN
*---------------------------------------------------------------------------------------------------------      
ADDABADDATA JSR         BADDATA
            JMP         RTN_BADA     
                           
*---------------------------------------------------------------------------------------------------------
*IS BCLR           TO BE CALLED IF CURRENT INSTRUCTION POINTED TO BY A6 IS A KNOWN BCLR COMMAND. CAN BE 
*                  CALLED REGARDLESS OF SIZE CODE. EA WILL BE THE SAME FOR BOTH BYTE AND LONG MODES
*
*PRE CONDITIONS -  A6 POINTS TO START OF MOVE COMMAND. A2 POINTS TO LOCATION AFTER MOVE STRING AND TAB
*
*POST CONDITIONS - A6 POINTS TO NEXT COMMAND TO BE DISASSEMBLED. A2 POINTS TO NEXT LOCATION TO BE APPENDED,
*                  DELIMETER SHOULD BE ADDED TO THIS LOCATION IMMEDIATELY. ALL OTHER ADDRESS AND DATA 
*                  REGISTERS ARE PRESERVED
*---------------------------------------------------------------------------------------------------------   
ISBCLR      MOVEM.L     D0-D7/A0/A1/A3-A5, $400          *SAVE JEENS REGISTERS AT $400
            JSR         CLRALLDREG                       *CLEAR REGISTERS FOR USE
            MOVE.W      (A6)+, D0
            JSR         GETMOVEREG                                               
            JSR         SWAP
            CMPI.B      #6, D1
            BNE         IMSOURCE
            MOVE.B      #0, D1
RTN_IMSRC   JSR         ERRORCHECK
            JSR         SWAP
            JSR         ERRORCHECK
            JSR         SWAP
            CMP.W       #$BEEF, $456                     *IF $BEEF, APPEND BAD DATA STRING TO A2
            BEQ         BCLRBADDATA
            JSR         APPENDEA 
            JSR         SWAP                             *ELSE APPEND SRC AE
            MOVE.B      #',', (A2)+
            MOVE.B      #' ', (A2)+
            JSR         APPENDEA                         *APPEND DESTINATION EA
RTN_BCLRBAD MOVEM.L     $400, D0-D7/A0/A1/A3-A5          *RESTORE JEENS REGISTERS
            MOVE.L      #0, D6
            MOVE.L      #0, D7
            RTS 
            
IMSOURCE    MOVE.B      #7, D1
            MOVE.B      #4, D0
            JMP         RTN_IMSRC

*---------------------------------------------------------------------------------------------------------
*MOVE BAD DATA - BAD DATA FOUND, CLEANUP AND RETURN
*---------------------------------------------------------------------------------------------------------      
BCLRBADDATA JSR         BADDATA
            JMP         RTN_BCLRBAD
          

*---------------------------------------------------------------------------------------------------------
*IS BRA            TO BE CALLED IF CURRENT INSTRUCTION POINTED TO BY A6 IS A KNOWN BRA OR BRA FAMILY COMMAND. 
*                  APPENDS ADDRESSING OF NEXT INSTRUCTION TO BE EXECUTED TO A2
*
*PRE CONDITIONS -  A6 POINTS TO START OF MOVE COMMAND. A2 POINTS TO LOCATION AFTER MOVE STRING AND TAB
*
*POST CONDITIONS - A6 POINTS TO NEXT COMMAND TO BE DISASSEMBLED. A2 POINTS TO NEXT LOCATION TO BE APPENDED,
*                  DELIMETER SHOULD BE ADDED TO THIS LOCATION IMMEDIATELY. ALL OTHER ADDRESS AND DATA 
*                  REGISTERS ARE PRESERVED
*---------------------------------------------------------------------------------------------------------
ISBRA           MOVEM.L     D0-D7/A0/A1/A3-A5, $400          *SAVE JEENS REGISTERS AT $400
                JSR         CLRALLDREG                       *CLEAR REGISTERS FOR USE
                MOVE.L      A6, D1                           *PC ADDRESS
                ADDQ        #2, D1                           *ADD 2 TO PC ADDRESS
                MOVE.W      (A6)+, D0
                JSR         GETDISPLACEMENT                                               
                CMPI.B      #0, D0
                BEQ         BITDISPLACE                      *IF SIXTEEN BIT DISPLACEMENT GET NEXT WORD
RTN_16BIT       ADD.L       D0, D1
                JSR         APPENDDISPLACE                   *APPEND DESTINATION EA
                MOVEM.L     $400, D0-D7/A0/A1/A3-A5          *RESTORE JEENS REGISTERS
                MOVE.L      #0, D6
                MOVE.L      #0, D7
                RTS

*---------------------------------------------------------------------------------------------------------
*GET DISPLACEMENT - SHIFTS CURRENT WORD TO EXTRACT 8 BIT DISPLACEMENT VALUE, CHECK FOR 00 AFTERWARDS
*---------------------------------------------------------------------------------------------------------
GETDISPLACEMENT LSL.W   #8, D0
                LSR.W   #8, D0
                RTS
 
*---------------------------------------------------------------------------------------------------------
*BIT DISPLACEMENT - 8 BIT DISPLACEMENT MUST BE 0, GRAB NEXT WORD TO EXTRACT 16 BIT DISPLACEMENT, HEHE.
*---------------------------------------------------------------------------------------------------------               
BITDISPLACE     MOVE.W      (A6)+, D0
                JMP         RTN_16BIT
<<<<<<< Updated upstream
=======
>>>>>>> origin/master
>>>>>>> Stashed changes

*---------------------------------------------------------------------------------------------------------
*IS MOVEB/W/L      TO BE CALLED IF CURRENT INSTRUCTION POINTED TO BY A6 IS A KNOWN MOVE COMMAND. APPENDS 
*                  ADDRESSING MODES TO END OF CURRENT COMMAND STRING
*
*PRE CONDITIONS -  A6 POINTS TO START OF MOVE COMMAND. A2 POINTS TO LOCATION AFTER MOVE STRING AND TAB
*
*POST CONDITIONS - A6 POINTS TO NEXT COMMAND TO BE DISASSEMBLED. A2 POINTS TO NEXT LOCATION TO BE APPENDED,
*                  DELIMETER SHOULD BE ADDED TO THIS LOCATION IMMEDIATELY. ALL OTHER ADDRESS AND DATA 
*                  REGISTERS ARE PRESERVED
*---------------------------------------------------------------------------------------------------------   
ISMOVEL     MOVE.L      #1, D6                           *INDICATES LONG DATA
<<<<<<< Updated upstream
            JSR         ISMOVE                                                                             
            RTS   
ISMOVE      MOVEM.L     D0-D7/A0/A1/A3-A5, $400          *SAVE JEENS REGISTERS AT $400
=======
<<<<<<< HEAD
            JSR         ISMOVEB                                                                             
            RTS   
ISMOVEB     MOVEM.L     D0-D7/A0/A1/A3-A5, $400          *SAVE JEENS REGISTERS AT $400
=======
            JSR         ISMOVE                                                                             
            RTS   
ISMOVE      MOVEM.L     D0-D7/A0/A1/A3-A5, $400          *SAVE JEENS REGISTERS AT $400
>>>>>>> origin/master
>>>>>>> Stashed changes
            JSR         CLRALLDREG                       *CLEAR REGISTERS FOR USE
            MOVE.W      (A6)+, D0
            JSR         GETMOVEREG                                               
            JSR         ERRORCHECK                       *CHECK FOR ERRORS, $BEEF AT $456 IF ERRORS EXISTS
            JSR         SWAP
            JSR         ERRORCHECK
            JSR         SWAP
            CMP.W       #$BEEF, $456                     *IF $BEEF, APPEND BAD DATA STRING TO A2
            BEQ         MOVEBADDATA
            JSR         APPENDEA 
            JSR         SWAP                             *ELSE APPEND SRC AE
            MOVE.B      #',', (A2)+
            MOVE.B      #' ', (A2)+
            JSR         APPENDEA                         *APPEND DESTINATION EA
RTN_BAD     MOVEM.L     $400, D0-D7/A0/A1/A3-A5          *RESTORE JEENS REGISTERS
            MOVE.L      #0, D6
<<<<<<< Updated upstream
            MOVE.L      #0, D7
=======
<<<<<<< HEAD
=======
            MOVE.L      #0, D7
>>>>>>> origin/master
>>>>>>> Stashed changes
            RTS 

*---------------------------------------------------------------------------------------------------------
*MOVE BAD DATA - BAD DATA FOUND, CLEANUP AND RETURN
*---------------------------------------------------------------------------------------------------------      
MOVEBADDATA JSR         BADDATA
            JMP         RTN_BAD

*---------------------------------------------------------------------------------------------------------
*GET MOVE REGISTERS - PARSES MOVE ADDRESSING REGISTERS AND MODES INTO D0, D1, D2 AND D3 TO BE CHECKED FOR ERROR
*---------------------------------------------------------------------------------------------------------            
GETMOVEREG      MOVE.W  D0, D1
                MOVE.W  D0, D2
                MOVE.W  D0, D3
                LSL.W   #8, D0
                LSL.W   #5, D0
                LSR.W   #8, D0
                LSR.W   #5, D0
                LSL.W   #8, D1
                LSL.W   #2, D1
                LSR.W   #8, D1
                LSR.W   #5, D1
                LSL.W   #4, D2
                LSR.W   #8, D2
                LSR.W   #5, D2
                LSL.W   #7, D3
                LSR.W   #8, D3
                LSR.W   #5, D3
                RTS               
                
*---------------------------------------------------------------------------------------------------------
*ISMOVEMW/L        (IS MOVEM.L AND MOVEM.W)- TO BE CALLED IF CURRENT INSTRUCTION POINTED TO BY A6 IS A 
*                  KNOWN MOVEM COMMAND
*
*PRE CONDITIONS -  A6 POINTS TO START OF MOVEM COMMAND
*
*POST CONDITIONS - A2 POINTS TO NEXT AVAILABLE LOCATION TO ADD NEXT ASCII INSTRUCTION. DO NOT INCREMENT
*                  A2, ALREADY DONE! A6 POINTS TO START OF NEXT COMMAND OR AND OF FILE IF ALL COMMANDS HAVE
*                  BEEN DIASSEMBLED. DO NOT INC A6, ALREADY DONE. ASCII STRINGS HAVE BEEN ADDED TO (A2) IF
*                  NO ERRORS OCCURED. IF ADDRESSING MODES ARE USED THAT ARE NOT SUPPORTED, THE COMMAND 
*                  STRING WILL BE INCORRECT, TO BE FIXED! THE STATE OF ALL OTHER REGISTERS IS UNDETERMINED 
*                  AFTER EXECUTION.
*---------------------------------------------------------------------------------------------------------
<<<<<<< Updated upstream
ISMOVEM       MOVEM.L       D0-D7/A0/A1/A3-A5, $400          *SAVE JEENS REGISTERS AT $400
=======
<<<<<<< HEAD
ISMOVEML      MOVEM.L       D0-D7/A0/A1/A3-A5, $400          *SAVE JEENS REGISTERS AT $400
=======
ISMOVEM       MOVEM.L       D0-D7/A0/A1/A3-A5, $400          *SAVE JEENS REGISTERS AT $400
>>>>>>> origin/master
>>>>>>> Stashed changes
              JSR           CLRALLDREG                       *CLEAR REGISTERS FOR MOVEM
              JSR           SETEAREGISTERS
              JSR           ERRORCHECK
              CMP.W         #$BEEF, $456                     *IF $BEEF, APPEND BAD DATA STRING TO A2
              BEQ           MMBADDATA 
              JSR           GETLISTMASK
              CMPI.B        #1, D4
              BEQ           MMAPPEA1
              JSR           MMAPPEA0
<<<<<<< Updated upstream
RTN_1DIR      MOVEM.L       $400, D0-D7/A0/A1/A3-A5          *RESTORE JEENS REGISTERS  
              MOVE.L      #0, D6
              MOVE.L      #0, D7   
=======
<<<<<<< HEAD
RTN_1DIR      MOVEM.L       $400, D0-D7/A0/A1/A3-A5          *RESTORE JEENS REGISTERS     
=======
RTN_1DIR      MOVEM.L       $400, D0-D7/A0/A1/A3-A5          *RESTORE JEENS REGISTERS  
              MOVE.L      #0, D6
              MOVE.L      #0, D7   
>>>>>>> origin/master
>>>>>>> Stashed changes
              RTS 

*---------------------------------------------------------------------------------------------------------
*MOVE BAD DATA - BAD DATA FOUND, CLEANUP AND RETURN
*---------------------------------------------------------------------------------------------------------      
MMBADDATA   JSR         BADDATA
            JMP         RTN_1DIR 

*-----------------------------------------------------------------------------------------------------------
*MOVEM APPEND ADDRESS DIRECTION 0 (REG TO MEM) - APPENDS ADDRESSES ACCORDING TO DIRECTION REG TO MEM
*-----------------------------------------------------------------------------------------------------------
MMAPPEA0      MOVEM.W      D0-D7, $500                      *SAVE MY PRECIOUS REGISTERS
              JSR          APPLISTRTM
              MOVEM.W      $500, D0-D7
              MOVE.B       #',', (A2)+
              MOVE.B       #' ', (A2)+
              JSR          APPENDEA
              RTS

*-----------------------------------------------------------------------------------------------------------
*MOVEM APPEND ADDRESS DIRECTION 1 (MEM TO REG) - APPENDS ADDRESSES ACCORDING TO DIRECTION MEM TO REG
*-----------------------------------------------------------------------------------------------------------
MMAPPEA1      JSR          APPENDEA
              MOVE.B       #',', (A2)+
              MOVE.B       #' ', (A2)+
              JSR          APPLISTRTM
              JMP          RTN_1DIR     

*-----------------------------------------------------------------------------------------------------------
*APPEND LIST - APPENDS SOURCE LIST OF REGISTERS TO COMMAND STRING IN THE FORMAT AN/DN OR DN/AN IF ADDRESS 
*              INDIRECT PRE DECREMENT IS USED FOR DESTINATION ADDRESSING MODE. DOES NOT USE DASH (-) SYMBOL. 
*              IF THERE'S TIME, I WILL ADD.
*-----------------------------------------------------------------------------------------------------------                
APPLISTRTM      CMPI.B        #4, D1              *DIESTINATION IS ADDRESS INDIRECT PRE DECREMEMNT
                BEQ           BACKWARDLIST
                CMPI.B        #2, D1              *DESTINATION IS ADDRESS INDIRECT
                BEQ           FORWARDLIST
                CMPI.B        #7, D1              *DESTINATION IS  ABSOLUTE WORD OR LONG
                BEQ           FORWARDLIST
RTN_LIST        RTS

*-----------------------------------------------------------------------------------------------------------
*FORWARD LIST - FOR LOOP USED TO APPEND REGISTER STRINGS FOR EXAMPLE "A7/A6/D3/D1/D0"
*-----------------------------------------------------------------------------------------------------------
FORWARDLIST     MOVE.W  #0015, D1           *BIG UGLY FOR LOOP
                MOVE.W  #0000, D0
                MOVE.W  #0000, D2
FRWRDLOOP       LSL.W   #1, D3              *SHIFT FIELD MASK, CARRY WILL BE SET IF REGISTER SHOULD BE APPENDED
                BCS     APPENDDORAF         *WAS THERE CARRY?
RTN_APPDF       SUBI.B  #1, D1              *DECREMENT 
                CMP.B   D0, D1              *IS GREATER THAN OR EQUAL? FOR(INT D0 = 15; D1 >= D0; D1--)
                BGE     FRWRDLOOP
                JMP     RTN_LIST 

*-----------------------------------------------------------------------------------------------------------
*APPEND D OR A (FORWARD LOOP) - APPENDS STRING D OR A DEPENDING ON FOR LOOP COUNT
*-----------------------------------------------------------------------------------------------------------
APPENDDORAF     CMPI.B  #7, D1
                BGT     APPAF
                MOVE.B  #'D', (A2)+
                ADDI.B  #48, D2
                ADD.B   D1, D2
                MOVE.B  D2, (A2)+
RTN_APPAF       CMP.W   #0, D3
                BEQ     RTN_SLASHF
                JMP     APPENDSLASHF
RTN_SLASHF      CLR     D2
                JMP     RTN_APPDF            *END BIG UGLY FOR LOOP

*-----------------------------------------------------------------------------------------------------------
*APPEND SLASH (FORWARD LOOP) - APPENDS A SLASH (/) TO COMMAND STRING IS MORE REGISTERS ARE TO BE PRINTED
*-----------------------------------------------------------------------------------------------------------
APPENDSLASHF    MOVE.B  #$2F, (A2)+     *ADD SLASH = 2F IN HEX
                JMP     RTN_SLASHF 
                
APPAF           MOVE.B  #'A', (A2)+
                ADDI.B  #40, D2
                ADD.B   D1, D2
                MOVE.B  D2, (A2)+
                JMP     RTN_APPAF

*-----------------------------------------------------------------------------------------------------------
*BACKWARDS LIST - SAME AS BEFORE BUT WE HAVE TO GO THE OTHER WAY FOR(INT D0 = 0; D0 <= D1; D0++)
*-----------------------------------------------------------------------------------------------------------
BACKWARDLIST    MOVE.W  #0015, D1             *BIG UGLY FOR LOOP
                MOVE.W  #0000, D0
                MOVE.W  #0000, D2
BCKWRDLOOP      LSL.W   #1, D3
                BCS     APPENDDORA
RTN_APPD        ADDI.B  #1, D0
                CMP     D1, D0
                BLE     BCKWRDLOOP
                JMP     RTN_LIST 

*-----------------------------------------------------------------------------------------------------------
*APPEND D OR A - SAME AS ABOVE BUT DIFFERENT REGISTERS WERE USED...I SHOULDN'T HAVE DONE THAT...
*-----------------------------------------------------------------------------------------------------------             
APPENDDORA      CMPI.B  #7, D0
                BGT     APPA
                MOVE.B  #'D', (A2)+
                ADDI.B  #48, D2
                ADD.B   D0, D2
                MOVE.B  D2, (A2)+
RTN_APPA        CMP.W   #0, D3
                BEQ     RTN_SLASH
                JMP     APPENDSLASH
RTN_SLASH       CLR     D2
                JMP     RTN_APPD            *END BIG UGLY FOR LOOP

*-----------------------------------------------------------------------------------------------------------
*APPEND SLASH - SAME AS ABOVE BUT DIFFERENT REGISTERS ARE USED FOR THE FORWARD LOOP....STUPID....
*-----------------------------------------------------------------------------------------------------------               
APPENDSLASH     MOVE.B  #$2F, (A2)+     *ADD SLASH = 2F IN HEX
                JMP     RTN_SLASH 
                
APPA            MOVE.B  #'A', (A2)+
                ADDI.B  #40, D2
                ADD.B   D0, D2
                MOVE.B  D2, (A2)+
                JMP     RTN_APPA

*-----------------------------------------------------------------------------------------------------------
*GET LIST MASK - MOVES THE LIST MASK FROM MEMORY TO D3 TO BE SHIFTED FOR EACH REGISTER SAVED
*-----------------------------------------------------------------------------------------------------------
GETLISTMASK     MOVE.W  (A6)+, D3      *THANKS!
                RTS     
              
*-----------------------------------------------------------------------------------------------------------
*SET EA REGISTERS - PUTS THE DIRECTION, MODE, AND REGISTER ID D4, D5, AND D6 TO BE CHECKED FOR ERRORS AND W/E
*-----------------------------------------------------------------------------------------------------------
SETEAREGISTERS  MOVE.W (A6)+, D4       *COPY COMMAND INTO D4, 5 AND 6 TO BE PARSED
                MOVE.W  D4, D1         *FOR DIRECTION, MODE AND REG
                MOVE.W  D4, D0  
                LSL.W   #5, D4         *SHIFTING FOR DIRECTION
                LSR.W   #8, D4
                LSR.W   #7, D4
                LSL.W   #8, D1         *SHIFTING FOR MODE
                LSL.W   #2, D1
                LSR.W   #8, D1
                LSR.W   #5, D1
                LSL.W   #8, D0         *SHIFTING FOR REGISTER
                LSL.W   #5, D0
                LSR.W   #8, D0
                LSR.W   #5, D0
                RTS

*---------------------------------------------------------------------------------------------------------
*isLEA            (IS LEA)- TO BE CALLED IF CURRENT INSTRUCTION POINTED TO BY A6 IS A KNOWN LEA COMMAND
*
*PRE CONDITIONS -  A6 POINTS TO START OF LEA COMMAND
*
*POST CONDITIONS - A2 POINTS TO NEXT AVAILABLE LOCATION TO ADD NEXT ASCII INSTRUCTION. DO NOT INCREMENT
*                  A2, ALREADY DONE! A6 POINTS TO START OF NEXT COMMAND OR AND OF FILE IF ALL COMMANDS HAVE
*                  BEEN DIASSEMBLED. DO NOT INC A6, ALREADY DONE. ASCII STRINGS HAVE BEEN ADDED TO (A2) IF
*                  NO ERRORS OCCURED. THE STATE OF ALL OTHER REGISTERS IS EXACTLY HOW THEY WERE BEFORE CALLING THIS
*---------------------------------------------------------------------------------------------------------
<<<<<<< Updated upstream
ISLEA            MOVEM.L     D0-D7/A0/A1/A3-A5, $400          *SAVE JEENS REGISTERS AT $400
=======
<<<<<<< HEAD
isLEA            MOVEM.L     D0-D7/A0/A1/A3-A5, $400          *SAVE JEENS REGISTERS AT $400
=======
ISLEA            MOVEM.L     D0-D7/A0/A1/A3-A5, $400          *SAVE JEENS REGISTERS AT $400
>>>>>>> origin/master
>>>>>>> Stashed changes
                 JSR         CLRALLDREG                           
                 MOVE.W      (A6)+, D0                        *GET CURRENT OP CODE DATA TO D7
                 JSR         GETMOVEREG
                 JSR         ERRORCHECK
                 CMP.W       #$BEEF, $456
                 BEQ         LEABADDATA
                 MOVE.L      #1, D6                           *INDICATES LONG FOR IMMEDIATE ADDRESSING
                 JSR         APPENDEA
                 MOVE.B      #',', (A2)+                      *ADD SPACE BETWEEN ADDRESSES
                 MOVE.B      #' ', (A2)+                      *ADD COMMA BETWEEN ADDRESSES
                 JSR         SWAP
                 MOVE.W      #1, D1
                 JSR         APPENDEA
LEARTN           MOVEM.L     $400, D0-D7/A0/A1/A3-A5
                 MOVE.L      #0, D6
<<<<<<< Updated upstream
                 MOVE.L      #0, D7
=======
<<<<<<< HEAD
=======
                 MOVE.L      #0, D7
>>>>>>> origin/master
>>>>>>> Stashed changes
                 RTS

*-----------------------------------------------------------------------------------------------------------
*LEABAD DATA - SETS BEEF FLAG IF BAD DATA
*-----------------------------------------------------------------------------------------------------------
LEABADDATA       JSR         BADDATA
                 JMP         LEARTN
                
*---------------------------------------------------------------------------------------------------------
*IS ORIB/W/L       TO BE CALLED IF CURRENT INSTRUCTION POINTED TO BY A6 IS A KNOWN ORI COMMAND
*
*PRE CONDITIONS -  A6 POINTS TO START OF MOVE COMMAND. A2 POINTS TO LOCATION AFTER MOVE STRING AND TAB
*
*POST CONDITIONS - A6 POINTS TO NEXT COMMAND TO BE DISASSEMBLED. A2 POINTS TO NEXT LOCATION TO BE APPENDED,
*                  DELIMETER SHOULD BE ADDED TO THIS LOCATION IMMEDIATELY. ALL OTHER ADDRESS AND DATA 
*                  REGISTERS ARE PRESERVED. EXCEPT D6, D6 IS GONE....SORRY
*---------------------------------------------------------------------------------------------------------            
ISORIL          MOVE.L      #1, D6                           *INDICATES LONG DATA
<<<<<<< Updated upstream
                JSR         ISORI                                                                             
                RTS   
ISORI           MOVEM.L     D0-D7/A0/A1/A3-A5, $400          *SAVE JEENS REGISTERS AT $400
=======
<<<<<<< HEAD
                JSR         ISORIB                                                                             
                RTS   
ISORIB          MOVEM.L     D0-D7/A0/A1/A3-A5, $400          *SAVE JEENS REGISTERS AT $400
=======
                JSR         ISORI                                                                             
                RTS   
ISORI           MOVEM.L     D0-D7/A0/A1/A3-A5, $400          *SAVE JEENS REGISTERS AT $400
>>>>>>> origin/master
>>>>>>> Stashed changes
                JSR         CLRALLDREG                       *CLEAR REGISTERS FOR USE
                MOVE.W      (A6)+, D0
                JSR         GETMOVEREG                                              
                JSR         ERRORCHECK                        *CHECK FOR ERRORS, $BEEF AT $456 IF ERRORS EXISTS
                CMP.W       #$BEEF, $456                     *IF $BEEF, APPEND BAD DATA STRING TO A2
                BEQ         ORIBADDATA
                JSR         APPENDIMMEDIATE                  *ELSE APPEND SRC AE
                MOVE.B      #',', (A2)+
                MOVE.B      #' ', (A2)+
                JSR         APPENDEA                         *APPEND DESTINATION EA
RTN_BADORI      MOVEM.L     $400, D0-D7/A0/A1/A3-A5          *RESTORE JEENS REGISTERS
                MOVE.L      #0, D6
<<<<<<< Updated upstream
                MOVE.L      #0, D7
=======
<<<<<<< HEAD
=======
                MOVE.L      #0, D7
>>>>>>> origin/master
>>>>>>> Stashed changes
                RTS 

*---------------------------------------------------------------------------------------------------------
*ORI BAD DATA - BAD DATA FOUND, CLEANUP AND RETURN
*---------------------------------------------------------------------------------------------------------      
ORIBADDATA  JSR         BADDATA
            JMP         RTN_BADORI      
                
*---------------------------------------------------------------------------------------------------------
*IS NEGB/W/L       TO BE CALLED IF CURRENT INSTRUCTION POINTED TO BY A6 IS A KNOWN NEG COMMAND
*
*PRE CONDITIONS -  A6 POINTS TO START OF MOVE COMMAND. A2 POINTS TO LOCATION AFTER MOVE STRING AND TAB
*
*POST CONDITIONS - A6 POINTS TO NEXT COMMAND TO BE DISASSEMBLED. A2 POINTS TO NEXT LOCATION TO BE APPENDED,
*                  DELIMETER SHOULD BE ADDED TO THIS LOCATION IMMEDIATELY. ALL OTHER ADDRESS AND DATA 
*                  REGISTERS ARE PRESERVED. EXCEPT D6, D6 IS GONE....SORRY
*---------------------------------------------------------------------------------------------------------             
ISNEGL          MOVE.L      #1, D6                           *INDICATES LONG DATA
<<<<<<< Updated upstream
=======
<<<<<<< HEAD
                JSR         ISNEGB
                RTS
ISNEGB          MOVEM.L     D0-D7/A0/A1/A3-A5, $400          *SAVE JEENS REGISTERS AT $400
                JSR         CLRALLDREG                       *CLEAR REGISTERS FOR USE
                MOVE.W      (A6)+, D0
                JSR         GETMOVEREG                                               
                JSR         ERRORCHECK                        *CHECK FOR ERRORS, $BEEF AT $456 IF ERRORS EXISTS
=======
>>>>>>> Stashed changes
                JSR         ISNEG
                RTS
ISNEG           MOVEM.L     D0-D7/A0/A1/A3-A5, $400          *SAVE JEENS REGISTERS AT $400
                JSR         CLRALLDREG                       *CLEAR REGISTERS FOR USE
                MOVE.W      (A6)+, D0
                JSR         GETMOVEREG                                               
                JSR         ERRORCHECK                       *CHECK FOR ERRORS, $BEEF AT $456 IF ERRORS EXISTS
<<<<<<< Updated upstream
=======
>>>>>>> origin/master
>>>>>>> Stashed changes
                CMP.W       #$BEEF, $456                     *IF $BEEF, APPEND BAD DATA STRING TO A2
                BEQ         NEGBADDATA
                JSR         APPENDEA                         *APPEND DESTINATION EA
RTN_NEGERR      MOVEM.L     $400, D0-D7/A0/A1/A3-A5
                MOVE.L      #0, D6
<<<<<<< Updated upstream
                MOVE.L      #0, D7
=======
<<<<<<< HEAD
=======
                MOVE.L      #0, D7
>>>>>>> origin/master
>>>>>>> Stashed changes
                RTS

*---------------------------------------------------------------------------------------------------------
*ORI BAD DATA - BAD DATA FOUND, CLEANUP AND RETURN
*---------------------------------------------------------------------------------------------------------      
NEGBADDATA  JSR         BADDATA
            JMP         RTN_NEGERR

*---------------------------------------------------------------------------------------------------------
*IS E/ORB/W/L        TO BE CALLED IF CURRENT INSTRUCTION POINTED TO BY A6 IS A KNOWN OR/EOR COMMAND
*
*PRE CONDITIONS -  A6 POINTS TO START OF MOVE COMMAND. A2 POINTS TO LOCATION AFTER MOVE STRING AND TAB
*
*POST CONDITIONS - A6 POINTS TO NEXT COMMAND TO BE DISASSEMBLED. A2 POINTS TO NEXT LOCATION TO BE APPENDED,
*                  DELIMETER SHOULD BE ADDED TO THIS LOCATION IMMEDIATELY. ALL OTHER ADDRESS AND DATA 
*                  REGISTERS ARE PRESERVED. EXCEPT D6...
*---------------------------------------------------------------------------------------------------------
<<<<<<< Updated upstream
=======
<<<<<<< HEAD
ISEORB          MOVE.L      #1, D6                           *INDICATES EXCULIVE OR OPERATION TO THE OR DISASSEMBLER
                JSR         ISORB
                RTS
ISORB           MOVEM.L     D0-D7/A0/A1/A3-A5, $400          *SAVE JEENS REGISTERS AT $400
=======
>>>>>>> Stashed changes
ISEORL          MOVE.L      #1, D6
                JSR         ISEOR   
                RTS
ISORL           MOVE.L      #1, D6
                JSR         ISOR
ISEOR           MOVE.L      #1, D7                           *INDICATES EXCULIVE OR OPERATION TO THE OR DISASSEMBLER
                JSR         ISOR
                RTS
ISOR            MOVEM.L     D0-D7/A0/A1/A3-A5, $400          *SAVE JEENS REGISTERS AT $400
<<<<<<< Updated upstream
=======
>>>>>>> origin/master
>>>>>>> Stashed changes
                JSR         CLRALLDREG                       *CLEAR REGISTERS FOR USE
                MOVE.W      (A6)+, D4
                JSR         PARSEOROP 
                CMPI.B      #2, D4                           *IF OPMODE GREATER THAN 2 DN IS SOURCE
                BGT         PARSEDNSOURCE    
                JSR         PARSEDNDEST                                          
RTN_PARSEOR     JSR         ERRORCHECK                        *CHECK FOR ERRORS, $BEEF AT $456 IF ERRORS EXISTS
                JSR         SWAP
                JSR         ERRORCHECK  
                JSR         SWAP
                CMP.W       #$BEEF, $456                     *IF $BEEF, APPEND BAD DATA STRING TO A2
                BEQ         ORBADDATA
                JSR         APPENDEA                         *APPEND DESTINATION EA
                JSR         SWAP
                MOVE.B      #',', (A2)+
                MOVE.B      #' ', (A2)+
                JSR         APPENDEA
RTN_OR          MOVEM.L     $400, D0-D7/A0/A1/A3-A5
                MOVE.L      #0, D6
<<<<<<< Updated upstream
                MOVE.L      #0, D7
=======
<<<<<<< HEAD
=======
                MOVE.L      #0, D7
>>>>>>> origin/master
>>>>>>> Stashed changes
                RTS

*---------------------------------------------------------------------------------------------------------
*ORI BAD DATA - BAD DATA FOUND, CLEANUP AND RETURN
*---------------------------------------------------------------------------------------------------------      
ORBADDATA   JSR         BADDATA
            JMP         RTN_OR

*---------------------------------------------------------------------------------------------------------
*PARSE OR OP MODE - PARSES THE OPMODE FROM THE COMMAND TO DETERMINE IF DATA REGISTER IS SOURCE OR 
*                   DESTINATION OPERAND
*---------------------------------------------------------------------------------------------------------
PARSEOROP       MOVE.W      D4, D0
                MOVE.W      D4, D1
                MOVE.W      D4, D2
                MOVE.W      D4, D3
                LSL.W       #7, D4
                LSR.W       #8, D4
                LSR.W       #5, D4
                RTS

*---------------------------------------------------------------------------------------------------------
*PARSE DN SOURCE - PARSES ADDRESSING REGISTER AND MODE IF DN IS KNOWN TO BE SOURCE OPERAND
*---------------------------------------------------------------------------------------------------------                
PARSEDNSOURCE   MOVE.W      #0, D1
                LSL.W       #4, D0
                LSR.W       #8, D0
                LSR.W       #5, D0  
                LSL.W       #8, D2
                LSL.W       #5, D2
                LSR.W       #8, D2
                LSR.W       #5, D2
                LSL.W       #8, D3
                LSL.W       #2, D3
                LSR.W       #8, D3
                LSR.W       #5, D3
<<<<<<< Updated upstream
                CMPI.B      #1, D7
=======
<<<<<<< HEAD
                CMPI.B      #1, D6
=======
                CMPI.B      #1, D7
>>>>>>> origin/master
>>>>>>> Stashed changes
                BEQ         RTN_STRGCASE
                JMP         RTN_PARSEOR 

*---------------------------------------------------------------------------------------------------------
*PARSE DN DESTINATION - PARSES ADDRESSING REGISTER AND MODE IF DN IS KNOWN TO BE DESTINATION OPERAND
*---------------------------------------------------------------------------------------------------------
<<<<<<< Updated upstream
PARSEDNDEST     CMPI.B      #1, D7
=======
<<<<<<< HEAD
PARSEDNDEST     CMPI.B      #1, D6
=======
PARSEDNDEST     CMPI.B      #1, D7
>>>>>>> origin/master
>>>>>>> Stashed changes
                BEQ         PARSEDNSOURCE
                MOVE.W      #0, D3
                LSL.W       #4, D2
                LSR.W       #8, D2
                LSR.W       #5, D2  
                LSL.W       #8, D0
                LSL.W       #5, D0
                LSR.W       #8, D0
                LSR.W       #5, D0
                LSL.W       #8, D1
                LSL.W       #2, D1
                LSR.W       #8, D1
                LSR.W       #5, D1
RTN_STRGCASE    RTS

<<<<<<< Updated upstream
=======
<<<<<<< HEAD
=======
>>>>>>> Stashed changes
*---------------------------------------------------------------------------------------------------------
*IS SHIFTY STUFF    TO BE CALLED IF CURRENT INSTRUCTION POINTED TO BY A6 IS A KNOWN LSR,LSL, ASL, ASL, ROR, ROL
*
*PRE CONDITIONS -  A6 POINTS TO START OF LEA COMMAND
*
*POST CONDITIONS - A2 POINTS TO NEXT AVAILABLE LOCATION TO ADD NEXT ASCII INSTRUCTION. DO NOT INCREMENT
*                  A2, ALREADY DONE! A6 POINTS TO START OF NEXT COMMAND OR AND OF FILE IF ALL COMMANDS HAVE
*                  BEEN DIASSEMBLED. DO NOT INC A6, ALREADY DONE. ASCII STRINGS HAVE BEEN ADDED TO (A2) IF
*                  NO ERRORS OCCURED. THE STATE OF ALL OTHER REGISTERS IS EXACTLY HOW THEY WERE BEFORE CALLING THIS
*---------------------------------------------------------------------------------------------------------
ISSHIFTYSTUFF    MOVEM.L     D0-D7/A0/A1/A3-A5, $400          *SAVE JEENS REGISTERS AT $400
                 JSR         CLRALLDREG                           
                 MOVE.W      (A6)+, D0                        *GET CURRENT OP CODE DATA TO D7
                 JSR         SHIFTSIZE
                 JSR         GETMOVEREG
                 JSR         SWAP
                 CMPI.B      #3, D4
                 BEQ         MEMORYSHIFT                           *SHIFT FOR I/R
                 CMPI.B      #3, D3
                 BLE         SETUP 
                 MOVE.B      #0, D1
                 MOVE.B      #0, D3
                 JSR         APPENDEA
RTN_SETUP        MOVE.B      #',', (A2)+                      *ADD SPACE BETWEEN ADDRESSES
                 MOVE.B      #' ', (A2)+                      *ADD COMMA BETWEEN ADDRESSES
                 JSR         SWAP
                 JSR         APPENDEA
RTN_MEMSHIFT     MOVEM.L     $400, D0-D7/A0/A1/A3-A5
                 MOVE.L      #0, D6
                 MOVE.L      #0, D7
                 RTS

*-----------------------------------------------------------------------------------------------------------
*SHIFT BAD DATA DATA - SETS BEEF FLAG IF BAD DATA
*-----------------------------------------------------------------------------------------------------------
SHIFTBADDATA     JSR         BADDATA
                 JMP         RTN_MEMSHIFT

*-----------------------------------------------------------------------------------------------------------
*SHIFT SIZE - SHIFT DATA TO RETRIEVE SIZE DATA
*-----------------------------------------------------------------------------------------------------------                 
SHIFTSIZE        MOVE.W     D0, D4
                 LSL.W      #8, D4
                 LSR.W      #8, D4
                 LSR.W      #6, D4
                 RTS

*-----------------------------------------------------------------------------------------------------------
*MEMORY SHIFT - MEMORY SHIFT DETERMINED, APPEND APPROPRIATELY
*-----------------------------------------------------------------------------------------------------------                 
MEMORYSHIFT     JSR         SHIFTMEM
                JMP         RTN_MEMSHIFT
 
*-----------------------------------------------------------------------------------------------------------
*SHIFT MEMORY - MEMORY SHIFT DETERMINED, CHECK FOR ERRORS AND APPEND STRING TO A2
*-----------------------------------------------------------------------------------------------------------               
SHIFTMEM        JSR         SWAP
                JSR         ERRORCHECK
                CMP.W       #$BEEF, $456         
                BEQ         BADSHIFTYDATA
                JSR         APPENDEA
                RTS

*-----------------------------------------------------------------------------------------------------------
*SET UP - SETS UP REGISTER DATA TO BE PRINTED
*-----------------------------------------------------------------------------------------------------------                
SETUP           MOVE.B      #'#', (A2)+
                MOVE.B      #0, D1
                MOVE.B      #0, D3
                CMPI.B      #0, D0
                BEQ         MAKEZEROEIGHT
RTN_ZE          JSR         APPENDDISPLACE
                JMP         RTN_SETUP
MAKEZEROEIGHT   ADDI.W      #8, D0 
                JMP         RTN_ZE
BADSHIFTYDATA   JSR         BADDATA
                JMP         RTN_MEMSHIFT


<<<<<<< Updated upstream
=======
>>>>>>> origin/master
>>>>>>> Stashed changes
*-----------------------------------------------------------------------------------------------------------
**********************************************SHARED-CODE-SECTION******************************************* 
*-----------------------------------------------------------------------------------------------------------
*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~HEHE~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*
*-----------------------------------------------------------------------------------------------------------
**********************************************SHARED-CODE-SECTION******************************************* 
*-----------------------------------------------------------------------------------------------------------

<<<<<<< Updated upstream
=======
<<<<<<< HEAD
*---------------------------------------------------------------------------------------------------------
*RECOVER POINTER  - RECOVERS A2 IN CASE OF BAD DATA (INSUPPORTED ADDRESSING MODES) DOES THIS MAKE SENSE??
*---------------------------------------------------------------------------------------------------------
RECOVERPTR          CMPI.B      #1, D6
                    BEQ         INCPTRLONG  
                    ADDA        #2, A6
RTN_LONGPTR         RTS
INCPTRLONG          ADDA        #4, A6
                    JMP         RTN_LONGPTR
=======
>>>>>>> origin/master
>>>>>>> Stashed changes
                    
*---------------------------------------------------------------------------------------------------------
*ERROR CHECK - CHECKS ADDRESSING MODES AND ADDRESSING REGISTERS FOR GENERAL ERRORS THAT APPLY TO ALL OP CODES
*---------------------------------------------------------------------------------------------------------            
ERRORCHECK      JSR         CHECKMODE
RTN_REGCHK      RTS
CHECKMODE       CMPI.B      #5, D1
                BEQ         ERROR2
                CMPI.B      #6, D1
<<<<<<< Updated upstream
                BEQ         ERROR2
=======
<<<<<<< HEAD
                BEQ         ERROR
=======
                BEQ         ERROR2
>>>>>>> origin/master
>>>>>>> Stashed changes
                CMPI.B      #7, D1
                BEQ         CHECKREG
                RTS
CHECKREG        CMPI.B      #2, D0
                BEQ         ERROR2
                CMPI.B      #3, D0
                BEQ         ERROR2
                JMP         RTN_REGCHK
ERROR2          MOVE.W      #$BEEF, $456
                JMP         RTN_REGCHK

*---------------------------------------------------------------------------------------------------------
*APPENDS IMMEDIATE  - APPEND IMMEDIATE DATA FROM A6 TO A2 DEPENDING ON WORD OR LONG ADDRESSING MODE
*                     INDICATED BY D6, (1 FOR LONG, 0 FOR WORD)
*---------------------------------------------------------------------------------------------------------                
APPENDIMMEDIATE MOVE.B      #'#', (A2)+
                MOVE.B      #'$', (A2)+
                CMP.B       #1, D6
                BEQ         ISLONG
                JSR         APPENDWORD
                RTS
                
*---------------------------------------------------------------------------------------------------------
*SWAP  - SWAPS D0 AND D1 WITH D2 AND D3 SO ERROR CHECKING CAN BE DONE ONE BOTH SOURCE AND DEST OPERANDS
*---------------------------------------------------------------------------------------------------------
SWAP            EXG         D0, D2
                EXG         D1, D3
                RTS

*---------------------------------------------------------------------------------------------------------
*APPEND EA          - APPENDS ADDRESSES DEPENDING ON ADDRESSING MODES USED
*PRE-CONDITIONS     - ERROR CHECKING HAS BEEN COMPLETED. D0 CONTAINS ADDRESSING REGISTER. D1 CONTAINS
*                     ADDRESSING MODE. d6 contains 1 for immediate long addressing
*---------------------------------------------------------------------------------------------------------           
APPENDEA        CMPI.B      #7, D1
                BEQ         MSWORL
                CMPI.B      #0, D1
                BEQ         MSDREG
                CMPI.B      #1, D1
                BEQ         MSAREG
                CMPI.B      #2, D1
                BEQ         MSAIREG
                CMPI.B      #3, D1
                BEQ         MSAPIREG
                CMPI.B      #4, D1
                BEQ         MSAPDREG
RTN_APPSRC      RTS

*---------------------------------------------------------------------------------------------------------
*APPEND MOVE SOURCE DATA REGISTER - APPENDS DN TO ADDRESS POINTED TO BY A2
*---------------------------------------------------------------------------------------------------------
MSDREG          JSR         APPENDSRCDREG
                JMP         RTN_APPSRC

*---------------------------------------------------------------------------------------------------------
*APPEND MOVE SOURCE ADDRESS REGISTER - APPENDS AN TO ADDRESS POINTED TO BY A2
*---------------------------------------------------------------------------------------------------------                
MSAREG          JSR         APPENDSRCAREG
                JMP         RTN_APPSRC

*---------------------------------------------------------------------------------------------------------
*APPEND MOVE SOURCE ADRESS INDIRECT REGISTER - APPENDS (AN) TO ADDRESS POINTED TO BY A2
*---------------------------------------------------------------------------------------------------------                
MSAIREG         JSR         APPENDSRCAIREG
                JMP         RTN_APPSRC

*---------------------------------------------------------------------------------------------------------
*APPEND MOVE SOURCE ADRESS INDIRECT POST INCREMENT REGISTER - APPENDS (AN)+ TO ADDRESS POINTED TO BY A2
*---------------------------------------------------------------------------------------------------------                
MSAPIREG        JSR         APPENDSRCAPIREG
                JMP         RTN_APPSRC

*---------------------------------------------------------------------------------------------------------
*APPEND MOVE SOURCE ADRESS INDIRECT PRE DECREMENT REGISTER - APPENDS -(AN) TO ADDRESS POINTED TO BY A2
*---------------------------------------------------------------------------------------------------------                
MSAPDREG        JSR         APPENDSRCAPDREG
                JMP         RTN_APPSRC

*---------------------------------------------------------------------------------------------------------
*MOVE SOURCE WORD OR LONG - SOURCE ADDRESSING MODE IS ABSOLUTE WORD OR LONG, APPEND APPROPRIATELY
*---------------------------------------------------------------------------------------------------------                
MSWORL          CMPI.B      #0, D0
                BEQ         MSWORD
                CMPI.B      #1, D0
                BEQ         MSLONG
                CMPI.B      #4, D0
                BEQ         MSIMMEDIATE
                JMP         RTN_APPSRC

*---------------------------------------------------------------------------------------------------------
*MOVE SOURCE IMMEDIATE - SOURCE ADDRESSING MODE IS IMMEDIATE DATA, APPEND APPROPRIATELY
*---------------------------------------------------------------------------------------------------------                
MSIMMEDIATE     MOVE.B      #'#', (A2)+
                MOVE.B      #'$', (A2)+
                CMP.B       #1, D6
                BEQ         ISLONG
                JSR         APPENDWORD
                JMP         RTN_APPSRC

*---------------------------------------------------------------------------------------------------------
*IS LONG - ADDRESSING MODE IS LONG, APPEND APPROPRIATELY
*---------------------------------------------------------------------------------------------------------                
ISLONG          JSR         APPENDLONG
                JMP         RTN_APPSRC

*---------------------------------------------------------------------------------------------------------
*MOVE SOURCE LONG - IS LONG, APPEND APPROPRIATELY
*---------------------------------------------------------------------------------------------------------                
MSLONG          MOVE.B      #'$', (A2)+
                JSR         APPENDLONG
                JMP         RTN_APPSRC

*---------------------------------------------------------------------------------------------------------
*MOVE SOURCE WORD - ADDRESSING MODE IS ABSOLUTE WORD, APPEND APPROPRIATELY
*---------------------------------------------------------------------------------------------------------               
MSWORD          MOVE.B      #'$', (A2)+
                JSR         APPENDWORD
                JMP         RTN_APPSRC

*---------------------------------------------------------------------------------------------------------
*APPEND DATA REGISTER - APPENDS DN TO A2
*---------------------------------------------------------------------------------------------------------
APPENDSRCDREG       MOVE.B      #'D', (A2)+
                    ADDI.B      #48, D0
                    MOVE.B      D0, (A2)+
                    SUBI.B      #48, D0
                    RTS

*---------------------------------------------------------------------------------------------------------
*APPEND ADDRESS REGISTER - APPENDS AN TO A2
*---------------------------------------------------------------------------------------------------------                    
APPENDSRCAREG       MOVE.B      #'A', (A2)+
                    ADDI.B      #48, D0
                    MOVE.B      D0, (A2)+
                    SUBI.B      #48, D0
                    RTS

*---------------------------------------------------------------------------------------------------------
*APPEND ADDRESS REGISTER INDIRECT - APPENDS (AN) TO A2
*---------------------------------------------------------------------------------------------------------                    
APPENDSRCAIREG      MOVE.B      #'(', (A2)+
                    MOVE.B      #'A', (A2)+
                    ADDI.B      #48, D0
                    MOVE.B      D0, (A2)+
                    MOVE.B      #')', (A2)+
                    SUBI.B      #48, D0
                    RTS

*---------------------------------------------------------------------------------------------------------
*APPEND ADDRESS REGISTER POST INCREMENT - APPENDS (AN)+ TO A2
*---------------------------------------------------------------------------------------------------------                     
APPENDSRCAPIREG     MOVE.B      #'(', (A2)+
                    MOVE.B      #'A', (A2)+
                    ADDI.B      #48, D0
                    MOVE.B      D0, (A2)+
                    MOVE.B      #')', (A2)+
                    MOVE.B      #'+', (A2)+
                    SUBI.B      #48, D0
                    RTS
 
*---------------------------------------------------------------------------------------------------------
*APPEND ADDRESS REGISTER PRE DECREMENT - APPENDS -(AN) TO A2
*---------------------------------------------------------------------------------------------------------                    
APPENDSRCAPDREG     MOVE.B      #'-', (A2)+
                    MOVE.B      #'(', (A2)+
                    MOVE.B      #'A', (A2)+
                    ADDI.B      #48, D0
                    MOVE.B      D0, (A2)+
                    MOVE.B      #')', (A2)+
                    SUBI.B      #48, D0
                    RTS

*---------------------------------------------------------------------------------------------------------
<<<<<<< Updated upstream
*CLEA ALL D REG - CLEARS ALL DATA REGISTERS, EXCEPT D6 AND D7....I NEED IT, DONT ASK
=======
<<<<<<< HEAD
*CLEA ALL D REG - CLEARS ALL DATA REGISTERS, EXCEPT D6....I NEED IT, DONT ASK
=======
*CLEA ALL D REG - CLEARS ALL DATA REGISTERS, EXCEPT D6 AND D7....I NEED IT, DONT ASK
>>>>>>> origin/master
>>>>>>> Stashed changes
*--------------------------------------------------------------------------------------------------------- 
CLRALLDREG          CLR         D0
                    CLR         D1
                    CLR         D2
                    CLR         D3
                    CLR         D4
                    CLR         D5
<<<<<<< Updated upstream
=======
<<<<<<< HEAD
                    CLR         D7
=======
>>>>>>> origin/master
>>>>>>> Stashed changes
                    RTS

*---------------------------------------------------------------------------------------------------------
*APPEND LONG - APPENDS THE LONG ABSOLUTE ADDRESS TO A2
*---------------------------------------------------------------------------------------------------------                 
APPENDLONG          JSR         APPENDWORD
                    JSR         APPENDWORD
                    RTS 
 
*---------------------------------------------------------------------------------------------------------
*APPEND WORD - APPENDS THE WORD ABSOLUTE ADDRESS TO A2
*---------------------------------------------------------------------------------------------------------                 
APPENDWORD      MOVEM.L     D0-D7, $400
                JSR         CLRALLDREG
                MOVE.W      (A6)+, D7
                MOVE.W      D7, D0
                MOVE.W      D7, D1
                MOVE.W      D7, D2
                MOVE.W      D7, D3
                LSR.W       #8, D0
                LSR.W       #4, D0
                LSL.W       #4, D1
                LSR.W       #8, D1
                LSR.W       #4, D1
                LSL.W       #8, D2
                LSR.W       #8, D2
                LSR.W       #4, D2
                LSL.W       #8, D3
                LSL.W       #4, D3
                LSR.W       #8, D3
                LSR.W       #4, D3
                JSR         CONVERT
                MOVE.B      D1, D0
                JSR         CONVERT
                MOVE.B      D2, D0
                JSR         CONVERT
                MOVE.B      D3, D0
                JSR         CONVERT
                JSR         CLRALLDREG        
                MOVEM.L     $400, D0-D7
                RTS

*---------------------------------------------------------------------------------------------------------
<<<<<<< Updated upstream
=======
<<<<<<< HEAD
=======
>>>>>>> Stashed changes
*APPEND WORD - APPENDS THE WORD ABSOLUTE ADDRESS TO A2
*---------------------------------------------------------------------------------------------------------                 
APPENDDISPLACE  MOVE.B      #'$', (A2)+
                MOVEM.L     D0-D7, $400
                MOVE.W      D0, D1
                MOVE.W      D0, D2
                MOVE.W      D0, D3
                LSR.W       #8, D0
                LSR.W       #4, D0
                LSL.W       #4, D1
                LSR.W       #8, D1
                LSR.W       #4, D1
                LSL.W       #8, D2
                LSR.W       #8, D2
                LSR.W       #4, D2
                LSL.W       #8, D3
                LSL.W       #4, D3
                LSR.W       #8, D3
                LSR.W       #4, D3
                JSR         CONVERT
                MOVE.B      D1, D0
                JSR         CONVERT
                MOVE.B      D2, D0
                JSR         CONVERT
                MOVE.B      D3, D0
                JSR         CONVERT        
                MOVEM.L     $400, D0-D7
                RTS

*---------------------------------------------------------------------------------------------------------
<<<<<<< Updated upstream
=======
>>>>>>> origin/master
>>>>>>> Stashed changes
*ADD 55 - ADD 55 HEX TO VALUE IN D0 TO CONVERT TO LETTER
*---------------------------------------------------------------------------------------------------------                 
ADD55           ADDI.B      #55, D0
                JMP         RTN_ADD55

*---------------------------------------------------------------------------------------------------------
*ADD 48 - ADD 55 HEX TO VALUE IN D0 TO CONVERT TO NUMBER
*---------------------------------------------------------------------------------------------------------                 
ADD48           ADDI.B      #48, D0
                RTS
*---------------------------------------------------------------------------------------------------------
*CONVERT - CONVERTS VALUE AT D0 BY ADDING 55 OR 48 IF LETTER OR NUMBER
*---------------------------------------------------------------------------------------------------------                
CONVERT         CMPI.B      #$A, D0
                BGE         ADD55 
                JSR         ADD48 
RTN_ADD55       MOVE.B      D0, (A2)+  
                RTS
                
*---------------------------------------------------------------------------------------------------------
*BAD DATA - ILLEGAL ADDRESSING MODES USED, APPEND BAD DATA TO A2, REMOVE BEEF FLAG FROM MEMORY FOR LATER USE
*---------------------------------------------------------------------------------------------------------            
BADDATA         MOVE.B      #'B', (A2)+
                MOVE.B      #'A', (A2)+
                MOVE.B      #'D', (A2)+
                MOVE.B      #' ', (A2)+
                MOVE.B      #'D', (A2)+
                MOVE.B      #'A', (A2)+
                MOVE.B      #'T', (A2)+
                MOVE.B      #'A', (A2)+
                MOVE.W      #$FFFF, $456
                RTS

* Put variables and constants here
*-----------Output texts------------------------------------
WelcomeMsg  DC.b    'Welcome to EASy68K Instruction Disassembler!',CR,LF,0
WrtBy       DC.B    'Created by: Vuochly Ky, Kunlakan Cherdchusilp, Nicolas Michael',CR,LF,CR,LF,0
note1       DC.B    'Preconditions: ',CR,LF,0
note2       DC.B    '   -- The address inputs must be in hexadecimal number (without $)',CR,LF,0
note3       DC.B    '   -- Addresses must be in the range of 0 ~ 00FFFFFE',CR,LF,0
note4       DC.B    '   -- Both starting and ending address must be even addresses',CR,LF,0
startLoc    DC.B    'Please enter the starting location in hexadecimal format: ',0
endLoc      DC.B    'Please enter the ending location in hexadecimal format: ',0
AskToCont   DC.B    'Would you like to start over? (y/n) :',0
enter       DC.B    'Press ENTER key to see more.',0
ThxMsg      DC.B    'Thank you for using our EASy68K Instruction Disassembler!',0
string      DC.W    $80
startAddr   DC.W    $90
endAddr     DC.W    $98
error       DC.B    'The address you entered is whether invalid or out of range.',CR,LF,CR,LF,0
    END    START        ; last line of source



            







<<<<<<< Updated upstream
=======
<<<<<<< HEAD
=======
>>>>>>> Stashed changes




<<<<<<< Updated upstream
=======
>>>>>>> origin/master
>>>>>>> Stashed changes
*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
