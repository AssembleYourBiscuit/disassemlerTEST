*-----------------------------------------------------------
* Title      :
* Written by :
* Date       :
* Description:
*-----------------------------------------------------------

CR          EQU     $0D
LF          EQU     $0A

    ORG    $1000
START:                  ; first instruction of program
* Put program code here
main        JSR     welcome
            JSR     getStart
            JMP     promptCont
    
welcome     LEA     WelcomeMsg,A1       ;Load welcome message
            MOVE.B  #14,D0              ;Display the welcome message
            TRAP    #15                 ;to the user
            LEA     WrtBy,A1            ;Load the Writen by message
            MOVE.B  #14,D0              ;Display the authority
            TRAP    #15                 ;
            MOVEA   #$0,A1              ;Clear register A1
            LEA     note1,A1            ;Load precondition messages 
            MOVE.B  #14,D0              ;
            TRAP    #15                 ;and
            LEA     note2,A1            ;Display
            MOVE.B  #14,D0              ;the
            TRAP    #15                 ;preconditions
            LEA     note3,A1            ;message
            MOVE.B  #14,D0              ;
            TRAP    #15                 ;
            RTS
            
getStart    LEA     startLoc,A1         ;Load the prompting message startLoc
            MOVE.B  #14,D0              ;Display the prompt message for the starting location
            TRAP    #15                 ;for the user to enter the starting location
            MOVEA   #$0,A1              ;clear A1
            MOVEA.W startAddr,A6        ;get a pointer to the memory location A6
            MOVEA.W startAddr,A1        ;get a pointer point to A1 (to copy to A6 later)
            MOVE.L  #2,d0               ;Get the user input 
            TRAP    #15                 ;(user input will store in (A1))
            MOVE.L  (A1),A6             ;Move whatever at address A1 to A6
            JSR     getEnd              ;After done dealing with starting address, call getEnd
            RTS
            
getEnd      LEA     endLoc,A1           ;Load the prompting message endLoc
            MOVE.B  #14,D0              ;Display the prompt message for the ending location
            TRAP    #15                 ;for the user to enter the ending location
            MOVEA   #$0,A1              ;clear A1
            MOVEA.W endAddr,A6          ;get a pointer to the memory location A6
            MOVEA.W endAddr,A1          ;get a pointer point to A1 (to copy to A6 later)
            MOVE.L  #2,d0               ;Get the user input 
            TRAP    #15                 ;(user input will store in (A1))
            MOVE.L  (A1),A6
            RTS    
            
    
promptCont  LEA     AskToCont,A1
            MOVE.B  #14,D0
            TRAP    #15
            MOVEA.w string,A1    ;put 800 in register to use to point to the memory
            MOVE.B  #2, d0
            TRAP    #15
            CMP.B   #$79, (A1)      ;Check if the user enter 'y'
            BEQ     continue        ;If yes, branch to getaddress
            CMP.B   #$59, (A1)      ;Check if the user enter 'Y'
            BEQ     continue
            CMP.B   #$6e, (A1)
            BEQ     end
            CMP.B   #$4e, (A1)
            BEQ     end
            RTS         
    
    
continue    MOVE.W #$BEEF, d6
            RTS

end         LEA     ThxMsg,A1
            MOVE.B  #14,D0
            TRAP    #15    
            MOVE.B  #9, d0
            TRAP    #15

            SIMHALT             ; halt simulator

* Put variables and constants here
*-----------Output texts------------------------------------
WelcomeMsg  DC.b    'Welcome to EASy68K Instruction Disassembler!',CR,LF,0
WrtBy       DC.B    'Created by: Vuochly Ky, Kunlakan Cherdchusilp, Nicolas Michael',CR,LF,CR,LF,0
note1       DC.B    'Preconditions: ',CR,LF,0
note2       DC.B    '   -- The address location inputs must be in hexadecimal format',CR,LF,0
note3       DC.B    '   -- Address must be in the range of $0 ~ $00FFFFFE',CR,LF,0
startLoc    DC.l    'Please enter the starting location in hexadecimal format: ',0
endLoc      DC.B    'Please enter the ending location in hexadecimal format: ',0
AskToCont   DC.B    'Would you like to start over? (y/n) :',0
MoreCmd     DC.B    'Press ENTER key to see more.',0
ThxMsg      DC.B    'Thank you for using our EASy68K Instruction Disassembler!',0
string      DC.w    $800
startAddr   DC.w    $900
endAddr     DC.w    $908
    END    START        ; last line of source





*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
