*-----------------------------------------------------------
* Title      :EA
* Written by :Nicolas Michael
* Date       :5/19/2015
* Description:Completed EA codes for testing
*-----------------------------------------------------------

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
ISMOVEMW      JSR       ISMOVEML            *WORD OR LONG DOES NOT CHANGE EA
ISMOVEML      MOVE.B    #$9, (a2)+
              JSR       MOVEMCLRREG         *CLEAR REGISTERS FOR MOVEM
              MOVE.L    #$510, A5           *USING THIS SPACE TO STORE REGISTERS D4, D5, D6 WHEN I NEED THE REGISTER SPACE
              JSR       SETEAREGISTERS 
              JSR       GETLISTMASK
              MOVEM.L   D0-D7, (A5)         *SAVE MY PRECIOUS REGISTERS
              JSR       GETDIRECTION       
              RTS       
              
*---------------------------------------------------------------------------------------------------------
*GET DIRECTION - DETERMINES IF THIS IS A REGISTER TO MEMORY OR MEMORY TO REGISTER OPERATION AND OUTPUTS
*                COMMAND STRING APPROPRIATELY
*---------------------------------------------------------------------------------------------------------
GETDIRECTION    CMP.B   #0, D4        
                BEQ     REGTOMEM
                JSR     MEMTOREG
RTN_GETDIR      RTS
                
*---------------------------------------------------------------------------------------------------------
*REGISTER TO MEMORY - CALLED WHEN REGISTER TO MEMORY TRANSFER IS REQUESTED.
*---------------------------------------------------------------------------------------------------------
REGTOMEM        JSR     APPLISTRTM      *APPEND THE SOURCE ADDRESS
                MOVE.B  #',', (A2)+     *ADD COMMA AND SPACE
                MOVE.B  #' ', (A2)+
                JSR     APPENDDEST      *APPEND THE DESTINATION ADDRESS
RTN_RTM         JMP     RTN_GETDIR  

*---------------------------------------------------------------------------------------------------------
*APPEND DESTINATION - APPENDS THE DESTINATION ADDRESS TO COMMAND STRING DEPENDING ON ADDRESSING MODE. 
*                     ADDRESSING MODE ALLOWED: (AN), -(A), XXX.W, XXX.L
*---------------------------------------------------------------------------------------------------------
APPENDDEST      CMPI.B  #2, D5
                BEQ     APPENDAI        *APPEND ADDRESS INDIRECT
                CMPI.B  #3, D5
                BEQ     APPENDAIPI
                CMPI.B  #4, D5
                BEQ     APPENDAIPD      *APPEND ADDRESS INDIRECT PRE DECREMENT
                CMPI.B  #7, D5
                BEQ     MOVEMWORL       *APPEND ABSOLUTE WORD OR LONG ADDRESS
RTN_APPDEST     RTS

*---------------------------------------------------------------------------------------------------------
*APPEND ADDRESS INDIRECT POST INCREMENT - APPENDS THE STRING (AN)+ TO THE COMMAND STRING
*---------------------------------------------------------------------------------------------------------
APPENDAIPI      MOVE.B  #'(', (A2)+
                MOVE.B  #'A', (A2)+
                ADDI.B  #48, D2
                ADD.B   D6, D2
                MOVE.B  D2, (A2)+
                MOVE.B  #')', (A2)+
                MOVE.B  #'+', (A2)+
                CLR     D2
                JMP     RTN_APPDEST
                
*---------------------------------------------------------------------------------------------------------
*MOVEM WORD OR LONG - DETERMINES WORD OR LONG ADDRESSING MODES AND APPENDS APPROPRIATELY
*---------------------------------------------------------------------------------------------------------  
MOVEMWORL       MOVE.B  #$24, (A2)+     *24 = $ DOLLAR SIGN DO NOT TRY MOVE '$', DOES NOT WORK
                CMP.L   #0, D6
                BEQ     MOVEMWORD         *LEA WORD
                CMP.L   #1, D6
                BEQ     MOVEMLONG         *LEA LONG
RTN_MMWORL      JMP     RTN_APPDEST          *RETURN TO CALLING ROUTINE

*---------------------------------------------------------------------------------------------------------
*MOVEM WORD - WORD ADDRESSING DETERMINED, APPEND APPROPRIATELY
*---------------------------------------------------------------------------------------------------------  
MOVEMWORD       MOVE.W  (A6)+, D2
                CLR     D3              *CLEAR REG, SHITS ABOUT TO GET REAL
                CLR     D4
                CLR     D5
                CLR     D6
                JSR     MOVEMWORDPARSE
                JSR     MMCONVERTWORD
                JMP     RTN_MMWORL
               
*-----------------------------------------------------------------------------------------------------------
*MOVEM CONVERT WORD - CONVERTS WORD HEX DATA TO ASCII SYMBOL
*-----------------------------------------------------------------------------------------------------------  
MMCONVERTWORD   MOVE.B  D3, D1
                JSR     MMNUMORLETT     *DETERMINE IF NUMBER OR LETTER
                MOVE.B  D1, (A2)+
                CLR     D1
                MOVE.B  D4, D1
                JSR     MMNUMORLETT     *DETERMINE IF NUMBER OR LETTER
                MOVE.B  D1, (A2)+
                CLR     D1
                MOVE.B  D5, D1
                JSR     MMNUMORLETT     *DETERMINE IF NUMBER OR LETTER
                MOVE.B  D1, (A2)+
                CLR     D1
                MOVE.B  D6, D1
                JSR     MMNUMORLETT     *DETERMINE IF NUMBER OR LETTER
                MOVE.B  D1, (A2)+
                CLR     D1
                RTS
                
*-----------------------------------------------------------------------------------------------------------
*MOVEM NUMBER OR LETTER - DETERMINE IF SYMBOL IS A NUMBER OR A LETTER, CONVERSION TO ASCII IS DIFFERENT FOR 
*                         EACH CASE.
*----------------------------------------------------------------------------------------------------------- 
MMNUMORLETT    CMP.B   #$0A, D1
                BEQ     MMADD55 
                CMP.B   #$0B, D1
                BEQ     MMADD55
                CMP.B   #$0C, D1
                BEQ     MMADD55
                CMP.B   #$0D, D1
                BEQ     MMADD55
                CMP.B   #$0E, D1
                BEQ     MMADD55
                CMP.B   #$0F, D1
                BEQ     MMADD55
                JSR     MMADD48
RTN_MMNUMLET   RTS

*-----------------------------------------------------------------------------------------------------------
*MOVEM ADD 48 - CONVERTS TO ASCII BY ADDING 48 (MUST BE A NUMBER)
*----------------------------------------------------------------------------------------------------------- 
MMADD48        ADD.B   #48, D1
               RTS

*-----------------------------------------------------------------------------------------------------------
*MOVEM ADD 55 - CONVERTS TO ASCII BY ADDING 55 (MUST BE A LETTER)
*----------------------------------------------------------------------------------------------------------- 
MMADD55        ADD.B   #55, D1
               JMP     RTN_MMNUMLET
                
*-----------------------------------------------------------------------------------------------------------
*MOVEM WORD PARSE - PARSES EACH SYMBOL OF THE WORD DATA IN ORDER TO CONVERT TO ASCII
*-----------------------------------------------------------------------------------------------------------                 
MOVEMWORDPARSE  MOVE.W  D2, D3 
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
*MOVEM LONG - LONG ADDRESSING DETERMINED, PARSE APPROPRIATELY
*----------------------------------------------------------------------------------------------------------- 
MOVEMLONG       MOVE.W  (A6)+, D2
                CLR     D3              *CLEAR REG, SHITS ABOUT TO GET REAL
                CLR     D4
                CLR     D5
                CLR     D6
                JSR     MOVEMWORDPARSE
                JSR     MMCONVERTWORD
                CLR     D2
                MOVE.W  (A6)+, D2
                CLR     D3              *CLEAR REG, SHITS ABOUT TO GET REAL
                CLR     D4
                CLR     D5
                CLR     D6
                JSR     MOVEMWORDPARSE
                JSR     MMCONVERTWORD
                JMP     RTN_MMWORL
                
*-----------------------------------------------------------------------------------------------------------
*APPEND ADDRESS REGISTER INDIRECT PRE DECREMENT - APPENDS THE STRING -(AN) TO THE COMMAND STRING
*-----------------------------------------------------------------------------------------------------------
APPENDAIPD      MOVE.B  #'-', (A2)+
                MOVE.B  #'(', (A2)+
                MOVE.B  #'A', (A2)+
                ADDI.B  #48, D2
                ADD.B   D6, D2
                MOVE.B  D2, (A2)+
                MOVE.B  #')', (A2)+
                CLR     D2
                JMP     RTN_APPDEST

*-----------------------------------------------------------------------------------------------------------
*APPEND ADDRESS INDIRECT - APPENDS THE STRING (AN) TO THE COMMAND STRING
*-----------------------------------------------------------------------------------------------------------
APPENDAI        MOVE.B #'(', (A2)+
                MOVE.B  #'A', (A2)+
                ADDI.B  #48, D2
                ADD.B   D6, D2
                MOVE.B  D2, (A2)+
                MOVE.B  #')', (A2)+
                CLR     D2
                JMP     RTN_APPDEST

*-----------------------------------------------------------------------------------------------------------
*MEMORY TO REGISTER - MEMORY TO REGISTER TRANSFER DETERMINED, APPENDS DATA APPROPRIATELY
*-----------------------------------------------------------------------------------------------------------
MEMTOREG        JSR     APPENDDEST
                MOVEM.L (A5), D0-D7
                MOVE.B  #',', (A2)+
                MOVE.B  #' ', (A2)+
                JSR     APPLISTRTM
                JMP     RTN_GETDIR  

*-----------------------------------------------------------------------------------------------------------
*APPEND LIST (REGISTER TO MEMORY) - FOR USE WITH REGISTER TO MEMORY TRANSFERS. APPENDS SOURCE LIST OF 
*                                   REGISTERS TO COMMAND STRING IN THE FORMAT AN/DN OR DN/AN IF ADDRESS 
*                                   INDIRECT PRE DECREMENT IS USED FOR DESTINATION ADDRESSING MODE. DOES
*                                   NOT USE DASH (-) SYMBOL. IF THERE'S TIME, I WILL ADD.
*-----------------------------------------------------------------------------------------------------------                
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

*-----------------------------------------------------------------------------------------------------------
*FORWARD LIST - FOR LOOP USED TO APPEND REGISTER STRINGS FOR EXAMPLE "A7/A6/D3/D1/D0"
*-----------------------------------------------------------------------------------------------------------
FORWARDLIST     MOVE.B  #15, D1             *BIG UGLY FOR LOOP
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
BACKWARDLIST    MOVE.B  #15, D1             *BIG UGLY FOR LOOP
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
                
*-----------------------------------------------------------------------------------------------------------
*MOVEM CLEAR REGISTERS - CLEARS ALL REGISTERS TO BE USED BY ISMOVEMW/L
*-----------------------------------------------------------------------------------------------------------
MOVEMCLRREG    CLR      D0 
               CLR      D1
               CLR      D2
               CLR      D3
               CLR      D4
               CLR      D5
               CLR      D6
               MOVEA.L  #0, A5
               RTS

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
                 MOVE.B #'9', (A2)      *ADD TAB AFTER OP CODE
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
                MOVE.B  #'A', (A2)
                ADDQ    #1, A2
                JSR     LEAGETAN
                ADDQ    #1, A2
                MOVE.B  #')', (A2)
                ADDQ    #1, A2
                JMP     RTN_LEAAPP

*-----------------------------------------------------------------------------------------------------------
*LEA GET ADDRESS REGISTER - I CANT REMEMBER WHAT THIS DOES... CHECK BACK LETER...
*-----------------------------------------------------------------------------------------------------------               
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

*-----------------------------------------------------------------------------------------------------------
*SOURCE APPEND 0-7 - THIS IS THE WORST THING IVE EVER WRITTEN...FIX IT....
*----------------------------------------------------------------------------------------------------------- 
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
                
*-----------------------------------------------------------------------------------------------------------
*APPEND DESTINATION REGISTER - APPENDS THE STRING A TO COMMAND STRING....FIX THIS MESS LATER!
*-----------------------------------------------------------------------------------------------------------                 
APPENDDREG      MOVE.B  #'A', (A2)  *ADD 'A'
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

*-----------------------------------------------------------------------------------------------------------
*GET LEA DESTINATION REGISTER - GETS THE DESTINATION REGISTER FROM MEMORY TO PUT IN D6 FOR ERROR CHECKING
*-----------------------------------------------------------------------------------------------------------    
GETLEADREG      MOVE.W  D7, D6
                LSL.L   #4, D6
                LSL.L   #8, D6
                LSL.L   #8, D6
                LSR.L   #8, D6
                LSR.L   #8, D6
                LSR.L   #8, D6
                LSR.L   #5, D6
                RTS

*-----------------------------------------------------------------------------------------------------------
*GET LEA SOURCE REGISTER - GETS THE SOURCE REGISTER FROM MEMORY TO PUT IN D5 FOR ERROR CHECKING
*-----------------------------------------------------------------------------------------------------------              
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

*-----------------------------------------------------------------------------------------------------------
*GET LEA SOURCE MODE - GETS THE SOURCE MODE FROM MEMORY TO PUT IN D4 FOR ERROR CHECKING
*-----------------------------------------------------------------------------------------------------------                 
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

*-----------------------------------------------------------------------------------------------------------
*LEA ERROR CHECK - CHECKS D4, D5, D6 (SOURCE MODE, DESTINATION REGISTER, SOURCE REGISTER) FOR ERRORS
*                  BEEF IN D2 IS ERRORS EXIST...DOESNT REALLY HELP, FIX LATER!
*-----------------------------------------------------------------------------------------------------------                 
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

*-----------------------------------------------------------------------------------------------------------
*LEA CHECK REGISTER ERRORS - CHECKS D5 FOR CORRECT ADDRESSING MODES
*-----------------------------------------------------------------------------------------------------------           
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

*-----------------------------------------------------------------------------------------------------------
*LEA ERROR - PUTS BEEF ERROR IN D2 
*-----------------------------------------------------------------------------------------------------------                 
LEAERROR        MOVE.L  #$0BEEF, D2     *BEEF ERROR, RETURN
                JMP     LEARTN

*-----------------------------------------------------------------------------------------------------------
*APPEND 0-7 - APPENDS THE APPROPRIATE NUMBER TO THE CORRESPONDING REGISTER... DONT DO THIS/FIX LATER...
*-----------------------------------------------------------------------------------------------------------                
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

*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
