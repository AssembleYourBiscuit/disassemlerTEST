*-----------------------------------------------------------
* Title      :NICOLAS MICHAEL
* Written by :NICOLAS   
* Date       :MICHAEL
* Description:BLAHBLAHBLACKSHEEP
*-----------------------------------------------------------
    ORG    $1000
START:                  ; first instruction of program

* Put program code here
         
        MOVE.L  #$10000, A2         *0100 0001 1111 1000  000 111 010 000 lea 0100 0001 1101 0000
        MOVE.L  #$08000, A6
        MOVE.L  #$41F9AABB, $08000      *IGNORE THE TEST CODE
        MOVE.W  #$CC76, $08004
        JSR isLEA

        move.b #9, d0
        trap #15            ; halt simulator 
        
        
*---------------------------------------------------------------------------------------------------------
*isLEA            (IS MOVEA)- TO BE CALLED IF CURRENT INSTRUCTION POINTED TO BY A6 IS A KNOWN LEA COMMAND
*
*PRE CONDITIONS -  A6 POINTS TO START OF LEA COMMAND
*
*POST CONDITIONS - A2 POINTS TO NEXT AVAILABLE LOCATION TO ADD NEXT ASCII INSTRUCTION. DO NOT INCREMENT
*                  A2, ALREADY DONE! A6 POINTS TO START OF NEXT COMMAND OR AND OF FILE IF ALL COMMANDS HAVE
*                  BEEN DIASSEMBLED. DO NOT INC A6, ALREADY DONE. ASCII STRINGS HAVE BEEN ADDED TO (A2) IF
*                  NO ERRORS OCCURED. THE STATE OF ALL OTHER REGISTERS IS UNDETERMINED. I WAS MESSY, YOU
*                  MUST CLEAR THEM YOURSELVES.
*---------------------------------------------------------------------------------------------------------
isLEA            JSR    LEACLEAR        *CLEARS ALL REGISTERS I WILL USE, BETTER SAVE YOUR STUFF!
                 MOVE.W (A6)+, D7       *GET CURRENT OP CODE DATA TO D7
                 ADDQ   #3, A2          *inc a2 BY 4 TO MAKE ROOM FOR "lea"
                 MOVE.B #TAB, (A2)      *ADD TAB AFTER OP CODE
                 ADDQ   #1, A2          *MAKE ROOM FOR TAB CHARACTER
                 JSR    GETLEADREG
                 JSR    GETLEASREG
                 JSR    GETLEASMODE
                 JSR    LEAERRORCHK
                 MOVEM  D4-D6, $500     *SAVE REGISTERS TO $500
                 JSR    APPENDLEA
LEARTN           RTS

*---------------------------------------------------------------------------------------------------------
*LEACLREA           LEA SUPPORTING SUBROUTUNE - CLEARS ALL REGISTERS TO BE USED BY EA
*---------------------------------------------------------------------------------------------------------
LEACLEAR        CLR     D2
                CLR     D3
                CLR     D4
                CLR     D5
                CLR     D6
                RTS
                
*---------------------------------------------------------------------------------------------------------
*APPENDLEA      (APPEND LEA) - LEA SUPPORTING SUBROUTINE - APPENDS ASCII STRINGS TO (A2) FOR PRINTING
*---------------------------------------------------------------------------------------------------------    
APPENDLEA       JSR     LEAAPPSOURCE
                MOVE.B  #',', (A2)      *ADD SPACE BETWEEN ADDRESSES
                ADDQ    #1, A2
                MOVE.B  #' ', (A2)      *ADD COMMA BETWEEN ADDRESSES
                ADDQ    #1, A2
                MOVEM   $500, D4-D6     *RETREIVE REGISTERS
                JSR     APPENDDREG
                RTS
            
*----------------------------------------------------------------------------------------------------------
*LEAAPPSOURCE      (LEA APPEND SOURCE) - LEA SUPPORTING SUBROUTINE - APPENDS SOURCE ADDRESS IN ASCII TO (A2)
*----------------------------------------------------------------------------------------------------------     
LEAAPPSOURCE    CMP.L   #2, D4          *IS ADDRESS INDIRECT?
                BEQ     LEAAPPAI
                CMP.L   #7, D4          *IS ABSOLUTE WORD OR LONG?
                BEQ     LEAWORL         *LEA WORD OR LONG
RTN_LEAAPP      RTS
    
*---------------------------------------------------------------------------------------------------------
*LEAWORL      (LEA WORD OR LONG) - LEA SUPPORTING SUBROUTINE - DETERMINES WORD OR LONG ADDRESSING MODES 
*             AND APPENDS APPROPRIATELY
*---------------------------------------------------------------------------------------------------------  
LEAWORL         MOVE.B  #$24, (A2)+     *24 = $ DOLLAR SIGN DO NOT TRY MOVE '$', DOES NOT WORK
                CMP.L   #0, D5
                BEQ     LEAWORD         *LEA WORD
                CMP.L   #1, D5
                BEQ     LEALONG         *LEA LONG
RTN_WORL        JMP RTN_LEAAPP          *RETURN TO CALLING ROUTINE

*---------------------------------------------------------------------------------------------------------
*LEAWORD      (LEA WORD) - LEA SUPPORTING SUBROUTINE - WORD ADDRESSING DETERMINED, APPEND APPROPRIATELY
*---------------------------------------------------------------------------------------------------------  
LEAWORD         MOVE.W  (A6)+, D2
                CLR     D3              *CLEAR REG, SHITS ABOUT TO GET REAL
                CLR     D4
                CLR     D5
                CLR     D6
                JSR     LEAWORDPARSE
                JSR     LEACONVERTWORD
                JMP     RTN_WORL
               
*-----------------------------------------------------------------------------------------------------------
*LEACONVERTWORD      (LEA CONVERT WORD) - LEA SUPPORTING SUBROUTINE - CONVERTS WORD HEX DATA TO ASCII SYMBOL
*-----------------------------------------------------------------------------------------------------------  
LEACONVERTWORD  MOVE.B  D3, D1
                JSR     LEANUMORLETT
                MOVE.B  D1, (A2)+
                CLR     D1
                MOVE.B  D4, D1
                JSR     LEANUMORLETT
                MOVE.B  D1, (A2)+
                CLR     D1
                MOVE.B  D5, D1
                JSR     LEANUMORLETT
                MOVE.B  D1, (A2)+
                CLR     D1
                MOVE.B  D6, D1
                JSR     LEANUMORLETT
                MOVE.B  D1, (A2)+
                CLR     D1
                RTS
                
*-----------------------------------------------------------------------------------------------------------
*LEANUMORLETT      (LEA NUMBER OR LETTER) - LEA SUPPORTING SUBROUTINE - DETERMINE IF SYMBOL IS A NUMBER OR 
*                   A LETTER, CONVERSION TO ASCII IS DIFFERENT FOR EACH CASE.
*----------------------------------------------------------------------------------------------------------- 
LEANUMORLETT    CMP.B   #$0A, D1
                BEQ     LEAADD55 
                CMP.B   #$0B, D1
                BEQ     LEAADD55
                CMP.B   #$0C, D1
                BEQ     LEAADD55
                CMP.B   #$0D, D1
                BEQ     LEAADD55
                CMP.B   #$0E, D1
                BEQ     LEAADD55
                CMP.B   #$0F, D1
                BEQ     LEAADD55
                JSR     LEAADD48
RTN_LEANUMLET   RTS

*-----------------------------------------------------------------------------------------------------------
*LEAADD48      (LEA ADD 48) - LEA SUPPORTING SUBROUTINE - CONVERTS TO ASCII BY ADDING 48 (MUST BE A NUMBER)
*----------------------------------------------------------------------------------------------------------- 
LEAADD48        ADD.B   #48, D1
                RTS

*-----------------------------------------------------------------------------------------------------------
*LEAADD55      (LEA ADD 55) - LEA SUPPORTING SUBROUTINE - CONVERTS TO ASCII BY ADDING 55 (MUST BE A LETTER)
*----------------------------------------------------------------------------------------------------------- 
LEAADD55        ADD.B   #55, D1
                JMP     RTN_LEANUMLET
                
*-----------------------------------------------------------------------------------------------------------
*LEAWORDPARSE      (LEA WORD PARSE) - LEA SUPPORTING SUBROUTINE - PARSES EACH SYMBOL OF THE WORD DATA IN 
*                  ORDER TO CONVERT TO ASCII
*-----------------------------------------------------------------------------------------------------------                 
LEAWORDPARSE    MOVE.W  D2, D3 
                MOVE.W  D2, D4
                MOVE.W  D2, D5
                MOVE.B  D2, D6        
                LSR.L   #8, D3
                LSR.L   #4, D3
                LSL.W   #4, D4
                LSR.L   #8, D4
                LSR.L   #4, D4
                LSL.W   #8, D5
                LSR.L   #8, D5
                LSR.L   #4, D5
                LSL.B   #4, D6
                LSR.B   #4, D6
                RTS
                
*-----------------------------------------------------------------------------------------------------------
*LEALONG      (LEA LONG) - LEA SUPPORTING SUBROUTINE - LONG ADDRESSING DETERMINED, PARSE APPROPRIATELY
*----------------------------------------------------------------------------------------------------------- 
LEALONG         MOVE.W  (A6)+, D2
                CLR     D3              *CLEAR REG, SHITS ABOUT TO GET REAL
                CLR     D4
                CLR     D5
                CLR     D6
                JSR     LEAWORDPARSE
                JSR     LEACONVERTWORD
                CLR     D2
                MOVE.W  (A6)+, D2
                CLR     D3              *CLEAR REG, SHITS ABOUT TO GET REAL
                CLR     D4
                CLR     D5
                CLR     D6
                JSR     LEAWORDPARSE
                JSR     LEACONVERTWORD
                JMP     RTN_WORL    
            
*-----------------------------------------------------------------------------------------------------------
*LEAAPPAI      (LEA APPEND ADDRES INDIRECT) - LEA SUPPORTING SUBROUTINE - APPENDS THE STRING '(AN)' TO (A2)
*               WHERE N IS THE DESTINATION ADDRESS REGISTER NUMBER
*----------------------------------------------------------------------------------------------------------- 
LEAAPPAI        MOVE.B  #'(', (A2)
                ADDQ    #1, A2
                MOVE.B  #ASTRING, (A2)
                ADDQ    #1, A2
                JSR     LEAGETAN
                ADDQ    #1, A2
                MOVE.B  #')', (A2)
                ADDQ    #1, A2
                JMP     RTN_LEAAPP
                
LEAGETAN        CMP.L   #0, D5
                BEQ     SAPP0
                CMP.L   #1, D5
                BEQ     SAPP1
                CMP.L   #2, D5
                BEQ     SAPP2
                CMP.L   #3, D5
                BEQ     SAPP3
                CMP.L   #4, D5
                BEQ     SAPP4
                CMP.L   #5, D5
                BEQ     SAPP5
                CMP.L   #6, D5
                BEQ     SAPP6
                CMP.L   #7, D5
                BEQ     SAPP7
RTN_SAPP        RTS

SAPP0           MOVE.B  #'0', (A2)
                JMP     RTN_SAPP 
SAPP1           MOVE.B  #'1', (A2)
                JMP     RTN_SAPP
SAPP2           MOVE.B  #'2', (A2)
                JMP     RTN_SAPP
SAPP3           MOVE.B  #'3', (A2)
                JMP     RTN_SAPP
SAPP4           MOVE.B  #'4', (A2)
                JMP     RTN_SAPP
SAPP5           MOVE.B  #'5', (A2)
                JMP     RTN_SAPP
SAPP6           MOVE.B  #'6', (A2)
                JMP     RTN_SAPP
SAPP7           MOVE.B  #'7', (A2)
                JMP     RTN_SAPP
                
                
APPENDDREG      MOVE.B  #ASTRING, (A2)  *ADD 'A'
                ADDQ    #1, A2
                CMP.L   #0, D6
                BEQ     APPEND0
RTNAPP0         CMP.L   #1, D6
                BEQ     APPEND1
RTNAPP1         CMP.L   #2, D6
                BEQ     APPEND2
RTNAPP2         CMP.L   #3, D6
                BEQ     APPEND3
RTNAPP3         CMP.L   #4, D6
                BEQ     APPEND4
RTNAPP4         CMP.L   #5, D6
                BEQ     APPEND5
RTNAPP5         CMP.L   #6, D6
                BEQ     APPEND6
RTNAPP6         CMP.L   #7, D6
                BEQ     APPEND7
RTNAPP7         ADDQ    #1, A2          *UPDATE A2
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
                
APPEND0         MOVE.B  #'0', (A2)
                JMP     RTNAPP0
                
APPEND1         MOVE.B  #'1', (A2)
                JMP     RTNAPP1
           
APPEND2         MOVE.B  #'2', (A2)
                JMP     RTNAPP2
                
APPEND3         MOVE.B  #'3', (A2)
                JMP     RTNAPP3
                
APPEND4         MOVE.B  #'4', (A2)
                JMP     RTNAPP4
                
APPEND5         MOVE.B  #'5', (A2)
                JMP     RTNAPP5
                
APPEND6         MOVE.B  #'6', (A2)
                JMP     RTNAPP6
                
APPEND7         MOVE.B  #'7', (A2)
                JMP     RTNAPP7
                
* Put variables and constants here
TAB     EQU     $09 *TAB CHARACTER
ASTRING EQU     'A'
    END    START        ; last line of source




*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
