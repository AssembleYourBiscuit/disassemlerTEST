*-----------------------------------------------------------
* Title      :
* Written by :
* Date       :
* Description:
*-----------------------------------------------------------
    ORG    $1000
START:                  ; first instruction of program

* Put program code here
                                               
             move.L #$103C8008, $8000         
             MOVEA.L    #$8000, A6
             MOVE.W $8000, D7
             JSR    isMOVEB
             
             * END PROGRAM
             MOVE.B #9, D0
             TRAP #15
           
isMOVEB     JSR     getSREG         *PARSE REGISTERS AND MODES
            JSR     getDREG
            JSR     getSMODE
            JSR     getDMODE
            JSR     sModeErr        *CHECK FOR ERRORS IN REGISTERS D3 and D4 (source and destination modes)
            JSR     dModeErr
            CMP.L   #$BEEF, D2      *CHECK FOR ERROR FLAG BEEF (MMM) AND RETURN IF SET
            BNE     chkAddM         *CHECK ADDRESSING MODES
            RTS
 
*CHECKS ADDRESSING MODES FOR IMMEDIATE DATA OR ABSOLUTE ADDRESSING SO THEY CAN BE APPENDED BY IO  
chkAddM     MOVEA   #0, A5
            MOVEA   #0, A4
            CMP.L   #7, D4          
            BEQ     chkSAdd  
            CMP.L   #7, D3          
            BEQ     chkDAdd  
            RTS  

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
wordModeS   ADDQ.W  #2, A6          *SHIFT A6 1 WORD (NOT SURE IF THIS WORKS...!!!!!!) 
            MOVEA.W A6, A5          *STORE WORD IN A5 SO IO CAN PRINT IT
            RTS
            
*I HAVE NO IDEA IF THIS WORKS, MIGHT WANNA TEST SOME TIME SOON         
longModeS   ADDQ.W  #2, A6          *SHIFT A6 1 WORD (NOT SURE IF THIS WORKS...!!!!!!) 
            MOVEA.L A6, A5          *STORE LING IN A5 SO IO CAN PRINT IT
            RTS
            
*if immediate mode found get pointer to data in a5 so IO can print       
immediateModeS ADDQ.W  #2, A6          *increment A6 by 1 WORD so A6 points to immediate data
               MOVEA.L A6, A5          *STORE LONG IN A5 SO IO CAN PRINT IT, .L TO AVOID SIGN EXTENTION...I DONT LIKE IT
               RTS
               
*I HAVE NO IDEA IF THIS WORKS, MIGHT WANNA TEST SOME TIME SOON         
wordModeD   ADDQ.W  #2, A6          *SHIFT A6 1 WORD (NOT SURE IF THIS WORKS...!!!!!!) lmsd;flm
            MOVEA.W A6, A4          *STORE WORD IN A4 SO IO CAN PRINT IT
            RTS
            
*I HAVE NO IDEA IF THIS WORKS, MIGHT WANNA TEST SOME TIME SOON         
longModeD   ADDQ.W  #2, A6          *SHIFT A6 1 WORD (NOT SURE IF THIS WORKS...!!!!!!) 
            MOVEA.L A6, A4          *STORE LING IN A4 SO IO CAN PRINT IT
            RTS
         
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

             

    END    START        ; last line of source





*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
