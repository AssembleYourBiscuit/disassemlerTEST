*-----------------------------------------------------------
* Title      :HEY ASSHOLE! UPDATE A6! DONT FORGETTTTTTTT
* Written by :
* Date       :
* Description:
*-----------------------------------------------------------
    ORG    $1000
START:                  ; first instruction of program

* Put program code here
         
        MOVE.L  #$10000, A2
        MOVE.L  #$08000, A6
        MOVE.W  #$41F8, $08000
        JSR isLEA

        move.b #9, d0
        trap #15            ; halt simulator 

isLEA            MOVE.W (A6), D7    *GET CURRENT OP CODE DATA TO D7
                 ADDQ   #3, A2         *inc a2 BY 4 TO MAKE ROOM FOR "lea"
                 MOVE.B #TAB, (A2)   *ADD TAB AFTER OP CODE
                 ADDQ   #1, A2         *MAKE ROOM FOR TAB CHARACTER
                 JSR    GETLEADREG
                 JSR    GETLEASREG
                 JSR    GETLEASMODE
                 JSR    LEAERRORCHK
                 JSR    APPENDLEA
LEARTN           RTS
    
APPENDLEA       MOVE.B  #ASTRING, (A2)
                RTS
    
GETLEADREG      MOVE.W  D7, D6
                LSL.L   #4, D6
                LSL.L   #8, D6
                LSL.L   #8, D6
                LSR.L   #8, D6
                LSR.L   #8, D6
                LSR.L   #8, D6
                LSR.L   #5, D6
                RTS
                
GETLEASREG      MOVE.B  D7, D5
                LSL.L   #8, D5
                LSL.L   #5, D5 
                LSL.L   #8, D5
                LSL.L   #8, D5
                LSR.L   #8, D5
                LSR.L   #8, D5

                LSR.L   #8, D5
                LSR.L   #5, D5  
                RTS
                
GETLEASMODE     MOVE.W  D7, D4
                LSL.L   #8, D4
                LSL.L   #2, D4
                LSL.L   #8, D4
                LSL.L   #8, D4
                LSR.L   #8, D4
                LSR.L   #8, D4

                LSR.L   #8, D4
                LSR.L   #5, D4
                RTS
                
LEAERRORCHK     CMP.L   #0, D4
                BEQ     LEAERROR
                CMP.L   #1, D4
                BEQ     LEAERROR
                CMP.L   #3, D4
                BEQ     LEAERROR
                CMP.L   #4, D4
                BEQ     LEAERROR
                CMP.L   #5, D4
                BEQ     LEAERROR
                CMP.L   #6, D4
                BEQ     LEAERROR
                CMP.L   #7, D4
                BEQ     LEACHKREGERR
RTNLEAERRCHK    RTS
                
LEACHKREGERR    CMP.L   #2, D5
                BEQ     LEAERROR
                CMP.L   #3, D5
                BEQ     LEAERROR
                CMP.L   #4, D5
                BEQ     LEAERROR
                CMP.L   #5, D5
                BEQ     LEAERROR
                CMP.L   #6, D5
                BEQ     LEAERROR
                CMP.L   #7, D5
                BEQ     LEAERROR
                JMP     RTNLEAERRCHK
                
LEAERROR        MOVE.L  #$0BEEF, D2     *BEEF ERROR, RETURN
                JMP     LEARTN
                
* Put variables and constants here
TAB     EQU     $09 *TAB CHARACTER
ASTRING EQU     'A'
    END    START        ; last line of source

*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
