*-----------------------------------------------------------
* Title      : CSS422 Project: 68K Disassembler
* Written by : Narapady Chhuoy, Divayashna Chandra, Hafsa Ali
* Date       : June 10, 2021
* Description: A program disassembles opcode word from starting address to ending address
*-----------------------------------------------------------
            
           
*================ Main Program ===================
            ORG    $1000 
START:                  ; first instruction of program
            JSR welcome_page    ; greeting page (I/O routine)
            JSR disassemble     ; start disassembling (Opcode & EA routine)
 
*================ IO Routine =====================               
welcome_page
                 MOVE.B #14,D0                   ;display welcome page
                 LEA greeting_msg,A1             ; load greeting message to A1
                 TRAP #15
run_main        
                MOVE.B #5,D0        ; ask for input if user wants to continue disassemble
                TRAP #15
                
                CMP.B #$59,D1         ; if Y in D6, continue disassemble
                BEQ validate_start
                CMP.B #$79,D1          ; if y in D6, continue disassemble
                BEQ validate_start
                CMP.B #$4E,D1          ; if N in D6, stop disassemble
                BEQ stop
                CMP.B #$6E,D1          ; if n in D6, stop disassemble
                BEQ stop
                
stop            MOVE.B #9,D0
                TRAP #15
                                    
*================ Address Validation =======================
validate_start   
                 MOVE.B #14,D0
                 MOVE.B #1,D2                    ; validate starting address. If 1 in D2, it's starting address
                 LEA start_msg,A1                ; load starting address message to A1
                 TRAP #15                   
                 MOVE.B #2,D0                    ; ask user for starting address, store input string in A1
                 LEA start_addr,A1               ; save input string in variable start_addr
                 TRAP #15
                 CMP.B #8,D1                     ; D1 has length of input string
                 BNE invalid_addr                ; input string should have length 8. If not, invalid
                 JSR convert_start
                 JSR check_even_start

validate_end     
                 MOVE.B #2,D2                     ; validate ending address. If 2 in D2, it's ending address
                 MOVE.B #14,D0
                 LEA end_msg,A1
                 TRAP #15                
                 MOVE.B #2,D0                     ; ask user for ending address, store input string in A1
                 LEA end_addr,A1                  ; save input string in variable end_addr
                 TRAP #15
                 CMP.B #8,D1
                 BNE invalid_addr
                 JSR convert_end
                 JSR check_even_end
                 CMPA.L A4,A5
                 BLT disassemble
                 RTS

*================ IO Subroutine for checking input address if it's even ===================== 
*   Memory Address must be even
*   If input memory address is odd, program will ask user to re-enter the address              
check_even_start
                MOVE.L start_addr,D1
                AND.L #$00000001,D1
                CMP.B #$00,D1
                BEQ exit_even
                BRA invalid_addr
                RTS

check_even_end
                MOVE.L end_addr,D1
                AND.L #$00000001,D1
                CMP.B #$00,D1
                BEQ exit_even
                BRA invalid_addr
exit_even       RTS

*================ Handling invalid address ===================== 
invalid_addr    MOVE.B #14,D0                      ; display invalid message if address is not valid
                LEA invalid_addr_msg,A1
                TRAP #15
                CMP.B #1,D2                         ; if 1 in D2, it's starting address
                BEQ validate_start
                CMP.B #2,D2                          ; if 2 in D2, it's ending address
                BEQ validate_end

*================ Variables for IO Routines ===================                  
greeting_msg    DC.B '=================================================================================',CR,LF
                DC.B '========================= WELCOME TO 68K DISASSEMBLER ===========================',CR,LF
                DC.B '=================================================================================',CR,LF
                DC.B '                                                       ',CR,LF
                DC.B 'USAGE:',CR,LF 
                DC.B '      * Address must be in hexadecimal 8-degit format and must be even address.',CR,LF
                DC.B '      * Starting address must be smaller than ending address.',CR,LF
                DC.B '      * The program outputs 15 instructions per page',CR,LF 
                DC.B '      * Press "Enter" to see next pages of output.',CR,LF
                DC.B '                                                         ',CR,LF
                DC.B 'Would You Like Use 68K Disassembler? (Y/N)',CR,LF,0
start_msg       DC.B CR,LF,'Please Enter Starting Address in Hexadecimal',CR,LF,0
end_msg         DC.B 'Please Enter Ending Address in Hexadecimal',CR,LF,0
invalid_addr_msg  DC.B 'Address is invalid!!! Please re-enter the address',CR,LF,0
template        DC.B 'ADDRESS  OP-CODE  OPERAND(S)',CR,LF,0
start_addr      DS.L 2
end_addr        DS.L 2
                
*================ convert ascii string to hex ===================  
                
convert_start   
                CLR.L D6                      ; D6 holds the result      
                MOVE.B #0,D1                    ; counter
                CLR.L D6
                MOVE.B #0,D1
                LEA start_addr,A0               ; A0 is pointer to address to be converted
                LEA start_addr,A1               ; A1 is pointer when writing it back to memory
                BRA ascii_loop
                
convert_end     CLR.L D6                      ; D6 holds the result      
                MOVE.B #0,D1                    ; counter
                LEA end_addr,A0
                LEA end_addr,A1
                BRA ascii_loop 
    		    
ascii_loop	    CMP.B #8,D1		                ; check counter, if 8, done converting
			    BEQ	exit_ascii	
			    ADD.B #01,D1			        ;update counter
			    ROL.L #4,D6			       ;mpace for D6 to hold result for each ascii conversion
			    MOVE.B (A0)+,D3		            ;D3 holds next byte to convert
			    CMP.B #$40,D3                   ; $40 is invalid
			    BEQ invalid_addr        
			    CMP.B #$30,D3                   ; if smaller than $30, invalid
			    BLT invalid_addr
                CMP.B #$46,D3                   ; if greater than $46, invalid
                BGT invalid_addr
			    
			    CMP.B #$39,D3			        ;If equal or less than 39
			    BLE con_num		                ;Convert a numb
			    BGT con_letter    
			    
		
con_num  	    SUB.B		#$30,D3			    ;substract $30 if a number
			    OR.B		D3,D6			    ;masking
			    BRA			ascii_loop		    ;back to loop
con_letter	    SUBI.B		#$37,D3			    ;substract $37 if a number
			    OR.B		D3,D6			    ;masking
			    BRA			ascii_loop		    ;back to loop

exit_ascii      MOVE.L D6,(A1)                  ;write back to memory
                RTS							    ;return
                
*================ convert hex to ascii string ===================
converted_ascii     DS.W 5
hex_to_ascii
    		MOVEM.L		D0-D3,-(SP)	;Save D2 and A0
    		LEA converted_ascii,A1
    		MOVE.L      A4,D3
			CMPI.W		#04,D0			;See if D4 is a long or word
			BEQ			shift			;If a word need to shift
			
			
hex_loop	CMPI.W		#00,D0			;Is count done
			BEQ			exit_hex		;If done exit subroutine
			ROL.L		#4,D3			;Update D3 to next hex
			MOVE.L		D3,D2			;So D3 isn't corrupted
			ANDI.L		#$0000000F,D2	;Isolate the last 4 binary digits
			SUBI.B		#1,D0			;Update counter
			CMPI.B		#$09,D2			;Compare hex 9 and D2
			BLE			conv_num		;If 9 or less it's a number
			BRA			conv_letter		;Then is a letter
conv_num    ADDI.W		#$30,D2			;Convert a number
			BRA			save			;Now put in  memory
conv_letter	ADDI.W		#$37,D2			;Convert to Hex letter
			BRA			save			;Now put in memory
save		MOVE.B		D2,(A1)+		;Save in memory and ++
			BRA			hex_loop		;Back to top of loop
shift		ROL.L		#08,D3			;Move over 2 digits
			ROL.L		#08,D3			;Move over 2 digits
			BRA			hex_loop		;Start the loop
exit_hex    MOVE.B #$00,(A1)
            MOVEM.L     (SP)+,D0-D3 ;Pop off stack
			RTS

                
*================ Routine for adding ascii string to buffer for printing ===================
string_ptr      DS.L   1
buffer          DS.B   80
clr_ptr         DS.L   1

clr_buffer      ;clear the memory before add string to it
                MOVEM.L D0/D1/A2,-(SP)          ;save register in the stack
                CLR.L D0                        ; D0 is counter
                CLR.L D1
                MOVE.L #buffer,clr_ptr          ; load buffer to pointer to clear
                MOVEA.L clr_ptr,A2              ; load pointer to A2
                MOVE.B #80,D1                   ; max length of buffer is 80
                
clr_loop        CMP.L D1,D0                     ; stop after 80 times
                BEQ exit_clr                        
                    
                ADD.B #1,D0                     ; increment counter
                CLR.B (A2)+                     ; clear the buffer
                BRA clr_loop                    ; go back to loop
                 
exit_clr        MOVEM.L (SP)+,D0/D1/A2          ; return
                RTS     
                  

add_str_buffer  ; add ascii string to buffer
                MOVEM.L D0/D1/A2, -(SP)  ;save register
                MOVE.L string_ptr,A2        ; A2 get address of string to add to buffer
                
buffer_loop     CMP.B #0,(A2)               ; if 0 is found, done
                BEQ exit_buffer
                MOVE.B (A2)+,(A6)+          ; add content to buffer pointer
                BRA buffer_loop             ; go back to loop
                    
exit_buffer     
                MOVEM.L (SP)+,D0/D1/A2
                RTS

print_buffer    
                MOVE.L #new_line,string_ptr
                JSR add_str_buffer
                MOVE.L #14,D0               ; load null terminate string to A1 for printing to console
                LEA buffer,A1   
                TRAP #15
                BRA disass_loop
                RTS                         ; return

*================ Main loop for disassembling ===================
* A4 is pointer to current opcode instruction and also hold current address for disassembling
* A5 holds the end adress to disassemble
* A6 is pointer to buffer string to print

* Instruction is disassemble once at a time and output
* There are 15 instructions printing per page, the program will wait for user to press enter
* to output another pages
* When disassembling is done, it will ask users to either quit or continue using
      
disassemble
                LEA start_addr,A4          ; load starting address to A4
                MOVEA.L (A4),A4            ; load content (starting address)
                LEA end_addr,A5            ; load ending adress to A5
                MOVEA.L (A5),A5            ; load ending address to D5
             
                MOVE.B #14,D0
                LEA template,A1             ; column template
                TRAP #15
                MOVE.L #$F,D7
                
disass_loop     CMPA.L A4,A5                ; if starting address equal ending address, done
                BEQ exit_io
                BLT invalid_addr            ; if ending address is less than starting address, it's not valid            
                CMP.B #0,D7                 ; D7 is counter for output printing (15 instructions per page)
                BEQ page_full               ; if page is full, handle it
                SUB.B #1,D7                 ; decrement counter
                LEA buffer,A6               ; load buffer to A6
                JSR clr_buffer              ; clear it before adding string to it
                MOVE.L #8,D0                ; set D0 to 8 before converting to ascii string (address is 8 digits)
                JSR hex_to_ascii            ; convert current address to ascii string
                
                
                MOVE.L #converted_ascii,string_ptr          ; load converted ascii string to string pointer
                JSR add_str_buffer
                
                MOVE.L #tap,string_ptr      ; add tap to buffer
                JSR add_str_buffer
             
                MOVE.W (A4)+,opcode        ; get opcode to disassemble
                JSR opcode_routine         ; go to opcode routine
                
exit_io        
                BRA START                  ; when done disassembling, go back to the start of program
                
*================ IO subroutines, called when page for output page is full ===================              
page_full
                LEA page_buffer,A1
                MOVE.B #2,D0
                TRAP #15
                MOVE.L #$F,D7
                NOP
                BRA disass_loop
                
page_buffer     DS.W    20

*================ Subroutine to isolate bit from opcode word instruction ===================
* Isolate the 16 bits of opcode word and assign to corresponding variables
* From left to right:
*     -first 4 bits is assigned to bit15to12
*     -next 3 bits is assigned to bit11to9
*     -next 3 bits is assigned to bit8to6
*     -next 3 bits is assigned to bit5to3
*     -next 3 bits is assigned to bit2to0

bit15to12       DS.B 1
bit11to9        DS.B 1
bit8to6         DS.B 1
bit5to3         DS.B 1
bit2to0         DS.B 1

isolate_bit      MOVEM.L D1/D2,-(SP)
                 MOVE.W opcode,D2
                 MOVE.B #12,D1
                 LSR.L  D1,D2
                 MOVE.B D2,bit15to12
                 
                 MOVE.W opcode,D2
                 MOVE.B #4,D1
                 LSL.W  D1,D2
                 MOVE.B #13,D1
                 LSR.L D1,D2
                 MOVE.B D2,bit11to9
                 
                 MOVE.W opcode,D2
                 MOVE.B #6,D1
                 LSR.L  D1,D2
                 ANDI.L #$00000007,D2
                 MOVE.B D2,bit8to6
                 
                 MOVE.W opcode,D2
                 MOVE.B #3,D1
                 LSR.L  D1,D2
                 ANDI.L #$00000007,D2
                 MOVE.B D2,bit5to3
                 
                 MOVE.W opcode,D2
                 ANDI.L #$00000007,D2
                 MOVE.B D2,bit2to0
                 
                 MOVEM.L (SP)+,D1/D2
                 RTS
                 
*================ Opcode routine ===================
*  Operation can be identified from the first value of opcode word i.e bit 12th to bit 15th
*  Bellow are supported opcodes:
*  Start with:                     Group
*       $0                         Unsupported
*       $1                         MOVE byte
*       $2                         MOVE long and MOVE ADDESS long
*       $3                         MOVE word and MOVE ADDESS word
*       $4                         MOVEM, JSR, RTS, LEA, NOP, and NOT
*       $5                         ADD Quick
*       $6                         BRA, Bcc (BLE, BEQ,BGT)
*       $7                         MOVE Quick
*       $8                         OR
*       $9                         SUB
*       $A                         Unsupported
*       $B                         Unsupported
*       $C                         AND
*       $D                         ADD and ADDA
*       $E                         LSR, LSL, ASR, ASL, ROR, and ROL
*       $F                         Unsupported

opcode      DS.W   1     ; hold the current opcode 
opcode_routine  
                MOVEM.L D1/D2,-(SP)         ;save registers to stack
                
                BSR isolate_bit
                MOVE.W opcode,D1            ;load opcode word to D1
                MOVE.B #12,D2
                LSR.L D2,D1                 ; shift 12 times to get left-most hex to determine instruction      
                
                CMP.B #$0,D1                
                BEQ invalid_opcode

                CMP.B #$1,D1               
                BEQ MOVE_B
                
                CMP.B #$2,D1                  
                BEQ MOVE_L_MOVEA_L
                
                CMP.B #$3,D1
                BEQ MOVE_W_MOVEA_W
                
                CMP.B #$4,D1
                BEQ MOVEM_JSR_RTS_LEA_NOP_NOT
                
                CMP.B #$5,D1
                BEQ ADDQ_
                
                CMP.B #$6,D1
                BEQ BGT_BLE_BEQ_BRA
                
                CMP.B #$7,D1
                BEQ MOVEQ_
                
                CMP.B #$8,D1
                BEQ OR_
                
                CMP.B #$9,D1
                BEQ SUB_
                
                CMP.B #$A,D1
                BEQ invalid_opcode
                
                CMP.B #$B,D1
                BEQ invalid_opcode
                
                CMP.B #$C,D1
                BEQ AND_
                
                CMP.B #$D,D1
                BEQ ADD_ADDA
                
                CMP.B #$E,D1
                BEQ LSR_LSL_ASR_ASL_ROR_ROL
                
                CMP.B #$F,D1
                BEQ invalid_opcode
                
                BRA invalid_opcode
          
                RTS

MOVE_B          
                MOVE.L #_MOVE_B,string_ptr
                JSR add_str_buffer
                JSR ea_routine
                                   
MOVE_L_MOVEA_L
                CMP.B #%001,bit8to6
                BEQ MOVEA_L
                MOVE.L #_MOVE_L,string_ptr
                JSR add_str_buffer
                JSR ea_routine               
MOVE_W_MOVEA_W
                CMP.B #%001,bit8to6
                BEQ MOVEA_W
                MOVE.L #_MOVE_W,string_ptr
                JSR add_str_buffer
                JSR ea_routine
MOVEA_W
                MOVE.L #_MOVEA_W,string_ptr
                JSR add_str_buffer
                JSR ea_routine
                
MOVEA_L         
                MOVE.L #_MOVEA_L,string_ptr
                JSR add_str_buffer
                JSR ea_routine   
MOVEQ_
                MOVE.L #_MOVEQ,string_ptr
                JSR add_str_buffer
                JSR moveq_ea_routine
                
MOVEM_JSR_RTS_LEA_NOP_NOT
                MOVE.W opcode,D1
                AND.W #$FF00,D1
                CMP.W #$4600,D1
                BEQ NOT_
                CMP.W #$4E71,opcode
                BEQ NOP_
                CMP.W #$4E75,opcode
                BEQ RTS_
                
                MOVE.W opcode,D1
                AND.W #$FE80,D1
                CMP.W #$4E80,D1
                BEQ JSR_
                
                MOVE.W opcode,D1
                AND.W #$F1C0,D1
                CMP.W #$41C0,D1
                BEQ LEA_
                
                MOVE.W opcode,D0
                AND.W #$FCC0,D0    ; masking to see if it's MOVEM.L (memory to register)
                CMP.W #$4CC0,D0
                BEQ MOVEM_L_MEM_TO_REG
                
                MOVE.W opcode,D0
                AND.W #$F8C0,D0    ; masking to see if it's MOVEM.L (register ot memory)
                CMP.W #$48C0,D0
                BEQ MOVEM_L_REG_TO_MEM
                
                MOVE.W opcode,D0
                AND.W #$FC80,D0    ; masking to see if it's MOVEM.W (memory to register)
                CMP.W #$4C80,D0
                BEQ MOVEM_W_MEM_TO_REG
                
                MOVE.W opcode,D0
                AND.W #$F880,D0    ; masking to see if it's MOVEM.W (register to memory)
                CMP.W #$4880,D0
                BEQ MOVEM_W_REG_TO_MEM
                
NOT_
               CMP.B #%000,bit8to6
               BEQ NOT_B
               CMP.B #%001,bit8to6
               BEQ NOT_W
               BRA NOT_L
NOT_B
               MOVE.L #_NOT_B,string_ptr
               JSR add_str_buffer
               JSR not_ea_routine
NOT_W
               MOVE.L #_NOT_W,string_ptr
               JSR add_str_buffer
               JSR not_ea_routine
NOT_L
               MOVE.L #_NOT_L,string_ptr
               JSR add_str_buffer
               JSR not_ea_routine 
               
MOVEM_L_MEM_TO_REG
                MOVE.L #_MOVEM_L,string_ptr
                JSR add_str_buffer
movem_con       MOVE.L #_stack_in,string_ptr
                JSR add_str_buffer
                MOVE.L #comma,string_ptr
                JSR add_str_buffer
                JSR movem_mem_to_reg
                CLR.B -(A6)
                JSR print_buffer
                
MOVEM_L_REG_TO_MEM
                MOVE.L #_MOVEM_L,string_ptr
                JSR add_str_buffer
movem_cont      JSR movem_reg_to_mem
                CLR.B -(A6)
                MOVE.L #comma,string_ptr
                JSR add_str_buffer
                MOVE.L #_stack_de,string_ptr
                JSR add_str_buffer
                JSR print_buffer
                
MOVEM_W_MEM_TO_REG
                MOVE.L #_MOVEM_W,string_ptr
                JSR add_str_buffer
                BRA movem_con
                
MOVEM_W_REG_TO_MEM
                MOVE.L #_MOVEM_W,string_ptr
                JSR add_str_buffer
                BRA movem_cont
NOP_             
                MOVE.L #_NOP,string_ptr
                JSR add_str_buffer
                JSR print_buffer

RTS_             
                MOVE.L #_RTS,string_ptr
                JSR add_str_buffer
                JSR print_buffer             

JSR_            
                MOVE.L #_JSR,string_ptr
                JSR add_str_buffer
                JSR check_src
                JSR print_buffer
               
LEA_            
                MOVE.L #_LEA,string_ptr
                JSR add_str_buffer
                JSR ea_routine            
SUB_
                BRA check_opmode
AND_            
                BRA check_opmode

*================ Helper functions. Use exclusively for ADD,SUB,OR,and AND  ===================   
check_opmode    
                CMP.B #%111,bit8to6    ; if bit 8 to 6 is 111, it's MUL or Div, not supported
                BEQ invalid_opcode
                CMP.B #%011,bit8to6    ; if bit 8 to 6 is 011, it's MUL or Div, not supported
                BEQ invalid_opcode
                CMP.B #$2,bit8to6  
                BGT ea_as_des        ; if opmode is greater than $2, <ea> - Dn -> <ea>
                BRA ea_as_src        ; if opmode is less than or equal to $2, Dn - <ea> -> Dn
ea_as_des
                CMP.B #%100,bit8to6
                BEQ byte_op
                CMP.B #%101,bit8to6
                BEQ word_op
                CMP.B #%110,bit8to6
                BEQ long_op
                
ea_as_src        
                CMP.B #%000,bit8to6
                BEQ byte_op
                CMP.B #%001,bit8to6
                BEQ word_op
                CMP.B #%010,bit8to6
                BEQ long_op
byte_op     
                CMP.B #$9,bit15to12
                BEQ sub_b
                CMP.B #$8,bit15to12
                BEQ or_b
                BRA add_b
sub_b           MOVE.L #_SUB_B,string_ptr
                JSR add_str_buffer
                JSR sub_add_or_ea_routine
                
add_b           MOVE.L #_ADD_B,string_ptr
                JSR add_str_buffer
                JSR sub_add_or_ea_routine

or_b            MOVE.L #_OR_B,string_ptr
                JSR add_str_buffer
                JSR sub_add_or_ea_routine
                
and_b            MOVE.L #_AND_B,string_ptr
                JSR add_str_buffer
                JSR sub_add_or_ea_routine
word_op     
                CMP.B #$9,bit15to12
                BEQ sub_w
                CMP.B #$8,bit15to12
                BEQ or_w
                BRA add_w
sub_w           MOVE.L #_SUB_W,string_ptr
                JSR add_str_buffer
                JSR sub_add_or_ea_routine
                
add_w           MOVE.L #_ADD_W,string_ptr
                JSR add_str_buffer
                JSR sub_add_or_ea_routine
                
or_w            MOVE.L #_OR_W,string_ptr
                JSR add_str_buffer
                JSR sub_add_or_ea_routine

and_w            MOVE.L #_AND_W,string_ptr
                JSR add_str_buffer
                JSR sub_add_or_ea_routine
long_op                       
                CMP.B #$9,bit15to12
                BEQ sub_l
                CMP.B #$8,bit15to12
                BEQ or_l
                BRA add_l
sub_l           MOVE.L #_SUB_L,string_ptr
                JSR add_str_buffer
                JSR sub_add_or_ea_routine
                
add_l           MOVE.L #_ADD_L,string_ptr
                JSR add_str_buffer
                JSR sub_add_or_ea_routine
                
or_l            MOVE.L #_OR_L,string_ptr
                JSR add_str_buffer
                JSR sub_add_or_ea_routine

and_l           MOVE.L #_AND_L,string_ptr
                JSR add_str_buffer
                JSR sub_add_or_ea_routine
                
BGT_BLE_BEQ_BRA
               MOVE.W opcode,D1
               AND.L #$FF00,D1
               CMP.L #$6000,D1
               BEQ BRA_
               CMP.L #$6700,D1
               BEQ BEQ_
               CMP.L #$6F00,D1
               BEQ BLE_
               CMP.L #$6E00,D1
               BEQ BGT_
               
BRA_
               MOVE.L #_BRA,string_ptr
               JSR add_str_buffer
               BRA displacement
BEQ_
               MOVE.L #_BEQ,string_ptr
               JSR add_str_buffer
               BRA displacement
BLE_
               MOVE.L #_BLE,string_ptr
               JSR add_str_buffer
               BRA displacement
BGT_
               MOVE.L #_BGT,string_ptr
               JSR add_str_buffer
               BRA displacement
  
displacement   MOVE.B #4,D0
               MOVE.W (A4)+,D3
               MOVEM.L A4,-(SP)
               ADD.L A4,D3
               SUB.B #$2,D3
               MOVE.L D3,A4
               JSR hex_to_ascii
               MOVEM.L (SP)+,A4
               MOVE.L #converted_ascii,string_ptr
               JSR add_str_buffer
               JSR print_buffer
OR_
               BRA check_opmode
ADD_ADDA
               CMP.B #%011,bit8to6
               BEQ ADDA_W
               CMP.B #%111,bit8to6
               BEQ ADDA_L
               BRA check_opmode 
               
ADDA_W
               MOVE.L #_ADDA_W,string_ptr
               JSR add_str_buffer
               JSR ea_is_src

ADDA_L
               MOVE.L #_ADDA_L,string_ptr
               JSR add_str_buffer
               JSR ea_is_src
ADDQ_
               CMP.B #%000,bit8to6
               BEQ ADDQ_B
               CMP.B #%001,bit8to6
               BEQ ADDQ_W
               BRA ADDQ_L
ADDQ_B
               MOVE.L #_ADDQ_B,string_ptr
               JSR add_str_buffer
               JSR addq_ea_routine

ADDQ_W
               MOVE.L #_ADDQ_W,string_ptr
               JSR add_str_buffer
               JSR addq_ea_routine  

ADDQ_L
               MOVE.L #_ADDQ_L,string_ptr
               JSR add_str_buffer
               JSR addq_ea_routine
                   
LSR_LSL_ASR_ASL_ROR_ROL
               MOVE.W opcode,D1
               AND.W #$F7C0,D1   ; make to see if it's rol (memory shift)
               CMP.W #$E7C0,D1
               BEQ ROL_MEM_SHIFT
               
               MOVE.W opcode,D1
               AND.W #$F6C0,D1   ; make to see if it's ror (memory shift)
               CMP.W #$E6C0,D1
               BEQ ROR_MEM_SHIFT
               
               MOVE.W opcode,D1
               AND.W #$F3C0,D1   ; make to see if it's lsl (memory shift)
               CMP.W #$E3C0,D1
               BEQ LSL_MEM_SHIFT
               
               MOVE.W opcode,D1
               AND.W #$F2C0,D1   ; make to see if it's lsr (memory shift)
               CMP.W #$E2C0,D1
               BEQ LSR_MEM_SHIFT
               
               MOVE.W opcode,D1
               AND.W #$F1C0,D1   ; make to see if it's asl (memory shift)
               CMP.W #$E1C0,D1
               BEQ ASL_MEM_SHIFT
               
               MOVE.W opcode,D1
               AND.W #$F0C0,D1   ; make to see if it's asr (memory shift)
               CMP.W #$E0C0,D1
               BEQ ASR_MEM_SHIFT            
               
               MOVE.W opcode,D1
               AND.W #$F018,D1   ; mask bits to see if it's lsr and lsl
               CMP.W #$E008,D1
               BEQ LSR_LSL_
               
               MOVE.W opcode,D1
               AND.W #$F018,D1
               CMP.W #$E018,D1
               BEQ ROR_ROL_        ; ror and rol if above two are not the case
               
               MOVE.W opcode,D1
               AND.W #$F038,D1
               CMP.W #$E038,D1
               BEQ ROR_ROL_
               
               MOVE.W opcode,D1   
               AND.W #$F000,D1     ; mask bits to see if it's asr and arl
               CMP.W #$E000,D1
               BEQ ASR_ASL_
               
LSL_MEM_SHIFT
               MOVE.L #_LSL,string_ptr
               JSR add_str_buffer
               BRA mem_shift_con

LSR_MEM_SHIFT
               MOVE.L #_LSR,string_ptr
               JSR add_str_buffer
               BRA mem_shift_con
ASL_MEM_SHIFT
               MOVE.L #_ASL,string_ptr
               JSR add_str_buffer
               BRA mem_shift_con

ASR_MEM_SHIFT
               MOVE.L #_ASR,string_ptr
               JSR add_str_buffer
               BRA mem_shift_con
ROL_MEM_SHIFT
               MOVE.L #_ROL,string_ptr
               JSR add_str_buffer
               BRA mem_shift_con 
ROR_MEM_SHIFT
               MOVE.L #_ROR,string_ptr
               JSR add_str_buffer
               BRA mem_shift_con   

ASR_ASL_
               MOVE.B bit8to6,D2   ; load bit 8 to 6 to D1 shifting
               LSR.B #2,D2         ; shift right by two bits to get bit 8 
               CMP.B #1,D2         ; if bit 8 is 1 then it's ASL
               BEQ ASL_
               BRA ASR_
ASL_
               MOVE.L #_ASL,string_ptr
               JSR add_str_buffer
               BRA shifting_con
ASR_
               MOVE.L #_ASR,string_ptr
               JSR add_str_buffer
               BRA shifting_con             
LSR_LSL_        
               MOVE.B bit8to6,D2   ; load bit 8 to 6 to D1 shifting
               LSR.B #2,D2         ; shift right by two bits to get bit 8 
               CMP.B #1,D2         ; if bit 8 is 1 then it's LSL
               BEQ LSL_  
               BRA LSR_         
LSL_
               MOVE.L #_LSL,string_ptr
               JSR add_str_buffer
               BRA shifting_con
               
LSR_
               MOVE.L #_LSR,string_ptr
               JSR add_str_buffer
               BRA shifting_con

ROR_ROL_       
               MOVE.B bit8to6,D2   ; load bit 8 to 6 to D1 shifting
               LSR.B #2,D2         ; shift right by two bits to get bit 8 
               CMP.B #1,D2         ; if bit 8 is 1 then it's ROL
               BEQ ROL_  
               BRA ROR_ 
ROL_
               MOVE.L #_ROL,string_ptr
               JSR add_str_buffer
               BRA shifting_con
               
ROR_
               MOVE.L #_ROR,string_ptr
               JSR add_str_buffer
               BRA shifting_con
               
*================ Helper functions for Shifting and Rotation ===================          
shifting_con   MOVE.B bit8to6,D2
               AND.B #$03,D2            ; mask to get bit 6 and 7 to determine size
               CMP.B #%00,D2            ; if  00, byte
               BEQ ls_byte
               CMP.B #%01,D2            ; if 01, word 
               BEQ ls_word
               BRA ls_long              ; if 10, long
    
mem_shift_con  MOVE.L #tap,string_ptr         ; for memory shifting
               JSR add_str_buffer
               JSR mem_shifting_ea_routine
ls_byte
               MOVE.L #byte,string_ptr
               JSR add_str_buffer
               JSR shifting_ea_routine

ls_word
               MOVE.L #word,string_ptr
               JSR add_str_buffer
               JSR shifting_ea_routine
ls_long
               MOVE.L #long,string_ptr
               JSR add_str_buffer
               JSR shifting_ea_routine     

*================ Handling unsupported opcode instruction ===================
* Unsupported opcode at specific memorty location will be output in form of: 10000 DATA $XYZY                                    
invalid_opcode
              MOVE.L #data,string_ptr
              JSR add_str_buffer
              MOVE.L #dollar_sign,string_ptr
              JSR add_str_buffer
              MOVE.B #4,D0
              MOVEM.L A4,-(SP)     
              MOVEA.W opcode,A4
              JSR hex_to_ascii
              MOVEM.L (SP)+,A4
              MOVE.L #converted_ascii,string_ptr
              JSR add_str_buffer
              JSR print_buffer
              
*================ Variables for IO routines ===================  
_MOVE_B       DC.B 'MOVE.B   ',0
_MOVE_W       DC.B 'MOVE.W   ',0
_MOVE_L       DC.B 'MOVE.L   ',0
_MOVEA_W      DC.B 'MOVEA.W   ',0
_MOVEA_L      DC.B 'MOVEA.L   ',0
_MOVEM_L      DC.B 'MOVEM.L   ',0
_MOVEM_W      DC.B 'MOVEM.W  ',0
_MOVEQ        DC.B 'MOVEQ   ',0
_NOP          DC.B 'NOP',0
_RTS          DC.B 'RTS',0
_JSR          DC.B 'JSR   ',0
_LEA          DC.B 'LEA   ',0
_SUB_B        DC.B 'SUB.B   ',0
_SUB_W        DC.B 'SUB.W   ',0
_SUB_L        DC.B 'SUB.L   ',0
_ADD_B        DC.B 'ADD.B   ',0
_ADD_W        DC.B 'ADD.W   ',0
_ADD_L        DC.B 'ADD.L   ',0
_ADDA_W       DC.B 'ADDA.W   ',0
_ADDA_L       DC.B 'ADDA.L   ',0
_ADDQ_B       DC.B 'ADDQ.B   ',0
_ADDQ_W       DC.B 'ADDQ.W   ',0
_ADDQ_L       DC.B 'ADDQ.L   ',0
_NOT_B        DC.B 'NOT.B   ',0
_NOT_W        DC.B 'NOT.W   ',0
_NOT_L        DC.B 'NOT.L   ',0
_OR_B         DC.B 'OR.B   ',0
_OR_W         DC.B 'OR.W   ',0
_OR_L         DC.B 'OR.L   ',0
_AND_B        DC.B 'AND.B   ',0
_AND_W        DC.B 'AND.W   ',0
_AND_L        DC.B 'AND.L   ',0
_LSL          DC.B 'LSL',0
_LSR          DC.B 'LSR',0
_ASL          DC.B 'ASL',0
_ASR          DC.B 'ASR',0
_ROL          DC.B 'ROL',0
_ROR          DC.B 'ROR',0
_BRA          DC.B 'BRA   ',0
_BEQ          DC.B 'BEQ   ',0
_BLE          DC.B 'BLE   ',0
_BLT          DC.B 'BLT   ',0
_BGT          DC.B 'BGT   ',0
_stack_in       DC.B '(SP)+',0
_stack_de       DC.B '-(SP)',0
tap             DC.B '   ',0
comma           DC.B ',',0
dollar_sign     DC.B '$',0
pound_sign      DC.B '#',0
slash           DC.B '/',0
left_par        DC.B '(',0
right_par       DC.B ')',0
plus_sign       DC.B '+',0
minus_sign      DC.B '-',0
new_line        DC.B $0A,$0D,0
CR              EQU    $0A
LF              EQU    $0D
byte            DC.B '.B   ',0
word            DC.B '.W   ',0
long            DC.B '.L   ',0
data            DC.B 'DATA   ',0

*================ EA routine ===================
* Decode Effective Address From the Opcode Instruction
* Supported Effective Address:
*   - Data register
*   - Address register direct
*   - Address register indirect
*   - Address register with post increment
*   - Address register with pre decrement
*   - Long absolute addressing
*   - Word absolute addressing
*   - Immidate data addressing

ea_result       DS.L 1

ea_routine                          
                JSR check_src
skip            MOVE.L #comma,string_ptr
                JSR add_str_buffer
                JSR check_des
                RTS
                
moveq_ea_routine
                MOVE.L #pound_sign,string_ptr
                JSR add_str_buffer
                MOVE.W opcode,D1
                AND.W #$00FF,D1
                ADD.B #$30,D1
                MOVE.B D1,(A6)+
                MOVE.L #comma,string_ptr
                JSR add_str_buffer
                LEA data_regs,A1
                LEA ea_result,A2
                JSR decode_des

movem_mem_to_reg
                
                MOVE.B #16,D4      ; counter
                MOVE.B #0,D3
                MOVE.W (A4)+,D6
                
movem_loop      CMP.B #0,D4
                BEQ exit_movem
                SUB.B #1,D4
                CLR.L D2
                ROR.L #1,D6
                MOVE.L D6,D2
                AND.L #$80000000,D2
                CMP.L #$80000000,D2
                BEQ get_registers
                ADD.B #1,D3
                BRA movem_loop
get_registers
                CMP.B #7,D3
                BLE get_data_reg
                BRA get_address_reg
                
get_data_reg    
                LEA data_regs,A1
                LEA ea_result,A2
                MOVE.B D3,D5
                MULU.W #3,D5
                ADD.B #1,D3
                LEA (A1,D5.W),A1
                JSR ea_loop
                MOVE.L #slash,string_ptr
                JSR add_str_buffer
                CMP.B #%110,bit11to9
                BEQ movem_loop
                BRA movem_loop_

get_address_reg
                LEA address_regs,A1
                LEA ea_result,A2
                MOVE.B D3,D5
                SUB.B #8,D5
                MULU.W #3,D5
                ADD.B #1,D3
                LEA (A1,D5.W),A1
                JSR ea_loop
                MOVE.L #slash,string_ptr
                JSR add_str_buffer
                CMP.B #%110,bit11to9
                BEQ movem_loop
                BRA movem_loop_

movem_reg_to_mem
                               
                MOVE.B #16,D4      ; counter
                MOVE.B #0,D3
                MOVE.W (A4)+,D6
                MOVE.B #16,D7
                LSL.L D7,D6
                
movem_loop_     CMP.B #0,D4
                BEQ exit_movem
                SUB.B #1,D4
                CLR.L D2
                ROL.L #1,D6
                MOVE.L D6,D2
                AND.L #$00000001,D2
                CMP.L #$00000001,D2
                BEQ get_registers
                ADD.B #1,D3
                BRA movem_loop_
                
exit_movem      RTS       
      
addq_ea_routine
                MOVE.L #pound_sign,string_ptr
                JSR add_str_buffer
                ADD.B #$30,bit11to9
                MOVE.B bit11to9,(A6)+
                MOVE.L #comma,string_ptr
                JSR add_str_buffer
                JSR check_src
                JSR print_buffer
                
sub_add_or_ea_routine          
                CMP.B #2,bit8to6
                BGT ea_is_des
                BRA ea_is_src
                
shifting_ea_routine
                CMP.B #%001,bit5to3    ; check if i/r = 0 or 1
                BEQ count_as_immi       ; if i/r = 0, # of count is specified as immidiate value
                CMP.B #%000,bit5to3     ; for asl/asr.
                BEQ count_as_immi
                CMP.B #%101,bit5to3
                BEQ count_in_reg
                CMP.B #%100,bit5to3
                BEQ count_in_reg      ; if i/r = 1, # of count is in register
                CMP.B #%111,bit5to3
                BEQ count_in_reg
                CMP.B #%011,bit5to3
                BEQ count_as_immi      ; if i/r = 1, # of count is in register
count_in_reg
                JSR ea_is_des
                CLR.B -(A6)
get_reg         MOVE.L #comma,string_ptr
                JSR add_str_buffer
                LEA data_regs,A1
                LEA ea_result,A2
                JSR decode_src_
                JSR print_buffer               
                
count_as_immi
                MOVE.L #pound_sign,string_ptr
                JSR add_str_buffer
                ADD.B #$30,bit11to9
                MOVE.B bit11to9,(A6)+
                BRA get_reg

mem_shifting_ea_routine
                JSR check_src
                
not_ea_routine
                JSR check_src
                JSR print_buffer
ea_is_src
                JSR check_src
                MOVE.L #comma,string_ptr
                JSR add_str_buffer
                CMP.B #%111,bit8to6
                BEQ decode_des_adda
                CMP.B #%011,bit8to6
                BEQ decode_des_adda
                
                LEA data_regs,A1
                LEA ea_result,A2
                BRA decode_des
                RTS
                
decode_des_adda   ; get the destination register for adda
                LEA address_regs,A1
                LEA ea_result,A2
                BRA decode_des
                
ea_is_des
                LEA data_regs,A1
                LEA ea_result,A2
                JSR decode_des
                RTS
                
check_src       
                LEA ea_result,A2
                MOVE.B #1,D2                ; if D2 has 1, it's source
                CMP.B #%000,bit5to3
                BEQ ea000
                CMP.B #%001,bit5to3
                BEQ ea001
                CMP.B #%010,bit5to3
                BEQ ea010
                CMP.B #%011,bit5to3
                BEQ ea011
                CMP.B #%100,bit5to3
                BEQ ea100
                CMP.B #%111,bit5to3
                BEQ ea111
                
                RTS
                
check_des       LEA ea_result,A2
                MOVE.B #2,D2                   ; if D2 has 2, it's destination
                CMP.B #%000,bit8to6
                BEQ ea000
                CMP.B #%001,bit8to6
                BEQ ea001 
                CMP.B #%010,bit8to6
                BEQ ea010
                CMP.B #%011,bit8to6
                BEQ ea011
                CMP.B #%100,bit8to6
                BEQ ea100
                CMP.B #%111,bit8to6
                BEQ ea111
                RTS
                           
                
ea000           ; data register ea
                LEA data_regs,A1
                BRA decode_ea
                
ea001           ; direct address register ea
                LEA address_regs,A1
                BRA decode_ea
                                      
ea010           ; indirect address register ea           
                LEA address_regs,A1
                MOVE.L #left_par,string_ptr
                JSR add_str_buffer
                BRA decode_ea

ea011            ; indirect address register with post increment ea
                LEA address_regs,A1
                MOVE.L #left_par,string_ptr
                JSR add_str_buffer
                BRA decode_ea

ea100           ; indirect address register with pre decrement ea
                LEA address_regs,A1
                MOVE.L #minus_sign,string_ptr
                JSR add_str_buffer
                MOVE.L #left_par,string_ptr
                JSR add_str_buffer
                BRA decode_ea
ea111           
                CMP.B #%0100,bit15to12              ; if msb is $4 and it could be LEA
                BEQ lea_ea
                
ea111_con       CMP.B #1,D2
                BEQ  src_absolute_immidiate
                CMP.B #2,D2
                BEQ des_absolute_immidiate

lea_ea           CMP.B #%111,bit8to6            ; if bit 8 to 6 is %111, it's LEA
                 BNE ea111_con                  ; if not, 111 is mode for absolute addressing
                 LEA address_regs,A1    
                 CMP.B #1,D2
                 BEQ  src_absolute_immidiate
                 CMP.B #2,D2
                 BEQ decode_des
              
src_absolute_immidiate
                CMP.B #%001,bit2to0
                BEQ long_address
                CMP.B #%000,bit2to0
                BEQ word_address
                CMP.B #%100,bit2to0
                BEQ immidiate_address

des_absolute_immidiate  
                CMP.B #%001,bit11to9
                BEQ long_address
                CMP.B #%000,bit11to9
                BEQ word_address   
                
long_address           
                MOVE.L #dollar_sign,string_ptr
                JSR add_str_buffer
                MOVE.B #8,D0
                MOVE.L (A4)+,D3
                MOVEM.L A4,-(SP)
                MOVE.L D3,A4
                JSR hex_to_ascii
                MOVEM.L (SP)+,A4
                MOVE.L #converted_ascii,string_ptr
                JSR add_str_buffer
                CMP.B #$E,bit15to12
                BEQ print_buffer
                CMP.B #$D,bit15to12
                BEQ is_adda
                CMP.B #%010,bit8to6           ; if bit 8 to 6 is %010, it's JSR, no need other operand 
                BEQ print_buffer    
                CMP.B #1,D2               ; if source, go to destination
                BEQ skip
                JSR print_buffer            ; if destination, ready to print
                
                
word_address    
                MOVE.L #dollar_sign,string_ptr
                JSR add_str_buffer
                MOVE.B #4,D0
                MOVE.W (A4)+,D3
                MOVEM.L A4,-(SP)
                MOVE.L D3,A4
                JSR hex_to_ascii
                MOVEM.L (SP)+,A4
                MOVE.L #converted_ascii,string_ptr
                JSR add_str_buffer
                CMP.B #$E,bit15to12
                BEQ print_buffer
                CMP.B #$8,bit15to12
                BEQ print_buffer
                CMP.B #$9,bit15to12
                BEQ print_buffer
                CMP.B #$D,bit15to12
                BEQ is_adda
                CMP.B #%010,bit8to6             ; if bit 8 to 6 is %010, it's JSR, no need other operand 
                BEQ print_buffer            
                CMP.B #1,D2                     ; if source, go to destination
                BEQ skip
                JSR print_buffer                ; if destination, ready to print

is_adda         
                CMP.B #%011,bit8to6   ; print if add
                BNE print_buffer        
                CMP.B #%111,bit8to6   ; print if add  
                BNE print_buffer
                ; called when source ea of adda is absolute addressing
                MOVE.L #comma,string_ptr
                JSR add_str_buffer
                BRA decode_des_adda

immidiate_address
                MOVE.L #pound_sign,string_ptr
                JSR add_str_buffer
                MOVE.L #dollar_sign,string_ptr
                JSR add_str_buffer
                CMP.B #%0010,bit15to12
                BEQ immi_long
                BRA immi_word
                
immi_long       ; use exclusively for MOVE.L
                MOVE.B #8,D0
                MOVE.L (A4)+,D3
                MOVEM.L A4,-(SP)
                MOVE.L D3,A4
                JSR hex_to_ascii
                MOVEM.L (SP)+,A4
                MOVE.L #converted_ascii,string_ptr
                JSR add_str_buffer
                BRA skip
                              
immi_word       ; use exclusively for MOVE.W and MOVE.B
                MOVE.B #4,D0      
                MOVE.W (A4)+,D3
                MOVEM.L A4,-(SP)
                MOVE.L D3,A4
                JSR hex_to_ascii
                MOVEM.L (SP)+,A4
                MOVE.L #converted_ascii,string_ptr
                JSR add_str_buffer
                BRA skip
decode_ea       
                CMP.B #1,D2
                BEQ decode_src
                CMP.B #2,D2
                BEQ decode_des                  
decode_src      
                MOVE.B bit2to0,D0
                MULU.W #3,D0
                LEA (A1,D0.W),A1
                JSR ea_loop
                
                CMP.B #%010,bit5to3         ; add right parenthesis if source is indirect address regesister
                BEQ add_right_par                
                CMP.B #%011,bit5to3
                BEQ add_right_par_plus     ; add right parenthesis and plus if source is indirect address post increment
                CMP.B #%100,bit5to3
                BEQ add_right_par          ; add right parenthesis if source is indirect address regesister pre decrement
                CMP.B #$E,bit15to12
                BEQ print_buffer
exit_src        RTS

decode_src_
                MOVE.B bit2to0,D0
                MULU.W #3,D0
                LEA (A1,D0.W),A1
                JSR ea_loop
                RTS
decode_des     
                MOVE.B bit11to9,D0
                MULU.W #3,D0
                LEA (A1,D0.W),A1
                JSR ea_loop
                BRA check_print
                
check_print
                CMP.B #9,bit15to12  ; if opcode starts with 9, it's sub
                BEQ print_sub_add_or
                CMP.B #8,bit15to12  ; if opcode starts with 8, it's OR
                BEQ print_sub_add_or
                CMP.B #$D,bit15to12  ; if opcode starts with D, it's add
                BEQ print_sub_add_or
                CMP.B #$C,bit15to12   ;opcode starts with C, it's and
                BEQ print_sub_add_or
                CMP.B #$E,bit15to12
                BEQ get_reg
                CMP.B #$D,bit15to12
                BEQ print_buffer
                CMP.B #%111,bit8to6
                BEQ print_buffer
                CMP.B #4,bit15to12
                BEQ print_buffer
                CMP.B #%000,bit8to6       ; if destination mode is data register,don't need parenthesis
                BEQ print_buffer
                CMP.B #%001,bit8to6       ; if destination mode is direct address register,don't need parenthesis
                BEQ print_buffer
                CMP.B #%010,bit8to6
                BEQ add_right_par
                CMP.B #%011,bit8to6
                BEQ add_right_par_plus
                CMP.B #%100,bit8to6
                BEQ add_right_par
                
print_sub_add_or   
                CMP.B #%111,bit8to6    ; if adda.l, print
                BEQ print_buffer
                CMP.B #%011,bit8to6     ; if adda.w, print
                BEQ print_buffer
                CMP.B #2,bit8to6    ; if ea is source, print
                BLE print_buffer
                ; this when ea is destination
                MOVE.L #comma,string_ptr
                JSR add_str_buffer
                JSR check_src
                JSR print_buffer
                
ea_loop         CMP.B #$00,(A1)
                BEQ exit_ea
                SUB.B #1,D1
                MOVE.B (A1)+,(A2)+
                BRA ea_loop
                    
exit_ea         MOVE.B #0,(A2)
                MOVE.L #ea_result,string_ptr
                JSR add_str_buffer
                RTS
                    
add_right_par   MOVE.L #right_par,string_ptr
                JSR add_str_buffer
                CMP.B #$E,bit15to12
                BEQ print_buffer
                CMP.B #2,D2
                BEQ print_buffer
                RTS
                
add_right_par_plus  
                MOVE.L #right_par,string_ptr
                JSR add_str_buffer
                MOVE.L #plus_sign,string_ptr
                JSR add_str_buffer
                CMP.B #$E,bit15to12
                BEQ print_buffer
                CMP.B #2,D2
                BEQ print_buffer
                RTS
                
*================ Registers variables ===================                               
data_regs
d0              DC.B 'D0',0     
d1              DC.B 'D1',0
d2              DC.B 'D2',0   
d3              DC.B 'D3',0   
d4              DC.B 'D4',0   
d5              DC.B 'D5',0   
d6              DC.B 'D6',0   
d7              DC.B 'D7',0

address_regs
a0              DC.B 'A0',0     
a1              DC.B 'A1',0
a2              DC.B 'A2',0   
a3              DC.B 'A3',0   
a4              DC.B 'A4',0   
a5              DC.B 'A5',0   
a6              DC.B 'A6',0   
a7              DC.B 'A7',0 

branch_always
branch_less_equal
branch_equal
branch_greater 
           
            END    START        ; last line of source
































































*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
