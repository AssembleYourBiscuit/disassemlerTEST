*-----------------------------------------------------------
* Title      :EA
* Written by :Nicolas Michael
* Date       :5/19/2015
* Description:Completed EA codes for testing
*-----------------------------------------------------------

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
            JSR         ISMOVEB                                                                             
            RTS
ISMOVEW     JSR         ISMOVEB
            RTS   
ISMOVEB     MOVEM.L     D0-D7/A0/A1/A3-A5, $400          *SAVE JEENS REGISTERS AT $400
            JSR         CLRALLDREG                       *CLEAR REGISTERS FOR USE
            MOVE.W      (A6)+, D7
            JSR         GETMOVEREG                                               
            JSR         MOVEERRCHK                       *CHECK FOR ERRORS, $BEEF AT $456 IF ERRORS EXISTS
            CMP.W       #$BEEF, $456                     *IF $BEEF, APPEND BAD DATA STRING TO A2
            BEQ         MOVEBADDATA
            JSR         APPENDEA                         *ELSE APPEND SRC AE
            MOVE.B      #',', (A2)+
            MOVE.B      #' ', (A2)+
            MOVE.B      D2, D0
            MOVE.B      D3, D1
            JSR         APPENDEA                         *APPEND DESTINATION EA
            MOVEM.L     $400, D0-D7/A0/A1/A3-A5          *RESTORE JEENS REGISTERS
RTN_BAD     RTS 
     
MOVEBADDATA JSR         BADDATA
            JMP         RTN_BAD

*---------------------------------------------------------------------------------------------------------
*MOVE ERROR CHECK - CHECKS ADDRESSING MODES AND ADDRESSING REGISTERS FOR ERRORS
*---------------------------------------------------------------------------------------------------------            
MOVEERRCHK      JSR         MOVESERR
                JSR         MOVEDERR
                RTS
MOVEDERR        CMPI.B      #1, D3
                BEQ         DERROR
                CMPI.B      #5, D3
                BEQ         DERROR
                CMPI.B      #6, D3
                BEQ         DERROR
RTN_DERR        RTS
DERROR          MOVE.W      #$BEEF, $456
                JMP         RTN_DERR
MOVESERR        CMPI.B      #5, D1
                BEQ         SERROR
                CMPI.B      #6, D1
                BEQ         SERROR
                CMPI.B      #7, D1
                BEQ         SREGERR
RTN_SERR        RTS
SERROR          MOVE.W      #$BEEF, $456
                JMP         RTN_SERR
SREGERR         CMPI.B      #2, D0
                BEQ         SRERR
                CMPI.B      #3, D0
                BEQ         SRERR
                JMP         RTN_SERR
SRERR           JMP         SERROR

*---------------------------------------------------------------------------------------------------------
*GET MOVE REGISTERS - PARSES MOVE ADDRESSING REGISTERS AND MODES INTO D0, D1, D2 AND D3 TO BE CHECKED FOR ERROR
*---------------------------------------------------------------------------------------------------------            
GETMOVEREG      MOVE.W  D7, D0
                MOVE.W  D7, D1
                MOVE.W  D7, D2
                MOVE.W  D7, D3
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
*IS MOVEAW/L       TO BE CALLED IF CURRENT INSTRUCTION POINTED TO BY A6 IS A KNOWN MOVEA COMMAND. APPENDS 
*                  ADDRESSING MODES TO END OF CURRENT COMMAND STRING. JUST CALLS MOVE, SAME DEAL
*
*PRE CONDITIONS -  A6 POINTS TO START OF MOVE COMMAND. A2 POINTS TO LOCATION AFTER MOVE STRING AND TAB
*
*POST CONDITIONS - A6 POINTS TO NEXT COMMAND TO BE DISASSEMBLED. A2 POINTS TO NEXT LOCATION TO BE APPENDED,
*                  DELIMETER SHOULD BE ADDED TO THIS LOCATION IMMEDIATELY. ALL OTHER ADDRESS AND DATA 
*                  REGISTERS ARE PRESERVED, EXCEPT D6..., YEA I SAID IT....WHAT ARE YOU GONNA DO ABOUT IT PUNK!
*--------------------------------------------------------------------------------------------------------- 
ISMOVEAW            JSR         ISMOVEB
                    RTS
ISMOVEAL            JSR         ISMOVEL
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
ISMOVEMW      JSR           ISMOVEML                         *WORD OR LONG DOES NOT CHANGE EA
              RTS
ISMOVEML      MOVEM.L       D0-D7/A0/A1/A3-A5, $400          *SAVE JEENS REGISTERS AT $400
              JSR           CLRALLDREG                       *CLEAR REGISTERS FOR MOVEM
              JSR           SETEAREGISTERS 
              JSR           GETLISTMASK
              CMPI.B        #1, D4
              BEQ           MMAPPEA1
              JSR           MMAPPEA0
RTN_1DIR      MOVEM.L       $400, D0-D7/A0/A1/A3-A5          *RESTORE JEENS REGISTERS     
              RTS  

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
*isLEA            (IS MOVEA)- TO BE CALLED IF CURRENT INSTRUCTION POINTED TO BY A6 IS A KNOWN LEA COMMAND
*
*PRE CONDITIONS -  A6 POINTS TO START OF LEA COMMAND
*
*POST CONDITIONS - A2 POINTS TO NEXT AVAILABLE LOCATION TO ADD NEXT ASCII INSTRUCTION. DO NOT INCREMENT
*                  A2, ALREADY DONE! A6 POINTS TO START OF NEXT COMMAND OR AND OF FILE IF ALL COMMANDS HAVE
*                  BEEN DIASSEMBLED. DO NOT INC A6, ALREADY DONE. ASCII STRINGS HAVE BEEN ADDED TO (A2) IF
*                  NO ERRORS OCCURED. THE STATE OF ALL OTHER REGISTERS IS EXACTLY HOW THEY WERE BEFORE CALLING THIS
*---------------------------------------------------------------------------------------------------------
isLEA            MOVEM.L     D0-D7/A0/A1/A3-A5, $400          *SAVE JEENS REGISTERS AT $400
                 JSR         CLRALLDREG                           
                 MOVE.W      (A6)+, D7                        *GET CURRENT OP CODE DATA TO D7
                 JSR         GETLEADREG
                 JSR         GETLEASREG
                 JSR         GETLEASMODE
                 JSR         LEAERRORCHK
                 CMP.W       #$BEEF, $456
                 BEQ         LEABADDATA
                 MOVE.L      #1, D6                           *INDICATES LONG FOR IMMEDIATE ADDRESSING
                 JSR         APPENDEA
                 MOVE.B      #',', (A2)+                      *ADD SPACE BETWEEN ADDRESSES
                 MOVE.B      #' ', (A2)+                      *ADD COMMA BETWEEN ADDRESSES
                 MOVE.B      D3, D0
                 MOVE.W      #1, D1
                 JSR         APPENDEA
                 MOVEM.L     $400, D0-D7/A0/A1/A3-A5
LEARTN           RTS

*-----------------------------------------------------------------------------------------------------------
*LEABAD DATA - SETS BEEF FLAG IF BAD DATA
*-----------------------------------------------------------------------------------------------------------
LEABADDATA       JSR         BADDATA
                 JMP         LEARTN
                     
*-----------------------------------------------------------------------------------------------------------
*GET LEA DESTINATION REGISTER - GETS THE DESTINATION REGISTER FROM MEMORY TO PUT IN D6 FOR ERROR CHECKING
*-----------------------------------------------------------------------------------------------------------    
GETLEADREG      MOVE.W  D7, D3
                LSL.L   #4, D3
                LSL.L   #8, D3
                LSL.L   #8, D3
                LSR.L   #8, D3
                LSR.L   #8, D3
                LSR.L   #8, D3
                LSR.L   #5, D3
                RTS

*-----------------------------------------------------------------------------------------------------------
*GET LEA SOURCE REGISTER - GETS THE SOURCE REGISTER FROM MEMORY TO PUT IN D5 FOR ERROR CHECKING
*-----------------------------------------------------------------------------------------------------------              
GETLEASREG      MOVE.B  D7, D0
                LSL.L   #8, D0
                LSL.L   #5, D0 
                LSL.L   #8, D0
                LSL.L   #8, D0
                LSR.L   #8, D0
                LSR.L   #8, D0
                LSR.L   #8, D0
                LSR.L   #5, D0  
                RTS

*-----------------------------------------------------------------------------------------------------------
*GET LEA SOURCE MODE - GETS THE SOURCE MODE FROM MEMORY TO PUT IN D4 FOR ERROR CHECKING
*-----------------------------------------------------------------------------------------------------------                 
GETLEASMODE     MOVE.W  D7, D1
                LSL.L   #8, D1
                LSL.L   #2, D1
                LSL.L   #8, D1
                LSL.L   #8, D1
                LSR.L   #8, D1
                LSR.L   #8, D1
                LSR.L   #8, D1
                LSR.L   #5, D1
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
LEAERROR        MOVE.L  #$0BEEF, $456     *BEEF ERROR, RETURN
                JMP     RTNLEAERRCHK
                
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
                JSR         ISORIB                                                                             
                RTS
ISORIW          JSR         ISORIB
                RTS   
ISORIB          MOVEM.L     D0-D7/A0/A1/A3-A5, $400       *SAVE JEENS REGISTERS AT $400
                JSR         CLRALLDREG                       *CLEAR REGISTERS FOR USE
                MOVE.W      (A6)+, D0
                JSR         PARSEORI                                               
                JSR         ORIERRCHK                        *CHECK FOR ERRORS, $BEEF AT $456 IF ERRORS EXISTS
                CMP.W       #$BEEF, $456                     *IF $BEEF, APPEND BAD DATA STRING TO A2
                BEQ         ORIBADDATA
                JSR         APPENDIMMEDIATE                         *ELSE APPEND SRC AE
                MOVE.B      #',', (A2)+
                MOVE.B      #' ', (A2)+
                JSR         APPENDEA                         *APPEND DESTINATION EA
                MOVEM.L     $400, D0-D7/A0/A1/A3-A5          *RESTORE JEENS REGISTERS
RTN_BADORI      RTS 

*---------------------------------------------------------------------------------------------------------
*ORI ERROR CHECK - CHECKS FOR ERRORS IN ADDRESSSING MODES FOR ORI CALL
*--------------------------------------------------------------------------------------------------------- 
ORIERRCHK       CMPI.B      #1, D1                       *CANNOT HAVE MODES 1, 5, OR 6
                BEQ         ORIBADDATAF
                CMPI.B      #5, D1
                BEQ         ORIBADDATAF
                CMPI.B      #6, D1
                BEQ         ORIBADDATAF
RTN_ORIERRCHK   RTS
                
*---------------------------------------------------------------------------------------------------------
*ORI BAD DATA FLAG - SETS BEEF FLAG FOR BAD DATA (UN SUPPORTED ADDRESSING MODES 6 AND 7)
*--------------------------------------------------------------------------------------------------------- 
ORIBADDATAF     MOVE.W      #$BEEF, $456                *BEEF ERROR (MMMM)
                JMP         RTN_ORIERRCHK
 
*---------------------------------------------------------------------------------------------------------
*ORI BAD DATA - SETS BAD DATA FLAG AND RECOVERS A2 POINTER 
*---------------------------------------------------------------------------------------------------------                
ORIBADDATA      JSR         BADDATA                     
                JSR         RECOVERPTR
                CMPI.B      #7, D1
                BEQ         ORIISWORL
RTN_ORIISWORD   JSR         RECOVERPTR
                JMP         RTN_BADORI
ORIISWORL       CMPI.B      #0, D0
                BEQ         ORIISWORD
                MOVE.B      #1, D6
                JMP         RTN_ORIISWORD
ORIISWORD       MOVE.B      #0, D6
                JMP         RTN_ORIISWORD

*---------------------------------------------------------------------------------------------------------
*PARSE ORI - PARSES THE ADDRESSING MODE AND REGISTER INTO D1 AND D0 RESPECTIVELY TO BE CHECKED FOR ERRORS
*---------------------------------------------------------------------------------------------------------
PARSEORI        MOVE.W      D0, D1
                LSL.W       #8, D0
                LSL.W       #5, D0
                LSR.W       #8, D0
                LSR.W       #5, D0
                LSL.W       #8, D1
                LSL.W       #2, D1
                LSR.W       #8, D1
                LSR.W       #5, D1
                RTS
                
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
                JSR         ISNEGB
                RTS
ISNEGW          JSR         ISNEGB
                RTS
ISNEGB          MOVEM.L     D0-D7/A0/A1/A3-A5, $400          *SAVE JEENS REGISTERS AT $400
                JSR         CLRALLDREG                       *CLEAR REGISTERS FOR USE
                MOVE.W      (A6)+, D0
                JSR         PARSENEG                                               
                JSR         NEGERRCHK                        *CHECK FOR ERRORS, $BEEF AT $456 IF ERRORS EXISTS
                CMP.W       #$BEEF, $456                     *IF $BEEF, APPEND BAD DATA STRING TO A2
                BEQ         NEGBADDATA
                JSR         APPENDEA                         *APPEND DESTINATION EA
                MOVEM.L     $400, D0-D7/A0/A1/A3-A5
RTN_NEGERR      RTS

*---------------------------------------------------------------------------------------------------------
*NEG BAD DATA - CHECKS FOR ILLEGAL ADDRESSING MODES, APPENDS BAD DATA STRING TO A2 IF THEY EXIST 
*               (MODE 5 AND 6 NOT ALLOWED)
*--------------------------------------------------------------------------------------------------------- 
NEGBADDATA      JSR         BADDATA
                JMP         RTN_NEGERR
NEGERRCHK       CMPI.B      #5, D1
                BEQ         NEGERR 
                CMPI.B      #6, D1
                BEQ         NEGERR
RTN_NEG         RTS
NEGERR          MOVE.W      #$BEEF, $456
                JMP         RTN_NEG                      

*---------------------------------------------------------------------------------------------------------
*PARSE NEG - PARSES THE ADDRESSING REGISTER AND MODE INTO D0 AND D1 RESPECTIVELY TO BE CHECKED FOR ERRORS
*---------------------------------------------------------------------------------------------------------                
PARSENEG        MOVE.W      D0, D1
                LSL.W       #8, D0
                LSL.W       #5, D0
                LSR.W       #8, D0
                LSR.W       #5, D0
                LSL.W       #8, D1
                LSL.W       #2, D1
                LSR.L       #8, D1
                LSR.W       #5, D1
                RTS

*---------------------------------------------------------------------------------------------------------
*IS ORB/W/L        TO BE CALLED IF CURRENT INSTRUCTION POINTED TO BY A6 IS A KNOWN OR COMMAND
*
*PRE CONDITIONS -  A6 POINTS TO START OF MOVE COMMAND. A2 POINTS TO LOCATION AFTER MOVE STRING AND TAB
*
*POST CONDITIONS - A6 POINTS TO NEXT COMMAND TO BE DISASSEMBLED. A2 POINTS TO NEXT LOCATION TO BE APPENDED,
*                  DELIMETER SHOULD BE ADDED TO THIS LOCATION IMMEDIATELY. ALL OTHER ADDRESS AND DATA 
*                  REGISTERS ARE PRESERVED. EXCEPT D6, D6 IS GONE....SORRY
*---------------------------------------------------------------------------------------------------------
ISORL           JSR         ISORB
                RTS
ISORW           JSR         ISORB
                RTS
ISORB           MOVEM.L     D0-D7/A0/A1/A3-A5, $400          *SAVE JEENS REGISTERS AT $400
                JSR         CLRALLDREG                       *CLEAR REGISTERS FOR USE
                MOVE.W      (A6)+, D4
                JSR         PARSEOROP 
                CMPI.B      #2, D4                           *IF OPMODE GREATER THAN 2 DN IS SOURCE
                BGT         PARSEDNSOURCE    
                JSR         PARSEDNDEST                                          
RTN_PARSEOR     JSR         ORERRCHK                        *CHECK FOR ERRORS, $BEEF AT $456 IF ERRORS EXISTS
                CMP.W       #$BEEF, $456                     *IF $BEEF, APPEND BAD DATA STRING TO A2
                BEQ         ORBADDATA
                JSR         APPENDEA                         *APPEND DESTINATION EA
                MOVE.B      D2, D0
                MOVE.B      D3, D1
                MOVE.B      #',', (A2)+
                MOVE.B      #' ', (A2)+
                JSR         APPENDEA
                MOVEM.L     $400, D0-D7/A0/A1/A3-A5
RTN_OR          RTS

*---------------------------------------------------------------------------------------------------------
*OR BAD DATA - CHECKS FOR ILLEGAL ADDRESSING MODES AND APPENDS BAD DATA TO A2 IF THEY ARE USED
*---------------------------------------------------------------------------------------------------------
ORBADDATA       JSR         BADDATA
                JMP         RTN_OR
ORERRCHK        CMPI.B      #5, D1
                BEQ         ORERR 
                CMPI.B      #6, D1
                BEQ         ORERR
                CMPI.B      #5, D3
                BEQ         ORERR 
                CMPI.B      #6, D3
                BEQ         ORERR
RTN_ORCHK       RTS
ORERR           MOVE.W      #$BEEF, $456
                JMP         RTN_ORCHK

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
                JMP         RTN_PARSEOR 

*---------------------------------------------------------------------------------------------------------
*PARSE DN DESTINATION - PARSES ADDRESSING REGISTER AND MODE IF DN IS KNOWN TO BE DESTINATION OPERAND
*---------------------------------------------------------------------------------------------------------
PARSEDNDEST     MOVE.W      #0, D3
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
                RTS


*-----------------------------------------------------------------------------------------------------------
**********************************************SHARED-CODE-SECTION******************************************* 
*-----------------------------------------------------------------------------------------------------------
*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~HEHE~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*
*-----------------------------------------------------------------------------------------------------------
**********************************************SHARED-CODE-SECTION******************************************* 
*-----------------------------------------------------------------------------------------------------------

*---------------------------------------------------------------------------------------------------------
*RECOVER POINTER  - RECOVERS A2 IN CASE OF BAD DATA (INSUPPORTED ADDRESSING MODES)
*---------------------------------------------------------------------------------------------------------
RECOVERPTR          CMPI.B      #1, D6
                    BEQ         INCPTRLONG  
                    ADDA        #2, A6
RTN_LONGPTR         RTS
INCPTRLONG          ADDA        #4, A6
                    JMP         RTN_LONGPTR

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
*CLEA ALL D REG - CLEARS ALL DATA REGISTERS, EXCEPT D6....I NEED IT, DONT ASK
*--------------------------------------------------------------------------------------------------------- 
CLRALLDREG          CLR         D0
                    CLR         D1
                    CLR         D2
                    CLR         D3
                    CLR         D4
                    CLR         D5
                    CLR         D7
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






*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
