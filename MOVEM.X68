*-----------------------------------------------------------
* Title      :
* Written by :
* Date       :
* Description:
*-----------------------------------------------------------
    ORG    $1000
START:                  ; first instruction of program

* Put program code here
    movea.l     #$09000, a2
    MOVEM.l     d0/D2/D5/A1, -(a1)          0100 1000 1101 0000     
    MOVEA.L  #$08000, A6
    MOVE.L  #$48D0FfF8, (A6)
    JSR         ISMOVEMB
DIE MOVE.B      #9, D0
    TRAP        #15
    
ISMOVEMB      MOVE.B    #$9, (a2)+
              JSR       MOVEMCLRREG         *CLEAR REGISTERS FOR MOVEM
              MOVE.L    #$510, A5           *USING THIS SPACE TO STORE REGISTERS D4, D5, D6 WHEN I NEED THE REGISTER SPACE
              MOVE.L    #$520, A4           *USING THIS SPACE TO STORE REGISTERS 
              JSR       SETEAREGISTERS 
              JSR       GETLISTMASK
              JSR       GETDIRECTION       
              RTS       
              
GETDIRECTION    CMP.B   #0, D4              *IS REG-TO-MEM
                BEQ     REGTOMEM
                JSR     MEMTOREG
RTN_GETDIR      RTS
                
REGTOMEM        JSR     APPLISTRTM
                JSR     APPENDDEST
RTN_RTM         JMP     RTN_GETDIR  

APPENDDEST      CMPI.B  #2, D5
                BEQ     APPENDAI            *APPEND ADDRESS INDIRECT
                CMPI.B  #4, D5
                BEQ     APPENDAIPD          *APPEND ADDRESS INDIRECT PRE DECREMENT
                CMPI.B  #7, D5
                BEQ     APPENDALORW          *APPEND ABSOLUTE WORD OR LONG ADDRESS
RTN_APPDEST     RTS

APPENDALORW     CMPI.B  #0, D6
                *BEQ     APPENDMOVEMW        *APPEND ABSOLUTE WORD ADDRESS-----------------------------
                JMP     RTN_APPDEST

APPENDAIPD      MOVE.B  #'-', (A2)+
                MOVE.B  #'(', (A2)+
                MOVE.B  #'A', (A2)+
                ADDI.B  #48, D2
                ADD.B   D6, D2
                MOVE.B  D2, (A2)+
                MOVE.B  #')', (A2)+
                CLR     D2
                JMP     RTN_APPDEST

APPENDAI        MOVE.B #'(', (A2)+
                MOVE.B  #'A', (A2)+
                ADDI.B  #48, D2
                ADD.B   D6, D2
                MOVE.B  D2, (A2)+
                MOVE.B  #')', (A2)+
                CLR     D2
                JMP     RTN_APPDEST

MEMTOREG        
                RTS  
                
APPLISTRTM      CMPI.B  #4, D5              *DIESTINATION IS ADDRESS INDIRECT PRE DECREMEMNT
                BEQ     BACKWARDLIST
                CMPI.B  #2, D5              *DESTINATION IS ADDRESS INDIRECT
                BEQ     FORWARDLIST
                CMPI.B  #7, D5              *DESTINATION IS  ABSOLUTE WORD OR LONG
                BEQ     FORWARDLIST
                CLR     D0
                CLR     D1
                CLR     D2
                CLR     D3
RTN_LIST        RTS

FORWARDLIST     MOVE.B  #15, D1             *BIG UGLY FOR LOOP
FRWRDLOOP       LSL.W   #1, D3
                BCS     APPENDDORAF
RTN_APPDF       SUBI.B  #1, D1
                CMP.B   D0, D1
                BGT     FRWRDLOOP
                JMP     RTN_LIST 
                
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
                
APPENDSLASHF    MOVE.B  #$2F, (A2)+     *ADD SLASH = 2F IN HEX
                JMP     RTN_SLASHF 
                
APPAF           MOVE.B  #'A', (A2)+
                ADDI.B  #40, D2
                ADD.B   D1, D2
                MOVE.B  D2, (A2)+
                JMP     RTN_APPAF

BACKWARDLIST    MOVE.B  #15, D1             *BIG UGLY FOR LOOP
BCKWRDLOOP      LSL.W   #1, D3
                BCS     APPENDDORA
RTN_APPD        ADDI.B  #1, D0
                CMP     D1, D0
                BLT     BCKWRDLOOP
                JMP     RTN_LIST 
                
APPENDDORA      CMPI.B  #7, D0
                BGT     APPA
                MOVE.B  #'D', (A2)+
                ADDI.B  #48, D2
                ADD.B   D0, D2
                MOVE.B  D2, (A2)+
RTN_APPA        CMP.W   #$8000, D3
                BEQ     RTN_SLASH
                CMP.W   #0, D3
                BEQ     RTN_SLASH
                JMP     APPENDSLASH
RTN_SLASH       CLR     D2
                JMP     RTN_APPD            *END BIG UGLY FOR LOOP
                
APPENDSLASH     MOVE.B  #$2F, (A2)+     *ADD SLASH = 2F IN HEX
                JMP     RTN_SLASH 
                
APPA            MOVE.B  #'A', (A2)+
                ADDI.B  #41, D2
                ADD.B   D0, D2
                MOVE.B  D2, (A2)+
                JMP     RTN_APPA


GETLISTMASK     MOVE.W  (A6)+, D3      *THANKS!
                RTS     
              
SETEAREGISTERS  MOVE.W (A6)+, D4       *COPY COMMAND INTO D4, 5 AND 6 TO BE PARSED
                MOVE.W  D4, D5         *FOR DIRECTION, MODE AND REG
                MOVE.W  D4, D6  
                LSL.W   #5, D4         *SHIFTING FOR DIRECTION
                LSR.W   #8, D4
                LSR.W   #7, D4
                LSL.W   #8, D5         *SHIFTING FOR MODE
                LSL.W   #2, D5
                LSR.W   #8, D5
                LSR.W   #5, D5
                LSL.W   #8, D6         *SHIFTING FOR REGISTER
                LSL.W   #5, D6
                LSR.W   #8, D6
                LSR.W   #5, D6
                MOVEM.W D4-D6, (A5)
                RTS
                

MOVEMCLRREG    CLR      D0 
               CLR      D1
               CLR      D2
               CLR      D3
               CLR      D4
               CLR      D5
               CLR      D6
               MOVEA.L  #0, A5
               RTS

* Put variables and constants here


    END    START        ; last line of source



*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
