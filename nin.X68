*-----------------------------------------------------------
* Title      :
* Written by :
* Date       :
* Description:
*-----------------------------------------------------------
    ORG    $1000
START:                  ; first instruction of program

* Put program code here

    movea   #$8000, a7
    move.l  #$62656566, (a7)
    move.b  (a7), d0
    addq    #1, a7
    move.b  (a7), d1
    addq    #1, a7
    move.b  (a7), d2
    addq    #1, a7
    move.b  (a7), d3
    sub.b   #$57, d0
    sub.b   #$57, d1
    sub.b   #$57, d2
    sub.b   #$57, d3
    

     

    SIMHALT             ; halt simulator

* Put variables and constants here

    END    START        ; last line of source

*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
