*-----------------------------------------------------------
* Title      :
* Written by :
* Date       :
* Description:
*-----------------------------------------------------------
    ORG    $1000
START:                  ; first instruction of program

* Put program code here
    MOVEM.L     $00, D0-D7
    MOVEA.L  #$08000, A6
    MOVE.L  #$48F800FF, (A6)
    JSR         ISMOVEMB
DIE MOVE.B      #9, D0
    TRAP        #15
    
ISMOVEMB      JSR       MOVEMCLRREG         *CLEAR REGISTERS FOR MOVEM
              MOVE.L    #$510, A5           *USING THIS SPACE TO STORE REGISTERS D4, D5, D6 WHEN I NEED THE REGISTER SPACE
              MOVE.L    #$520, A4           *USING THIS SPACE TO STORE REGISTERS 
              JSR       SETEAREGISTERS 
              JSR       GETLISTMASK
              JSR       GETDIRECTION
              RTS       
              
GETDIRECTION    CMP.B   #0, D4          *IS REG-TO-MEM
                BEQ     REGTOMEM
                JSR     MEMTOREG
RTN_GETDIR      RTS
                
REGTOMEM        JSR     APPLISTRTM
                CMP.B   #2, D5
                BEQ     REGTOMEMI
RTN_RTM         JMP     RTN_GETDIR  

MEMTOREG        
                RTS  
                
REGTOMEMI       
                JMP     RTN_RTM
                
APPLISTRTM      CMPI.B  #4, D5
                BEQ     BACKWARDLIST
RTN_LIST        RTS

BACKWARDLIST    MOVE.B  #8, D1
                LSL.W   #1, D3
                BCS     APPENDD
                ADDI.B  #1, D0
                MOVE.B  #$2F, (A2)+     *ADD SLASH = 2F IN HEX
BCKWRDLOOP      LSL.W   #1, D3
                BCS     APPENDD
                ADDI.B  #1, D0
RTN_APPD        CMP     D0, D1
                BLT     BCKWRDLOOP
                JMP     RTN_LIST 
                
APPENDD         MOVE.B  'D', (A2)+
                ADDI.B  #30, D2
                ADD.B   D0, D2
                MOVE.B  D2, (A2)+
                CMP.L   #0, D3
                BNE     APPENDSLASH
RTN_SLASH       CLR     D2
                JMP     RTN_APPD
                
APPENDSLASH     MOVE.B  #$2F, (A2)+     *ADD SLASH = 2F IN HEX
                JMP     RTN_SLASH 

GETLISTMASK     MOVE.W  (A6)+, D3  
                RTS     
              
SETEAREGISTERS  MOVE.W (A6)+, D4        *COPY COMMAND INTO D4, 5 AND 6 TO BE PARSED
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
