*-----------------------------------------------------------
* Title      :
* Written by :
* Date       :
* Description:
*-----------------------------------------------------------
*================ Test Codes ===================
       ORG    $4000
************************** Unsupported Opcodes ******************************************
       CMP.B #3,D0
       MULU.W D2,D4
       MULS.W #5,D2
       DIVU.W D2,D4
       DIVS.W #6,D1
************************** Branching ******************************************
       BRA branch_always
       BLE branch_less_equal
       BEQ branch_equal
       BGT branch_greater 
       NOP
       RTS
       JSR $AAAAAAAA
       JSR $7FFF
       JSR (A5)

************************** LEA ******************************************  
       LEA $AAAA,A5
       LEA (A5),A6
       LEA $7000,A3
    
************************** Logical Shifting ******************************************
       LSL.B D1,D2
       LSL.B #5,D6
       LSL.W D1,D2
       LSL.W #5,D6
       LSL.L D1,D2
       LSL.L #5,D2            
       LSR.B D1,D2
       LSR.B #5,D6
       LSR.W D1,D2
       LSR.W #5,D6
       LSR.L D1,D2   
       LSR.L #5,D6
       LSR (A1)+
       LSL (A2)
       LSR -(A3)
       LSR $AAAAAAAA
       LSL $BBBB
************************** Rotation ******************************************  
            ROL.B D1,D2
            ROL.B #5,D6
            ROL.W D1,D2
            ROL.W #5,D6
            ROL.L D1,D2
            ROL.L #5,D2
            ROR.B D1,D2
            ROR.B #5,D6
            ROR.W D1,D2
            ROR.W #5,D6
            ROR.L D1,D2
            ROR.L #5,D6
            ROR (A1)+
            ROL (A2)
            ROR -(A3)
            ROR $AAAAAAAA
            ROL $BBBB
            
************************** Arithematic Shifting ******************************************
       ASL.B D1,D2
       ASL.B #5,D6
       ASL.W D1,D2
       ASL.W #5,D6
       ASL.L D1,D2
       ASL.L #5,D2            
       ASR.B D1,D2
       ASR.B #5,D6
       ASR.W D1,D2
       ASR.W #5,D6
       ASR.L D1,D2   
       ASR.L #5,D6
       ASR (A1)+
       ASL (A2)
       ASR -(A3)
       ASR $AAAAAAAA
       ASL $BBBB

************************** Move Quick ******************************************       
       MOVEQ #7,D5
       MOVEQ #5,D1
       MOVEQ #8,D3

************************** Move ******************************************
       MOVE.W #$AAAA,D0
       MOVE.L #$AAAA,D0
       MOVE.B (A5),D4
       MOVE.B D2,(A1)+
       MOVE.B (A0),(A6)
       MOVE.B -(A2),D7
       MOVE.B D4,$AAAA
       MOVE.B D2,$7EEE
       MOVE.B $AAAA,D4
       MOVE.B $7EEE,D2
       MOVE.W D2,(A1)+
       MOVE.W (A0),(A6)
       MOVE.W -(A2),D7
       MOVE.W D4,$AAAA
       MOVE.W D2,$7EEE
       MOVE.W $AAAA,D4
       MOVE.W $7EEE,D2
       MOVE.L D2,(A1)+
       MOVE.L (A0),(A6)
       MOVE.L -(A2),D7
       MOVE.L D4,$AAAA
       MOVE.L D2,$7EEE
       MOVE.L $AAAA,D4
       MOVE.L $7EEE,D2

************************** Move to address register ******************************************
       MOVEA.W D2,A5
       MOVEA.W $4777,A3
       MOVEA.L D2,A5
       MOVEA.L $E777,A3
       
************************** MOVEM ******************************************   
            MOVEM.L (SP)+,A1-A6
            MOVEM.W (SP)+,D1-D2
            MOVEM.L (SP)+, A1-A4/D1-D3
            MOVEM.L A1-A5,-(SP)
            MOVEM.W D1-D2/A2-A5,-(SP)
    
************************** Substraction ******************************************   
       SUB.B D2,D5
       SUB.W D3,D6
       SUB.L D6,D1
       SUB.B D2,(A2)+
       SUB.W D2,(A1)
       SUB.L D2,$7666
       SUB.L D5,$AAAABBBB
************************** Addition ******************************************
            ADD.B D2,D6
            ADD.W D2,D6
            ADD.L D2,D6     
            ADD.B D2,(A2)+
            ADD.W D2,(A1)
            ADD.L D2,$7666
            ADD.L D5,$AAAABBBB
************************** Addition ******************************************          
            ADDA.W D2,A5
            ADDA.W (A1)+,A2
            ADDA.W -(A2),A3
            ADDA.W (A2),A5
            ADDA.W $7733,A1      
            ADDA.L D2,A5
            ADDA.L (A1)+,A2
            ADDA.L -(A2),A3
            ADDA.L (A2),A5
            ADDA.L $AAAA7733,A1

************************** Addition Quick ******************************************            
            ADDQ.B #4,D2
            ADDQ.B #5,(A5)
            ADDQ.B #6,-(A2)
            ADDQ.B #2,(A6)+        
            ADDQ.W #4,D2
            ADDQ.W #5,(A5)
            ADDQ.W #6,-(A2)
            ADDQ.W #2,(A6)+           
            ADDQ.W #4,D2
            ADDQ.W #5,(A5)
            ADDQ.W #6,-(A2)
            ADDQ.W #2,(A6)+     

************************** OR ******************************************             
            OR.B D2,D5
            OR.W D2,D5
            OR.L D2,D5          
            OR.B D2,(A2)+
            OR.W D2,(A1)
            OR.L D2,$7666

************************** AND ******************************************                  
            AND.B D2,D5
            AND.W D3,D6
            AND.W (A2),D1
            AND.B -(A1),D6
            AND.L (A5)+,D1
            AND.L D6,D1
            AND.B D2,(A2)+
            AND.W D2,(A1)
            AND.L D2,$7666
            
************************** NOT ******************************************   
            NOT.B D2
            NOT.B (A1)
            NOT.W -(A5)
            NOT.L (A4)+
            NOT.W $3434
            NOT.L $AAAAAAAA

    

    END    START        ; last line of source


*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
