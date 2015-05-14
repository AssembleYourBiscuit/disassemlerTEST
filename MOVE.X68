*-----------------------------------------------------------
* Title      :
* Written by :
* Date       :
* Description:
*-----------------------------------------------------------
    ORG    $1000
START:                  ; first instruction of program

* Put program code here
             move.b D0, $7EEF                *STUFF                  
             move.L #$11C07EEF, $8000        *FOR
             *move.W #$AFFE, $8004           *DOING
             MOVEA.L    #$8000, A6           *SOME
             MOVE.W $8000, D7                *TESTING
             JSR    isMOVEBW                 *MUST
             
<<<<<<< HEAD
             * END PROGRAM
end          MOVE.B #9, D0
             TRAP #15

*---------------------------------------------------------------------------------------------------------
*isMOVEAW          (IS MOVEA.W)- TO BE CALLED IF CURRENT INSTRUCTION POINTED TO BY A6 AND INSIDE 
*                  D7 IS A KNOWN MOVE.B OR MOVEA.W COMMAND.
*
*PRE CONDITIONS -  A6 POINTS TO CURRENT INSTRUCTION, D7 CONTAINS CURRENT INSTRUCTION
*
*POST CONDITIONS - D6, D5, D4, D3 CONTAIN SOURCE REGISTER, DESTINATION REGISTER, SOURCE MODE, DESTINATION
*                  REGISTER RESPECTIVELY. iF ERRORS, D2 CONTAINS $BEEF (YUM). A6 POINTS TO NEXT INSTRUCTION 
*                  TO DISASSEMBLE, IF A5 CONTAINS A NON-ZERO ADDRESS, ABSOLUTE AND OR IMMEDIATE 
*                  ADRESSING WAS USED AND DATA POINTED TO BY A5 NEEDS TO BE PRINTED.
*---------------------------------------------------------------------------------------------------------
isMOVEAW    ADDQ.W  #2, A6          *KEEP A6 CURRENT
            JSR     getSREG         *PARSE REGISTERS AND MODES
            JSR     getDREG
            JSR     getSMODE
            JSR     getDMODE
            JSR     sModeErr        *CHECK FOR ERRORS IN REGISTERS D3 and D4 (source and destination modes)
            JSR     dModeErrAW
            CMP.L   #$BEEF, D2      *CHECK FOR ERROR FLAG BEEF (MMM) AND RETURN IF SET
            BNE     chkAddMAW       *CHECK ADDRESSING MODES FOR WORDB SPECS
            RTS
            
*CHECK FOR ERRORS CONTAINED IN DESTINATION MODE (DESTINATION MODE ERROR MOVEA.W)       
dModeErrAW  CMP.L   #1, D3          *DESTINATION MODE MUST BE 1
            BNE     setEAErr        *SET EFFECTIVE ADDRESS ERROR
            RTS
            
*CHECKS ADDRESSING MODES FOR IMMEDIATE DATA OR ABSOLUTE ADDRESSING SO THEY CAN BE APPENDED BY IO  
chkAddMAW   MOVEA.l  #0, A5
            MOVEA.l  #0, A4
            CMP.L    #7, D4          
            BEQ      chkSAddAW  
rtn_cAMAW   RTS 

chkSAddAW   CMP.L   #0, D6
            BEQ     wordModeSAW 
            CMP.L   #1, D6
            BEQ     longModeSAW
            CMP.L   #4, D6
            BEQ     immediateModeSAW
            RTS
            
*I HAVE NO IDEA IF THIS WORKS, MIGHT WANNA TEST SOME TIME SOON         
wordModeSAW MOVEA.L A6, A5          *STORE WORD IN A5 SO IO CAN PRINT IT
            ADDQ.W  #2, A6          *KEEP A6 ON CURRENT INSTRUCTION
            JMP rtn_cAMAW
            
*I HAVE NO IDEA IF THIS WORKS, MIGHT WANNA TEST SOME TIME SOON         
longModeSAW MOVEA.L A6, A5          *STORE LING IN A5 SO IO CAN PRINT IT
            ADDQ.W  #4, A6          *KEEP A6 ON CURRENT INSTRUCTION
            JMP rtn_cAMAW
            
*if immediate mode found get pointer to data in a5 so IO can print       
immediateModeSAW MOVEA.L  A6, A5
                 ADDQ.W  #2, A6          *KEEP A6 ON CURRENT INSTRUCTION
                 JMP rtn_cAMAW
          
=======
             * END PROGRAM                   *REMOVE
end          MOVE.B #9, D0                   *THESE
             TRAP #15                        *LINES
             
>>>>>>> origin/master
*---------------------------------------------------------------------------------------------------------
*isMOVEBW          (IS MOVE.B OR MOVE.W)- TO BE CALLED IF CURRENT INSTRUCTION POINTED TO BY A6 AND INSIDE 
*                  D7 IS A KNOWN MOVE.B OR MOVE.W COMMAND. EA IS IDENTICLE FOR MOVE.B AND MOVE.W.
*
*PRE CONDITIONS -  A6 POINTS TO CURRENT INSTRUCTION, D7 CONTAINS CURRENT INSTRUCTION
*
*POST CONDITIONS - D6, D5, D4, D3 CONTAIN SOURCE REGISTER, DESTINATION REGISTER, SOURCE MODE, DESTINATION
*                  MODE RESPECTIVELY. iF ERRORS, D2 CONTAINS $BEEF (YUM). A6 POINTS TO NEXT INSTRUCTION 
*                  TO DISASSEMBLE, IF A5 OR A4 CONTAIN NON-ZERO ADDRESSES, ABSOLUTE AND OR IMMEDIATE 
*                  ADRESSING WAS USED AND DATA POINTED TO BY A5 AND OR A4 NEED TO BE PRINTED IN THAT ORDER.
*---------------------------------------------------------------------------------------------------------
isMOVEBW    ADDQ.W  #2, A6          *KEEP A6 CURRENT
            JSR     getSREG         *PARSE REGISTERS AND MODES
            JSR     getDREG
            JSR     getSMODE
            JSR     getDMODE
            JSR     sModeErr        *CHECK FOR ERRORS IN REGISTERS D3 and D4 (source and destination modes)
            JSR     dModeErr
            CMP.L   #$BEEF, D2      *CHECK FOR ERROR FLAG BEEF (MMM) AND RETURN IF SET
            BNE     chkAddM         *CHECK ADDRESSING MODES FOR WORDB SPECS
            RTS
            
*CHECKS ADDRESSING MODES FOR IMMEDIATE DATA OR ABSOLUTE ADDRESSING SO THEY CAN BE APPENDED BY IO  
chkAddM     MOVEA.l  #0, A5
            MOVEA.l  #0, A4
            CMP.L    #7, D4          
            BEQ      chkSAdd  
rtn_cAM     CMP.L    #7, D3          
            BEQ      chkDAdd  
rtn_cAM2    RTS  

chkSAdd     CMP.L   #0, D6
            BEQ     wordModeS 
            CMP.L   #1, D6
            BEQ     longModeS
            CMP.L   #4, D6
            BEQ     immediateModeS
            RTS
            
chkDAdd     CMP.L   #0, D5
            BEQ     wordModeD 
            CMP.L   #1, D5
            BEQ     longModeD
            RTS
   
*I HAVE NO IDEA IF THIS WORKS, MIGHT WANNA TEST SOME TIME SOON         
wordModeS   MOVEA.L A6, A5          *STORE WORD IN A5 SO IO CAN PRINT IT
            ADDQ.W  #2, A6          *KEEP A6 ON CURRENT INSTRUCTION
            JMP rtn_cAM
            
*I HAVE NO IDEA IF THIS WORKS, MIGHT WANNA TEST SOME TIME SOON         
longModeS   MOVEA.L A6, A5          *STORE LING IN A5 SO IO CAN PRINT IT
            ADDQ.W  #4, A6          *KEEP A6 ON CURRENT INSTRUCTION
            JMP rtn_cAM
            
*if immediate mode found get pointer to data in a5 so IO can print       
immediateModeS MOVEA.L  A6, A5
               ADDQ.W  #2, A6          *KEEP A6 ON CURRENT INSTRUCTION
               JMP rtn_cAM
               
*I HAVE NO IDEA IF THIS WORKS, MIGHT WANNA TEST SOME TIME SOON         
wordModeD   MOVEA.L A6, A4          *STORE WORD IN A4 SO IO CAN PRINT IT
            ADDQ.W  #2, A6          *
            JMP rtn_cAM2
            
*IDENTICAL TO WORDMODED CLEAN UP LATER!       
longModeD   MOVEA.L A6, A4          *STORE LING IN A4 SO IO CAN PRINT IT
            ADDQ.W  #4, A6          *KEEP A6 ON CURRENT INSTRUCTION
            JMP rtn_cAM2
         
*CHECK FOR ERRORS CONTAINED IN SOURCE MODE      
sModeErr    CMP.L   #5, D4          *MODE CANNOT BE 5
            BEQ     setEAErr
            CMP.L   #6, D4          *MODE CANNOT BE 6
            BEQ     setEAErr
            CMP.L   #7, D4          *IF MODE IS 7 CHECK REGISTERS FOR ERRORS
            BEQ     sIErr
            RTS
    
*CHECK FOR ERRORS CONTAINED IN DESTINATION MODE        
dModeErr    CMP.L   #1, D3          *DESTINATION MODE CANNOT BE 1
            BEQ     setEAErr
            CMP.L   #7, D3          *IF MODE IS 7 CHECK REGISTERS FOR ERRORS
            BEQ     dIErr
            CMP.L   #5, D3          *MODE CANNOT BE 5
            BEQ     setEAErr
            CMP.L   #6, D3          *MODE CANNOT BE 6
            BEQ     setEAErr
            RTS
 
*CHECK FOR ERRORS IN DESTINATION ADDRESSING MODES ABSOLUTE AND IMMEDIATE           
dIErr       CMP.L   #1, D5          *DESTINATION REGISTER CANNOT BE GREATER THAN 1 WITH MODE 7
            BGT     setEAErr
            RTS
    
*CHECK FOR ERRORS IN SOURCE ADDRESSING MODES ABSOLUTE AND IMMEDIATE        
sIErr       CMP.L   #2, D6          *REGISTER 2 CANNOT BE USED WITH MODE 7
            BEQ     setEAErr
            CMP.L   #3, D6          *REGISTER 3 CANNOT BE USED WITH MODE 7
            BEQ     setEAErr
            CMP.L   #4, D6          *ALL REGISTERS GREATER THAN 4 CANNOT BE USED WITH MODE 7
            BGT     setEAErr
            RTS
            
*D2 WILL BE SET TO BEEF (MMM)FLAG IF ERRORS ARE FOUND IN EA
setEAErr    CLR     D2
            MOVE.W  #$BEEF, D2
            RTS

*SETS THE SOURCE REGISTER FOR A MOVE COMMAND TO D6          
getSREG     CLR     D6
            MOVE.L  D7, D6
            LSL.L   #8, D6
            LSL.L   #8, D6
            LSL.L   #8, D6
            LSL.L   #5, D6
            LSR.L   #8, D6
            LSR.L   #8, D6
            LSR.L   #8, D6
            LSR.L   #5, D6
            RTS

*SETS DESTINATION REGISTER FOR MOVE COMMAND TO D5            
getDREG     CLR     D5
            MOVE.L  D7, D5
            LSL.L   #8, D5
            LSL.L   #8, D5
            LSL.L   #4, D5
            LSR.L   #8, D5
            LSR.L   #8, D5
            LSR.L   #8, D5
            LSR.L   #5, D5
            RTS

*SETS SOURCE MODE FOR MOVE COMMAND TO D4            
getSMODE    CLR     D4
            MOVE.L  D7, D4
            LSL.L   #8, D4
            LSL.L   #8, D4
            LSL.L   #8, D4
            LSL.L   #2, D4
            LSR.L   #8, D4
            LSR.L   #8, D4
            LSR.L   #8, D4
            LSR.L   #5, D4
            RTS    

*GETS DESTNATION MODE FROM MOVE COMMAND, PUTS IN D3
getDMODE    CLR     D3
            MOVE.L  D7, D3
            LSL.L   #8, D3
            LSL.L   #8, D3
            LSL.L   #7, D3
            LSR.L   #8, D3
            LSR.L   #8, D3
            LSR.L   #8, D3
            LSR.L   #5, D3
            RTS    

           
*---------------------------------------------------------------------------------------------------------
*isMOVEL           (IS MOVE.L)- TO BE CALLED IF CURRENT INSTRUCTION POINTED TO BY A6 AND INSIDE 
*                  D7 IS A KNOWN MOVE.L COMMAND.
*
*PRE CONDITIONS -  A6 POINTS TO CURRENT INSTRUCTION, D7 CONTAINS CURRENT INSTRUCTION
*
*POST CONDITIONS - D6, D5, D4, D3 CONTAIN SOURCE REGISTER, DESTINATION REGISTER, SOURCE MODE, DESTINATION
*                  MODE RESPECTIVELY. iF ERRORS, D2 CONTAINS $BEEF (YUM). A6 POINTS TO NEXT INSTRUCTION 
*                  TO DISASSEMBLE, IF A5 OR A4 CONTAIN NON-ZERO ADDRESSES, ABSOLUTE AND OR IMMEDIATE 
*                  ADRESSING WAS USED AND DATA POINTED TO BY A5 AND OR A4 NEED TO BE PRINTED IN THAT ORDER.
*--------------------------------------------------------------------------------------------------------- 
isMOVEL     ADDQ.W  #2, A6          *KEEP A6 CURRENT
            JSR     getSREG
            JSR     getDREG
            JSR     getSMODE
            JSR     getDMODE
            JSR     sModeErr        *CHECK FOR ERRORS IN REGISTERS D3 and D4 (source and destination modes)
            JSR     dModeErr
            CMP.L   #$BEEF, D2      *CHECK FOR ERROR FLAG BEEF (MMM) AND RETURN IF SET
            BNE     chkAddML        *CHECK ADDRESSING MODE FOR MOVEW SPECS
            RTS
            
chkAddML    MOVEA.l  #0, A5         *CLEAR ADDRESS REGISTERS 5 AND 4
            MOVEA.l  #0, A4 
            CMP.L    #7, D4         *IS SOURCE MODE 111?
            BEQ      chkSAddL       *THEN CHECK FOR WORD, LONG, OR IMMEDIATE ADDRESSING
rtn_cAML    CMP.L    #7, D3         *IS DESTINATION REGISTER 111? 
            BEQ      chkDAddL       *THEN CHECK FOR WORD OR LONG ADDRESSING
rtn_cAM2L   RTS 

chkSAddL    CMP.L   #0, D6
            BEQ     wordModeSL 
            CMP.L   #1, D6
            BEQ     longModeSL
            CMP.L   #4, D6
            BEQ     immediateModeSL
            RTS
            
chkDAddL    CMP.L   #0, D5
            BEQ     wordModeDL 
            CMP.L   #1, D5
            BEQ     longModeDL
            RTS
            
wordModeSL  MOVEA.L A6, A5          *STORE WORD IN A5 SO IO CAN PRINT IT
            ADDQ.W  #2, A6          *KEEP A6 ON CURRENT INSTRUCTION
            JMP rtn_cAML
            
longModeSL  MOVEA.L A6, A5          *STORE LING IN A5 SO IO CAN PRINT IT
            ADDQ.W  #4, A6          *KEEP A6 ON CURRENT INSTRUCTION
            JMP rtn_cAML
            
*if immediate mode found get pointer to data in a5 so IO can print       
immediateModeSL MOVEA.L  A6, A5
                ADDQ.W  #4, A6          *KEEP A6 ON CURRENT INSTRUCTION
                JMP rtn_cAML
            
*I HAVE NO IDEA IF THIS WORKS, MIGHT WANNA TEST SOME TIME SOON         
wordModeDL  MOVEA.L A6, A4          *STORE WORD IN A4 SO IO CAN PRINT IT
            ADDQ.W  #2, A6          *
            JMP rtn_cAM2L
            
*IDENTICAL TO WORDMODED CLEAN UP LATER!       
longModeDL  MOVEA.L A6, A4          *STORE LING IN A4 SO IO CAN PRINT IT
            ADDQ.W  #4, A6          *KEEP A6 ON CURRENT INSTRUCTION
            JMP rtn_cAM2L 
 

             

    END    START        ; last line of source







*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
