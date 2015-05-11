*-----------------------------------------------------------
* Title      :
* Written by :
* Date       :
* Description:
*-----------------------------------------------------------
    ORG    $1000
START:                  ; first instruction of program

* Put program code here
                                               
             move.w #$1cc7, d7            *1cc7 = move.b d7, (a6)+ 0001 110 011 000 111
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
            CMP.L   #2, D6
            BEQ     immediateModeS
            RTS
            
chkDAdd     CMP.L   #0, D5
            BEQ     wordModeD 
            CMP.L   #1, D5
            BEQ     longModeD
            RTS
   
*I HAVE NO IDEA IF THIS WORKS, MIGHT WANNA TEST SOME TIME SOON         
wordModeS   ADDQ.W  #4, A6          *SHIFT A6 1 WORD (NOT SURE IF THIS WORKS...!!!!!!) 
            MOVEA.W A6, A5          *STORE WORD IN A5 SO IO CAN PRINT IT
            RTS
            
*I HAVE NO IDEA IF THIS WORKS, MIGHT WANNA TEST SOME TIME SOON         
longModeS   ADDQ.W  #4, A6          *SHIFT A6 1 WORD (NOT SURE IF THIS WORKS...!!!!!!) 
            MOVEA.L A6, A5          *STORE LING IN A5 SO IO CAN PRINT IT
            RTS
            
*I HAVE NO IDEA IF THIS WORKS, MIGHT WANNA TEST SOME TIME SOON         
immediateModeS ADDQ.W  #4, A6          *SHIFT A6 1 WORD (NOT SURE IF THIS WORKS...!!!!!!) 
               MOVEA.W A6, A5          *STORE LING IN A5 SO IO CAN PRINT IT
               RTS
               
*I HAVE NO IDEA IF THIS WORKS, MIGHT WANNA TEST SOME TIME SOON         
wordModeD   ADDQ.W  #4, A6          *SHIFT A6 1 WORD (NOT SURE IF THIS WORKS...!!!!!!) 
            MOVEA.W A6, A4          *STORE WORD IN A4 SO IO CAN PRINT IT
            RTS
            
*I HAVE NO IDEA IF THIS WORKS, MIGHT WANNA TEST SOME TIME SOON         
longModeD   ADDQ.W  #4, A6          *SHIFT A6 1 WORD (NOT SURE IF THIS WORKS...!!!!!!) 
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

*SETS THE SOURCE REGISTER FOR A MOVEB COMMAND TO D6          
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

*SETS DESTINATION REGISTER FOR MOVEB COMMAND TO D5            
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

*SETS SOURCE MODE FOR MOVEB COMMAND TO D4            
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

******************INGNORE CODE BELOW JUST USED TO TEST MY EA STUFF***********************  
    
printDREGF   CMP.W   #0, D6
             BEQ     printDREG0
             CMP.W   #1, D6
             BEQ     printDREG1
             CMP.W   #2, D6
             BEQ     printDREG2
             CMP.W   #3, D6
             BEQ     printDREG3
             CMP.W   #4, D6
             BEQ     printDREG4
             CMP.W   #5, D6
             BEQ     printDREG5
             CMP.W   #6, D6
             BEQ     printDREG6
             CMP.W   #7, D6
             BEQ     printDREG7
             RTS
             
printDREGS   CMP.W   #0, D5
             BEQ     printDREG0
             CMP.W   #1, D5
             BEQ     printDREG1
             CMP.W   #2, D5
             BEQ     printDREG2
             CMP.W   #3, D5
             BEQ     printDREG3
             CMP.W   #4, D5
             BEQ     printDREG4
             CMP.W   #5, D5
             BEQ     printDREG5
             CMP.W   #6, D5
             BEQ     printDREG6
             CMP.W   #7, D5
             BEQ     printDREG7
             RTS
             
printAREGF   CMP.W   #0, D6
             BEQ     printAREG0
             CMP.W   #1, D6
             BEQ     printAREG1
             CMP.W   #2, D6
             BEQ     printAREG2
             CMP.W   #3, D6
             BEQ     printAREG3
             CMP.W   #4, D6
             BEQ     printAREG4
             CMP.W   #5, D6
             BEQ     printAREG5
             CMP.W   #6, D6
             BEQ     printAREG6
             RTS
             
printAREGS   CMP.W   #0, D5
             BEQ     printAREG0
             CMP.W   #1, D5
             BEQ     printAREG1
             CMP.W   #2, D5
             BEQ     printAREG2
             CMP.W   #3, D5
             BEQ     printAREG3
             CMP.W   #4, D5
             BEQ     printAREG4
             CMP.W   #5, D5
             BEQ     printAREG5
             CMP.W   #6, D5
             BEQ     printAREG6
             RTS
             
printAPIREGF CMP.W   #0, D6
             BEQ     printAPIREG0
             CMP.W   #1, D6
             BEQ     printAPIREG1
             CMP.W   #2, D6
             BEQ     printAPIREG2
             CMP.W   #3, D6
             BEQ     printAPIREG3
             CMP.W   #4, D6
             BEQ     printAPIREG4
             CMP.W   #5, D6
             BEQ     printAPIREG5
             CMP.W   #6, D6
             BEQ     printAPIREG6
             RTS
             
printAPIREGS CMP.W   #0, D5
             BEQ     printAPIREG0
             CMP.W   #1, D5
             BEQ     printAPIREG1
             CMP.W   #2, D5
             BEQ     printAPIREG2
             CMP.W   #3, D5
             BEQ     printAPIREG3
             CMP.W   #4, D5
             BEQ     printAPIREG4
             CMP.W   #5, D5
             BEQ     printAPIREG5
             CMP.W   #6, D5
             BEQ     printAPIREG6
             RTS
             
printAIREGS  CMP.W   #0, D5
             BEQ     printAIREG0
             CMP.W   #1, D5
             BEQ     printAIREG1
             CMP.W   #2, D5
             BEQ     printAIREG2
             CMP.W   #3, D5
             BEQ     printAIREG3
             CMP.W   #4, D5
             BEQ     printAIREG4
             CMP.W   #5, D5
             BEQ     printAIREG5
             CMP.W   #6, D5
             BEQ     printAIREG6
             RTS
            
printDREG0  LEA     stringD0, A1
            JSR     LOAD
            RTS
            
printDREG1  LEA     stringD1, A1
            JSR     LOAD
            RTS
            
printDREG2  LEA     stringD2, A1
            JSR     LOAD
            RTS
            
printDREG3  LEA     stringD3, A1
            JSR     LOAD
            RTS
            
printDREG4  LEA     stringD4, A1
            JSR     LOAD
            RTS
            
printDREG5  LEA     stringD5, A1
            JSR     LOAD
            RTS
            
printDREG6  LEA     stringD6, A1
            JSR     LOAD
            RTS
            
printDREG7  LEA     stringD7, A1
            JSR     LOAD
            RTS
            
printAREG0  LEA     stringA0, A1
            JSR     LOAD
            RTS
            
printAREG1  LEA     stringA1, A1
            JSR     LOAD
            RTS
            
printAREG2  LEA     stringA2, A1
            JSR     LOAD
            RTS
            
printAREG3  LEA     stringA3, A1
            JSR     LOAD
            RTS
            
printAREG4  LEA     stringA4, A1
            JSR     LOAD
            RTS
            
printAREG5  LEA     stringA5, A1
            JSR     LOAD
            RTS
            
printAREG6  LEA     stringA6, A1
            JSR     LOAD
            RTS
            
printAPIREG0 LEA     stringA0PI, A1
             JSR     LOAD
             RTS
            
printAPIREG1 LEA     stringA1PI, A1
             JSR     LOAD
             RTS
            
printAPIREG2 LEA     stringA2PI, A1
             JSR     LOAD
             RTS
            
printAPIREG3 LEA     stringA3PI, A1
             JSR     LOAD
             RTS
            
printAPIREG4 LEA     stringA4PI, A1
             JSR     LOAD
             RTS
            
printAPIREG5 LEA     stringA5PI, A1
             JSR     LOAD
             RTS
            
printAPIREG6 LEA     stringA6PI, A1
             JSR     LOAD
             RTS
             
printAIREG0  LEA     stringA0I, A1
             JSR     LOAD
             RTS
            
printAIREG1  LEA     stringA1I, A1
             JSR     LOAD
             RTS
            
printAIREG2  LEA     stringA2I, A1
             JSR     LOAD
             RTS
            
printAIREG3  LEA     stringA3I, A1
             JSR     LOAD
             RTS
            
printAIREG4  LEA     stringA4I, A1
             JSR     LOAD
             RTS
            
printAIREG5  LEA     stringA5I, A1
             JSR     LOAD
             RTS
            
printAIREG6  LEA     stringA6I, A1
             JSR     LOAD
             RTS
            
load        MOVE.B  #14, D0
            TRAP    #15
            RTS      

* Put variables and constants here
stringD0    DC.B    'D0', 0
stringD1    DC.B    'D1', 0
stringD2    DC.B    'D2', 0
stringD3    DC.B    'D3', 0
stringD4    DC.B    'D4', 0
stringD5    DC.B    'D5', 0
stringD6    DC.B    'D6', 0
stringD7    DC.B    'D7', 0

stringA0    DC.B    'A0', 0
stringA1    DC.B    'A1', 0
stringA2    DC.B    'A2', 0
stringA3    DC.B    'A3', 0
stringA4    DC.B    'A4', 0
stringA5    DC.B    'A5', 0
stringA6    DC.B    'A6', 0

stringA0I   DC.B    '(A0)', 0
stringA1I   DC.B    '(A1)', 0
stringA2I   DC.B    '(A2)', 0
stringA3I   DC.B    '(A3)', 0
stringA4I   DC.B    '(A4)', 0
stringA5I   DC.B    '(A5)', 0
stringA6I   DC.B    '(A6)', 0

stringA0PI  DC.B    '(A0)+', 0
stringA1PI  DC.B    '(A1)+', 0
stringA2PI  DC.B    '(A2)+', 0
stringA3PI  DC.B    '(A3)+', 0
stringA4PI  DC.B    '(A4)+', 0
stringA5PI  DC.B    '(A5)+', 0
stringA6PI  DC.B    '(A6)+', 0

stringA0PD  DC.B    '-(A0)', 0
stringA1PD  DC.B    '-(A1)', 0
stringA2PD  DC.B    '-(A2)', 0
stringA3PD  DC.B    '-(A3)', 0
stringA4PD  DC.B    '-(A4)', 0
stringA5PD  DC.B    '-(A5)', 0
stringA6PD  DC.B    '-(A6)', 0

stringPOUND DC.B    '#', 0
stringHEX   DC.B    '$', 0
stringBADDATA DC.B  'BAD DATA', 0

stringMOVEB DC.B    'MOVE.B', 0


    END    START        ; last line of source


*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
