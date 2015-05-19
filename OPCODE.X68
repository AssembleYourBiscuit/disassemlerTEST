*----------------------------------------------------------------------------------------------------
* Title      : OP-CODE PROGRAM
* Written by : KUNLAKAN (JEEN) CHERDCHUSILP
* Date       : 
* Description: CSS422 DISASSEMBLR GROUP PROJECT
*----------------------------------------------------------------------------------------------------
                ORG    $1000
    
START:          MOVE.L  #$7000, A6      ;THESE ARE FOR TESTING! (NEED TO BE REMOVED AFTER DONE)
                MOVE.L  #$5B40, (A6)
                MOVEA.L #$10000, A2     ;INITIATE STARTING LOCATION FOR OUTPUT MEMORY REGION    
                
*----------------------------------------------------------------------------------------------------
* DISASSEMBLIE: DISASSEMBLE HEXADECIMAL INSTRUCTION CODE TO MNEMONIC INSTRUCTION
* PRECONDITION: - D2, D3, AND A2 MUST NOT BE IN USED
*               - A6 STORING AN APPROPRIATE STARTING ADDRESS
* POSTCONDITION: - IF THE INSTRUCTION IS IN THE REQUIREMENT, THE STRING OF THE RESULT WILL BE STORED
*                  IN OUTPUT MEMORY REGION POINTED BY A2
*                - IF THE INSTRUCTION IS NOT IN THE REQUIREMENT, FOR NOW IT WILL BE IGNORED
*----------------------------------------------------------------------------------------------------

DISASSEMBLE     MOVE.L  (A6), D2        ;RETRIEVE ORIGINAL INSTRUCTION TO D2 (NO CHANGE ALLOWED)
                MOVE.L  D2, D3          ;COPY ORIGINAL INSTRUCTION TO D3 (CHANGE ALLOW)

                LSR     #8, D3          ;GET THE FIRST 4 BITS
                LSR     #4, D3
                MULU    #6, D3
                
                LEA     MAINTABLE, A3   ;LOAD INDEX INTO THE TABLE
                JSR     0(A3, D3)       ;JUMP INDIRECT WITH INDEX
                RTS
                                
*----------------------------------------------------------------------------------------------------
* MAINTABLE: THIS IS A PRIMARY JUMP TABLE FOR DETERMINING TYPES OF OPCODES INSTRUCTION BY LOOKING  AT
*            THE FIRST 4 BITS IN THE HEXADECIMAL INSTRUCTION 
*----------------------------------------------------------------------------------------------------
MAINTABLE       JMP     CODE0000
                JMP     CODE0001
                JMP     CODE0010
                JMP     CODE0011
                JMP     CODE0100
                JMP     CODE0101
                JMP     CODE0110
                JMP     CODE1000
                JMP     CODE1001
                JMP     CODE1011
                JMP     CODE1100
                JMP     CODE1101
                JMP     CODE1110
FINISHE         RTS

*----------------------------------------------------------------------------------------------------
* CODE0000: DIASSEMBLE THE HEXADECIMAL INSTRUCTION STARTING WITH 0000 INTO BCLR, ORI, OR CMPI
*           INSTRUCTION
*----------------------------------------------------------------------------------------------------
CODE0000        MOVE.L      D2, D3
                LSL         #4, D3
                LSR         #8, D3
                BRA         FINISHE


TABLE0000      JMP         ORI
               JMP         CMPI
               JMP         ORI
            
ORI             MOVE.B      #'O', (A2)+
                MOVE.B      #'R', (A2)+
                MOVE.B      #'I', (A2)+
                MOVE.B      #'.', (A2)+
                JSR         GET_SIZE
                ;JSR         ISORI

CMPI            MOVE.B      #'C', (A2)+
                MOVE.B      #'M', (A2)+
                MOVE.B      #'P', (A2)+
                MOVE.B      #'I', (A2)+
                MOVE.B      #'.', (A2)+
                JSR         GET_SIZE
                ;JSR         ISCMPI
                
;BCLR                

*----------------------------------------------------------------------------------------------------
* CODE0001: DIASSEMBLE THE HEXADECIMAL INSTRUCTION STARTING WITH 0001 INTO MOVE.B INSTRUCTION
*----------------------------------------------------------------------------------------------------
CODE0001        MOVE.B      #'M', (A2)+
                MOVE.B      #'O', (A2)+
                MOVE.B      #'V', (A2)+
                MOVE.B      #'E', (A2)+
                MOVE.B      #'.', (A2)+
                MOVE.B      #'B', (A2)+
                ;JSR         ISMOVEB
                BRA         FINISHE
           
*----------------------------------------------------------------------------------------------------
* CODE0010: DIASSEMBLE THE HEXADECIMAL INSTRUCTION STARTING WITH 0010 INTO MOVE.L OR MOVEA.L
*           INSTRUCTION
*----------------------------------------------------------------------------------------------------
CODE0010        MOVE.B      #'M', (A2)+
                MOVE.B      #'O', (A2)+
                MOVE.B      #'V', (A2)+
                MOVE.B      #'E', (A2)+
                JSR         MOVEAL
                BRA         FINISHE

MOVEL           MOVE.B      #'.', (A2)+
                MOVE.B      #'L', (A2)+
                ;JSR         ISMOVEL
                RTS
          
MOVEAL          MOVE.L      D2, D3          ;MAKE A COPY OF ORIGINAL INSTRUCTION TO D3
                LSL         #7, D3          ;SHIFT TO THE LEFT 7 BITS
                LSR         #4, D3          ;SHIT TO THE RIGHT 4 BITS
                CMPI.W      #%001, D3       ;CHECK IF THIS INSTRUCTION IS MOVEA
                BNE         MOVEL           ;IF THE INSTRUCTION IS NOT MOVEA, IT MUST BE MOVE
                MOVE.B      #'A',(A2)+      ;OTHERWISE, IT IS MOVEA.
                MOVE.B      #'.', (A2)+
                MOVE.B      #'L', (A2)+
                ;JSR         ISMOVEAL
                RTS

*----------------------------------------------------------------------------------------------------
* CODE0011: DIASSEMBLE THE HEXADECIMAL INSTRUCTION STARTING WITH 0011 INTO MOVE.W OR MOVEA.W
*           INSTRUCTION
*----------------------------------------------------------------------------------------------------
CODE0011        MOVE.B      #'M', (A2)+
                MOVE.B      #'O', (A2)+
                MOVE.B      #'V', (A2)+
                MOVE.B      #'E', (A2)+
                JSR         MOVEAW
                BRA         FINISHE

MOVEW           MOVE.B      #'.', (A2)+
                MOVE.B      #'W', (A2)+
                ;JSR         ISMOVEW
                RTS
          
MOVEAW          MOVE.L      D2, D3          ;MAKE A COPY OF ORIGINAL INSTRUCTION TO D3
                LSL         #7, D3          ;SHIFT TO THE LEFT 7 BITS
                LSR         #4, D3          ;SHIT TO THE RIGHT 4 BITS
                CMPI.W      #%001, D3       ;CHECK IF THIS INSTRUCTION IS MOVEA
                BNE         MOVEW           ;IF THE INSTRUCTION ISNOT MOVEA, IT MUST BE MOVE
                MOVE.B      #'A',(A2)+      ;OTHERWISE, IT IS MOVEA.
                MOVE.B      #'.', (A2)+
                MOVE.B      #'W', (A2)+
                ;JSR         ISMOVEAW
                RTS

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
CODE0101        MOVE.B      #'S', (A2)+
                MOVE.B      #'U', (A2)+
                MOVE.B      #'B', (A2)+
                MOVE.B      #'Q', (A2)+
                MOVE.B      #'.', (A2)+
                
                JSR         GET_SIZE
                ;JSR         EASUBQ
                BRA         FINISHE

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
CODE1000        MOVE.B      #'O', (A2)+
                MOVE.B      #'R', (A2)+
                MOVE.B      #'.', (A2)+
                JSR         GET_OPMODE
                ;JSR        ISOR
RETURN1000      RTS

*----------------------------------------------------------------------------------------------------
* CODE1001: DIASSEMBLE THE HEXADECIMAL INSTRUCTION STARTING WITH 1001 INTO SUB INSTRUCTION
*----------------------------------------------------------------------------------------------------
CODE1001        MOVE.B      #'S', (A2)+
                MOVE.B      #'U', (A2)+
                MOVE.B      #'B', (A2)+
                MOVE.B      #'.', (A2)+
                JSR         GET_OPMODE
                ;JSR        ISSUB
RETURN1001      RTS
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


*----------------------------------------------------------------------------------------------------
* GET_OPMODE: THIS IS FUNCTION FOR DETERMINDING THE OPMODE OF THE INSTRUCTION (NOT YET COMPLETE)
*----------------------------------------------------------------------------------------------------
GET_OPMODE      MOVE.L      D2, D3          ;MAKE A COPY OF INSTRUCTION TO D3
                LSL         #7, D3          ;SHIFT TO THE LEFT 7 BITS
                LSR         #4, D3          ;SHIFT TO THE RIGHT 4 BITS
                LSR         #7, D3          ;SHIFT TO THE RIGHT 7 BITS
                MULU        #6, D3
                
                LEA         TABLEOPMODE, A3
                JSR         0(A3, D3)
                RTS
  
TABLEOPMODE     JSR         MODE_BYTE2
                JSR         MODE_WORD2
                JSR         MODE_LONG2
                JSR         MODE_BYTE3
                JSR         MODE_WORD3
                JSR         MODE_LONG3
RETURN_OPMODE   RTS
                
MODE_BYTE2      MOVE.B      #'B', (A2)+
                BRA         RETURN_OPMODE

MODE_WORD2      MOVE.B      #'W', (A2)+
                BRA         RETURN_OPMODE

MODE_LONG2      MOVE.B      #'L', (A2)+
                BRA         RETURN_OPMODE

MODE_BYTE3      MOVE.B      #'B', (A2)+
                BRA         RETURN_OPMODE

MODE_WORD3      MOVE.B      #'W', (A2)+
                BRA         RETURN_OPMODE
                
MODE_LONG3      MOVE.B      #'L', (A2)+
                BRA         RETURN_OPMODE
                
*----------------------------------------------------------------------------------------------------
* GET_SIZE : THIS IS A FUNCTION FOR DETERMINDING THE SIZE OF THE INSTRUCTION
*----------------------------------------------------------------------------------------------------
GET_SIZE        MOVE.L      D2, D3          ;MAKE A COPY OF ORIGINAL INSTRUCTION TO D3
                LSL         #8, D3          ;SHIFT TO THE LEFT 8 BITS
                LSR         #6, D3          ;SHIFT TO THE RIGHT 6 BITS
                LSR         #8, D3          ;SHIFT TO THE RIGHT 8 BITS
                MULU        #6, D3
                
                LEA         TABLESIZE, A3
                JSR         0(A3, D3)
                RTS

TABLESIZE       JMP         SIZE_BYTE1
                JMP         SIZE_WORD1
                JMP         SIZE_LONG1
RETURN_SIZE     RTS
                
SIZE_BYTE1      MOVE.B      #'B', (A2)+
                BRA         RETURN_SIZE
                
SIZE_WORD1      MOVE.B      #'W', (A2)+
                BRA         RETURN_SIZE
                
SIZE_LONG1      MOVE.B      #'L', (A2)+
                BRA         RETURN_SIZE
                
                

                END    START        ; last line of source


*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
