*----------------------------------------------------------------------------------------------------
* Title      : OP-CODE PROGRAM
* Written by : KUNLAKAN (JEEN) CHERDCHUSILP
* Date       : 
* Description: CSS422 DISASSEMBLR GROUP PROJECT
*----------------------------------------------------------------------------------------------------
                ORG    $1000
    
START:          MOVE.L  #$7000, A6      ;THESE ARE FOR TESTING! (NEED TO BE REMOVED AFTER DONE)
                MOVE.L  #$3200, (A6)    
                
*----------------------------------------------------------------------------------------------------
* DISASSEMBLIE: DISASSEMBLE HEXADECIMAL INSTRUCTION CODE
* PRECONDITION: - D2, D3, AND A2 MUST NOT BE IN USED
*               - A6 STORING AN APPROPRIATE STARTING ADDRESS
* POSTCONDITION: - IF THE INSTRUCTION IS IN THE REQUIREMENT, THE STRING OF THE RESULT WILL BE STORED
*                  IN OUTPUT MEMORY REGION POINTED BY A2
*                - IF THE INSTRUCTION IS NOT IN THE REQUIREMENT, FOR NOW IT WILL BE IGNORED
*----------------------------------------------------------------------------------------------------

DISASSEMBLE     MOVEA.L #$A000, A2      ;INITIATE STARTING LOCATION FOR OUTPUT MEMORY REGION  
                MOVE.L  (A6), D2        ;RETRIEVE HEXADECIMAL INSTRUCTION FROM ADDRESS POINTED BY A6
                MOVE.L  D2, D3          ;MAKE A COPY OF INSTRUCTION TO D3

                LSR     #8, D3          ;GET THE FIRST 4 BITS
                LSR     #4, D3          
                JSR     MAINTABLE
                
*----------------------------------------------------------------------------------------------------
* MAINTABLE: JUMP TABLE FOR THE FIRST 4 BITS IN THE HEXADECIMAL INSTRUCTION TO DETERMIND TYPES OF
*            OPCODES
*----------------------------------------------------------------------------------------------------
MAINTABLE       ;JSR     CODE0000
                JSR     CODE0001
                JSR     CODE0010
                JSR     CODE0011
                ;JSR     CODE0100
                ;JSR     CODE0101
                ;JSR     CODE0110
                ;JSR     CODE1000
                ;JSR     CODE1001
                ;JSR     CODE1011
                ;JSR     CODE1100
                ;JSR     CODE1101
                ;JSR     CODE1110
                RTS
   
*----------------------------------------------------------------------------------------------------
* CODE0000: DIASSEMBLE THE HEXADECIMAL INSTRUCTION STARTING WITH 0000 INTO BCLR OR CMPI INSTRUCTION
*----------------------------------------------------------------------------------------------------
CODE0000        CMPI.W      #%0000, D3      ;CHECK IF THE FIRST 4 BITS ARE 0000
                BEQ         RETURN0000
                MOVE.L      D2,D3
                LSL         #4, D3
                LSR         #8, D3
                
                
RETURN0000      RTS
; NEED A JUMP TABLE TO DETERMIND EITHER THIS IS A BCLR OR CMPI
; - BCLR
; - CMPI
; - ORI

;TABLE0000   JSR             BCLR1
;            JSR             CMPI
;            JSR             ORI
            
;BCLR    

*----------------------------------------------------------------------------------------------------
* CODE0001: DIASSEMBLE THE HEXADECIMAL INSTRUCTION STARTING WITH 0001 INTO MOVE.B INSTRUCTION
*----------------------------------------------------------------------------------------------------
CODE0001        CMPI.W      #%0001, D3      ;CHECK IF THE FIRST 4 DIGITS IS 0001
                BNE         RETURN0001
                MOVE.B      #'M', (A2)+
                MOVE.B      #'O', (A2)+
                MOVE.B      #'V', (A2)+
                MOVE.B      #'E', (A2)+
                MOVE.B      #'.', (A2)+
                MOVE.B      #'B', (A2)+
                ;JSR         ISMOVEB
RETURN0001      RTS
           
*----------------------------------------------------------------------------------------------------
* CODE0010: DIASSEMBLE THE HEXADECIMAL INSTRUCTION STARTING WITH 0010 INTO MOVE.L OR MOVEA.L
*           INSTRUCTION
*----------------------------------------------------------------------------------------------------

CODE0010        CMPI.W      #%0010, D3      ;CHECK IF THE FIRST 4 DIGITS IS 0010
                BNE         RETURN0010      
                MOVE.B      #'M', (A2)+
                MOVE.B      #'O', (A2)+
                MOVE.B      #'V', (A2)+
                MOVE.B      #'E', (A2)+
                BRA         MOVEAL
RETURN0010      RTS

MOVEL           MOVE.B      #'.', (A2)+
                MOVE.B      #'L', (A2)+
                ;JSR         ISMOVEL
                BRA         RETURN0010
          
MOVEAL          MOVE.L      D2, D3          ;MAKE A COPY OF INSTRUCTION TO D3
                LSL         #7, D3          ;SHIFT TO THE LEFT 7 BITS
                LSR         #4, D3          ;SHIT TO THE RIGHT 4 BITS
                CMPI.W      #%001, D3       ;CHECK IF THIS INSTRUCTION IS MOVEA
                BNE         MOVEL           ;IF THE INSTRUCTION IS NOT MOVEA, IT MUST BE MOVE
                MOVE.B      #'A',(A2)+
                MOVE.B      #'.', (A2)+
                MOVE.B      #'L', (A2)+
                ;JSR         ISMOVEAL
                BRA         RETURN0010


*----------------------------------------------------------------------------------------------------
* CODE0011: DIASSEMBLE THE HEXADECIMAL INSTRUCTION STARTING WITH 0011 INTO MOVE.W OR MOVEA.W
*           INSTRUCTION
*----------------------------------------------------------------------------------------------------
CODE0011        CMPI.W      #%0011, D3      ;CHECK IF THE FIRST 4 DIGITS IS 0011
                BNE         RETURN0011
                MOVE.B      #'M', (A2)+
                MOVE.B      #'O', (A2)+
                MOVE.B      #'V', (A2)+
                MOVE.B      #'E', (A2)+
                BRA         MOVEAW
RETURN0011      RTS

MOVEW           MOVE.B      #'.', (A2)+
                MOVE.B      #'W', (A2)+
                ;JSR         ISMOVEW
                BRA         RETURN0011
          
MOVEAW          MOVE.L      D2, D3          ;MAKE A COPY OF INSTRUCTION TO D3
                LSL         #7, D3          ;SHIFT TO THE LEFT 7 BITS
                LSR         #4, D3          ;SHIT TO THE RIGHT 4 BITS
                CMPI.W      #%001, D3       ;CHECK IF THIS INSTRUCTION IS MOVEA
                BNE         MOVEW           ;IF THE INSTRUCTION ISNOT MOVEA, IT MUST BE MOVE
                MOVE.B      #'A',(A2)+
                MOVE.B      #'.', (A2)+
                MOVE.B      #'W', (A2)+
                ;JSR         ISMOVEAW
                BRA         RETURN0011

*---------------------------------------------------------------------
* CODE0100: DIASSEMBLE THE HEXADECIMAL INSTRUCTION STARTING WITH 0100
*           INTO MOVEM, DIVS, LEA, NEG, JSR, OR RTS INSTRUCTION
*---------------------------------------------------------------------
CODE0100
; NEED A JUMP TABLE TO DETERMIND THIS:
; - MOVEM
; - DIVS
; - LEA
; - NEG
; - JSR
; - RTS

*---------------------------------------------------------------------
* CODE0101: DIASSEMBLE THE HEXADECIMAL INSTRUCTION STARTING WITH 0101
*           INTO SUBQ INSTRUCTION
*---------------------------------------------------------------------
CODE0101        CMPI.W      #%0101, D3      ;CHECK IF THE FIRST 4 DIGITS IS 0001
                BEQ         SUBQ
RETURN0101      RTS
     
SUBQ            MOVE.B      #'S', (A2)+
                MOVE.B      #'U', (A2)+
                MOVE.B      #'B', (A2)+
                MOVE.B      #'Q', (A2)+
                MOVE.B      #'.', (A2)+
GETTYPE         MOVE.L      D2, D3          ;RETRIEVE THE FULL HEXADECIMAL INSTRUCTION
                LSL         #8, D3          ;SHIFT TO THE LEFT 8 BITS
                LSR         #4, D3          ;SHIT TO THE RIGHT 4 BITS
                JSR         TABLESIZE
                ;JSR         EAMOVEB
                BRA         RETURN0001

*---------------------------------------------------------------------
* CODE0110: DIASSEMBLE THE HEXADECIMAL INSTRUCTION STARTING WITH 0110
*           INTO OR BCC, BCS, BGE, BLT, BVC, OR BRA INSTRUCTION
*---------------------------------------------------------------------
CODE0110
; NEED A JUMP TABLE TO DETERMIND EITHER THIS IS A BCLR OR CMPI
; - BCC
; - BCS
; - BGE
; - BLT
; - BVC
; - BRA

*----------------------------------------------------------------------------------------------------
* CODE1000: DIASSEMBLE THE HEXADECIMAL INSTRUCTION STARTING WITH 1000 INTO OR INSTRUCTION
*----------------------------------------------------------------------------------------------------
CODE1000        CMPI.W      #%1000, D3      ;CHECK IF THE FIRST 4 DIGITS IS 0001
                BNE         RETURN1000
                MOVE.B      #'O', (A6)+
                MOVE.B      #'R', (A6)+
                ;JSR        ISOR
RETURN1000      RTS

*---------------------------------------------------------------------
* CODE1001: DIASSEMBLE THE HEXADECIMAL INSTRUCTION STARTING WITH 1001
*           INTO SUB INSTRUCTION
*---------------------------------------------------------------------
CODE1001
; SUB

*---------------------------------------------------------------------
* CODE1011: DIASSEMBLE THE HEXADECIMAL INSTRUCTION STARTING WITH 1011
*           INTO EOR OR CMP INSTRUCTION
*---------------------------------------------------------------------
CODE1011
; EOR
; CMP


*---------------------------------------------------------------------
* CODE1100: DIASSEMBLE THE HEXADECIMAL INSTRUCTION STARTING WITH 1100
*           INTO MUL INSTRUCTION
*---------------------------------------------------------------------
CODE1100
;MULS

*---------------------------------------------------------------------
* CODE1101: DIASSEMBLE THE HEXADECIMAL INSTRUCTION STARTING WITH 1101
*           INTO ADDA INSTRUCTION
*---------------------------------------------------------------------
CODE1101
; ADD
; ADDA

*---------------------------------------------------------------------
* CODE1110: DIASSEMBLE THE HEXADECIMAL INSTRUCTION STARTING WITH 1110
*           INTO LSR, LSL, ASR, ASL, ROL, OR ROR INSTRUCTION
*---------------------------------------------------------------------
CODE1110
; LSR
; LSL
; ASR
; ASL
; ROL
; ROR

TABLEOPMODE

*----------------------------------------------------------------------------------------------------
* TABLESIZE : THIS IS A JUMP TABLE USED FOR DETERMINDING THE SIZE OF THE INSTRUCTION
*----------------------------------------------------------------------------------------------------

TABLESIZE       JSR     BYTESIZE
                JSR     WORDSIZE
                JSR     LONGSIZE
RETURNSIZE      RTS
                
BYTESIZE        CMPI.W      #%01, D3
                BNE         RETURNSIZE
                MOVE.B      #'B', (A2)+
                RTS
                
WORDSIZE        CMPI.W      #%11, D3
                BNE         RETURNSIZE
                MOVE.B      #'W', (A2)+
                RTS
                
LONGSIZE        CMPI.W      #%10, D3
                BNE         RETURNSIZE
                MOVE.B      #'L', (A2)+
                RTS

                END    START        ; last line of source










*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
