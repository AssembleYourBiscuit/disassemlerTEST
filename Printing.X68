main        JSR     getStart
            JSR     getEnd              ;After done dealing with starting address, call getEnd
            MOVE.B  #4,D7               ;INITIALIZE THE OUTPUT COUNTER
            JSR     DISPLAY
            
            
DISPLAY             MOVEA.L A2, A1
                    JSR     DISASSEMBLE
                    MOVE.B  #$0D, (A2)+
                    MOVE.B  #$0A, (A2)+
                    MOVE.B  #$0, (A2)+
                    MOVE.B  #14, D0
                    TRAP    #15
                    SUB.B   #1,D7
                    CMP.B   #1,D7
                    BEQ     ENTR
                    JSR     ISEND
                    RTS                    
                    
ENTR                JSR     CHKEND
                    LEA     enter,A1    ;PRINT THE ENTER-TO-SHOW-MORE MESSAGE
                    MOVE.B  #14,D0
                    TRAP    #15
                    MOVEA.L ent,A1
                    MOVE.B  #2,D0
                    TRAP    #15
                    CMP.B   #$20,(A1)       ;20 IS SPACE
                    BEQ     ISEND
                    JMP     CONTI

CONTI               MOVE.B  #4,D7   ;reset the counter
ISEND               CMP.L   A5,A6
                    BNE     DISPLAY
                    JMP     promptCont

CHKEND              CMP.L   A5,A6
                    BEQ     promptCont
                    RTS  
*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
