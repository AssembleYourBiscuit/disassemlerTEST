*-----------------------------------------------------------
* Title      : movem 
* Written by : Nicolas Michael
* Date       : 5/19/15
* Description: EA for movem
*-----------------------------------------------------------
    ORG    $1000
START:                  ; first instruction of program

              *TESTING CODE, IGNORE
              movea.l     #$09000, a2
              MOVEM.l     d0/D2/D5/A1, -(a1)          0100 1000 1101 0000     
              MOVEA.L     #$08000, A6
              MOVE.L      #$48E0FFFF, (A6)
              MOVE.w      #$1234, $8004
              JSR         ISMOVEMl
              MOVE.B      #9, D0
              TRAP        #15

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

* Put variables and constants here


    END    START        ; last line of source



*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
