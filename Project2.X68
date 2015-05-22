*-----------------------------------------------------------
* Title      :
* Written by :
* Date       :
* Description:
*-----------------------------------------------------------

CR          EQU     $0D
LF          EQU     $0A
starting    EQU     $00000400
ending      EQU     $00FFFFFE
outData     EQU     $10000



    ORG    $1000
START:                  ; first instruction of program
* Put program code here
            MOVEA.L #outData, A2        ;This location is where disassembled instruction is stored

    
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
            LEA     note4,A1            ;
            MOVE.B  #14,D0              ;
            TRAP    #15                 ;

main        JSR     getStart
            JSR     getEnd              ;After done dealing with starting address, call getEnd
            JMP     promptCont
*-----------------------------------------------------------------
* GET THE STARTING ADDRESS
*-----------------------------------------------------------------         
getStart    LEA     startLoc,A1         ;Load the prompting message startLoc
            MOVE.B  #14,D0              ;Display the prompt message for the starting location
            TRAP    #15                 ;for the user to enter the starting location
            MOVEA   #$0,A1              ;Clear A1 
            CLR     D6                  ;Clear D6 before using it
            MOVEA.W startAddr,A1        ;Make a pointer point to A1 access data to decode
            MOVE.L  #2,d0               ;Get the user input (user input will store in (A1))
            TRAP    #15                 ;(The length of the user input will store in D1)
            JSR     validate            ;Validate and decode the user input and save the address in D6
            CMP.B   #0,D3               ;Check if the input is invalid (while validating) 0=good,1=bad
            BEQ     checkRangeS         ;If yes (good), check the if the address is within the range
errMsgS     LEA     error,A1            ;Load the error message
            MOVE.B  #14,D0              ;Display the error message
            TRAP    #15                 ;for the user to enter the starting location
            JSR     getStart           

checkRangeS JSR     checkOdd            ;Check if the STARTING address is odd (bad)
            CMP.B   #1,D3               ;Check if the input is not odd (0=even, 1=odd)
            BEQ     errMsgS             ;If =1, then print the input error message
            MOVE.L  #starting,D2        ;Check if the address is less than the 
            CMP.L   D2,D6               ;  specified starting address
            BLT     errMsgS             ;If yes, then print error message and prompt again
            MOVE.L  #ending,D2          ;Check if the address is greater than the 
            CMP.L   D2,D6               ;  specified ending address
            BGT     errMsgS             ;If yes, print input error msg and prompt for input again
            MOVEA.L D6,A6               ;THE STARTING ADDRESS IS VALID, SAVE IT IN A6

checkOdd    CLR.L   D5                  ;Clear D2 
            MOVE.W  D6,D5               ;Copy the address over to D5
            MOVE.L  #$00000002,D2       ;Put #2 into D2
            DIVU    D2,D5               ;Divide the address by 2
            SWAP    D5                  ;Swap the remainder and quotient (to access the remainder)
            CMP.B   #$01,D5             ;Check if the remainder is 1 
            BEQ     badInput            ;If remainder=1, it means the address is odd
            RTS 
*--------------------------------------------------------------
* GET THE ENDING ADDRESS
*--------------------------------------------------------------
getEnd      LEA     endLoc,A1           ;Load the prompting message endLoc
            MOVE.B  #14,D0              ;Display the prompt message for the ending location
            TRAP    #15                 ;for the user to enter the ending location
            MOVEA   #$0,A1              ;clear A1
            CLR     D6                  ;Clear D6 before using it
            MOVEA.W endAddr,A1          ;Make a pointer point to A1 for access data to decode
            MOVE.L  #2,d0               ;Get the user input 
            TRAP    #15                 ;(user input will store in (A1))
            JSR     validate            ;Validate and decode the user input and save decoded addr in D6
            CMP.B   #0,D3               ;Check if the input is invalid (while validating) 0=good,1=bad
            BEQ     checkRangeE         ;If yes (good), check the if the address is within the range
checkRangeE JSR     checkOdd            ;Check if the ENDING address is odd (bad)
            CMP.B   #1,D3               ;Check if the input is not odd (0=even, 1=odd)
            BEQ     errMsgE             ;If =1, then print the input error message
            MOVE.L  #starting,D2        ;Check if the address is less than the 
            CMP.L   D2,D6               ;  specified starting address
            BLT     errMsgE             ;If yes, then print error message and prompt again
            MOVE.L  #ending,D2          ;Check if the address is greater than the 
            CMP.L   D2,D6               ;  specified ending address
            BGT     errMsgE             ;If yes, print input error msg and prompt for input again
            MOVE.L  A6,D2               ;Move the given (user) starting addr to D2 to compare with ending
            CMP.L   D2,D6               ;Check if the address is less than the given starting address
            BLT     errMsgE             ;If yes, print the input error msg and prompt for input again
            MOVEA.L D6,A5               ;THE ENDING ADDRESS IS VALID, SAVE IT IN A5
            RTS            
errMsgE     LEA     error,A1            ;Load the error message
            MOVE.B  #14,D0              ;Display the error message
            TRAP    #15                 ;for the user to enter the starting location
            JSR     getEnd 
*---------------------------------------------------------------------
* VALIDATE EACH DIGITS OF THE USER INPUT AND DECODE INTO ACTUAL VALUE
* -- Check if the user input is not NULL or greater than 8 digits
* -- Check each character if it is valid. If valid, decode it.
* NOTE:
*   --Using D5 to temporary store each digit to validate
*   --Using D6 to store the converted address
*   --Using D3 to store the good(0) and bad(1) inputs
*---------------------------------------------------------------------
validate    MOVEQ   #$0,D2              ;Set D2 to 0 to compare if the input is null 
            CMP.B   D2,D0               ;Is the length of the user input = 0?
            BEQ     badInput            ;If yes return badInput
            CMPI    #$8,D0              ;Check if the length of the user input is 
            BGT     badInput            ;greater than 8 character. If yes, badInput
valLoop     MOVE.B  (A1),D5             ;Validation Loop, validate character by character
            CMP.B   D2,D5               ;Check if the next character is null
            BEQ     badInput            ;If null, return bad input
            CMP.B   #$66,D5             ;66 is ascii value of character 'f', highest in the valid range 
            BGT     badInput            ;If this digit is greater than 66
            CMP.B   #$60,D5             ;
            BGT     conLCase            ;
            CMP.B   #$46,D5             ;greater than 46?
            BGT     badInput            ;yes, then it's bad b/c it's between 'F' and 'a'
            CMP.B   #$40,D5             ;greater than 40?
            BGT     conUCase
            CMP.B   #$39,D5             ;is this number is geater than 9?
            BGT     badInput
            CMP.B   #$29,D5
            BGT     conNum
            
conLCase    SUB.B   #$57,D5              ;Convert the ASCII value of lower-case to actual value
            BRA     converted           ;After converted branch to converted to save
conUCase    SUB.B   #$37,D5              ;Convert the ASCII value of Upper-case to actual value
converted   ASL.L   #4,D6               ;Arithmetic Shift Left, shif the 4 bits to the left (4zeros added at the end)
            ADD.B   D5,D6               ;Now replace the 4 bits (0000) with the actual value
            ADDQ    #1,A1               ;Increment the address pointer, point to the next digit
            SUB.B   #1,D1               ;Decrement the length of the user input string
            CMP.B   #0,D1               ;Check if the length is 0 (done with all the digits?)
            BEQ     goodInput           ;If yes, give signal as good input
            BRA     valLoop             ;Else, keep validating the next digit
conNum      SUB.B   #$30,D5             ;Convert the ASCII value of number to actual number
            ASL.L   #4,D6               ;Arithmetic Shift Left, shif the 4 bits to the left (4zeros added at the end)
            ADD.B   D5,D6               ;Now replace the 4 bits (0000) with the actual number
            ADDQ    #1,A1               ;Increment the address pointer, point to the locatin of the next digit
            SUB.B   #1,D1               ;Decrement the length of the user input string
            CMP.B   #0,D1               ;Check if the length is 0 (done with all the digits?)
            BEQ     goodInput           ;If yes, give signal as good input
            BRA     valLoop             ;Else, keep validating the next digit
badInput    MOVEQ   #$1,D3              ;Give bad signal by
            RTS                         ;Put #1 into D3 to represent the bad input
goodInput   MOVEQ   #$0,D3              ;Give good signal by
            RTS                         ;Put #0 into D3 to represent the good input
*----------------------END VALIDATION/DECODING------------------------------------


promptCont  LEA     AskToCont,A1
            MOVE.B  #14,D0
            TRAP    #15
            MOVEA.w string,A1           ;put 800 in register to use to point to the memory
            MOVE.B  #2, d0
            TRAP    #15
            CMP.B   #$79, (A1)          ;Check if the user enter 'y'
            BEQ     main                ;If yes, branch to getaddress
            CMP.B   #$59, (A1)          ;Check if the user enter 'Y'
            BEQ     main                ;If yes, branch to getaddress
            CMP.B   #$6e, (A1)          ;Check if the user input is 'n'
            BEQ     end                 ;If yes, brach to end
            CMP.B   #$4e, (A1)          ;Check if the user input is 'N'
            BEQ     end                 ;If yes, branch to end        
    

end         LEA     ThxMsg,A1           ;Load the Thank-you message
            MOVE.B  #14,D0              ;Print it out
            TRAP    #15    
            MOVE.B  #9, d0          
            TRAP    #15

            SIMHALT             ; halt simulator

* Put variables and constants here
*-----------Output texts------------------------------------
WelcomeMsg  DC.b    'Welcome to EASy68K Instruction Disassembler!',CR,LF,0
WrtBy       DC.B    'Created by: Vuochly Ky, Kunlakan Cherdchusilp, Nicolas Michael',CR,LF,CR,LF,0
note1       DC.B    'Preconditions: ',CR,LF,0
note2       DC.B    '   -- The address inputs must be in hexadecimal number (without $)',CR,LF,0
note3       DC.B    '   -- Addresses must be in the range of 0 ~ 00FFFFFE',CR,LF,0
note4       DC.B    '   -- Both starting and ending address must be even addresses',CR,LF,0
startLoc    DC.B    'Please enter the starting location in hexadecimal format: ',0
endLoc      DC.B    'Please enter the ending location in hexadecimal format: ',0
AskToCont   DC.B    'Would you like to start over? (y/n) :',0
enter       DC.B    'Press ENTER key to see more.',0
ThxMsg      DC.B    'Thank you for using our EASy68K Instruction Disassembler!',0
string      DC.W    $80
startAddr   DC.W    $90
endAddr     DC.W    $98
error       DC.B    'The address you entered is whether invalid or out of range.',CR,LF,CR,LF,0
    END    START        ; last line of source













*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
