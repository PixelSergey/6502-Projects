; Symbols
PORTB = $6000
PORTA = $6001
DIRB = $6002
DIRA = $6003

EN = %10000000
RWB = %01000000
RS = %00100000

; Location of used data sections in RAM

VALUE = $0200 ; 2 bytes. Right-hand side of the data initially used for storing the value
REMAINDER = $0202 ; 2 bytes. Left-hand side of the data used for storing the remainder
MESSAGE = $0204 ; 6 bytes. Message to be displayed on the display
COUNTER = $020A ; 2 bytes. Counter for interrupts.

    .org $8000

; Data section

; LCD startup commands:
; Function set: 8-bit mode, 2 lines, 5x8 font
; Display control: display on, cursor on, blinking on
; Entry mode: increment character position, do not shift screen
; Clear display
; Null byte
startup_cmds: .db %00111000,%00001111,%00000110,%00000001,0

; Text section
setup:
    ldx #$ff       ; Initialise stack pointer to FF
    txs
    cli            ; Enable interrupts
    lda #%11111111 ; Set all pins on port B to output
    sta DIRB
    lda #%11100000 ; Set relevant pins on port A to output
    sta DIRA
    lda #0
    sta COUNTER
    sta COUNTER + 1

    ldx #0
instr_loop:        ; Loop to send the instructions found in the data section
    lda startup_cmds,x
    beq begin_convert
    jsr send_instruction
    inx
    jmp instr_loop

begin_convert:
    lda #%00000010
    jsr send_instruction ; Go back to HOME
    
    lda #0
    sta MESSAGE
    lda COUNTER        ; Load the number to be converted into two addresses in RAM
    sta VALUE
    lda COUNTER + 1
    sta VALUE + 1

clear_remainder:
    lda #0         ; Clear the remainder addresses in RAM
    sta REMAINDER
    sta REMAINDER + 1
    clc

    ldx #16        ; Use X register as a counter
rotate_through:    ; Rotate all bits one to the left.
    rol VALUE      ; Rotates are done in this order due to the data being stored
    rol VALUE + 1  ; in little-endian format.
    rol REMAINDER
    rol REMAINDER + 1

do_subtraction:
    sec
    lda REMAINDER
    sbc #10
    tay            ; Store the low byte of subtraction in the Y register
    lda REMAINDER + 1
    sbc #0         ; Subtract zero *with carry bit*
    ; A and Y now contain remainder - 10
    
    bcc ignore_result ; If the carry bit is 0, a carry was performed; ignore the result
    sty REMAINDER     ; Else, store the result back
    sta REMAINDER + 1

ignore_result:
    dex
    bne rotate_through

    rol VALUE
    rol VALUE + 1
output_digit:
    lda REMAINDER
    clc
    adc #"0"
    jsr add_char

    ; If the VALUE != 0, keep dividing
    lda VALUE
    ora VALUE + 1
    bne clear_remainder

print_setup:
    ldx #0
print_loop:        ; Loop to send the data to the screen 
    lda MESSAGE,x  ; Load current char into A
    beq before_loop; If it's the null terminator, jump out
    jsr send_data  ; Send it
    inx
    jmp print_loop

before_loop:
    lda #%11000000 ; Set the DDRAM address to line 2
    jsr send_instruction
    jmp begin_convert

; Subroutines

; Pushes the character into the `message` variable
add_char:
    pha            ; Push the character to be added onto the stack
    ldy #0         ; Counter to 0
add_loop:
    lda MESSAGE,y  ; Load current y:th character into A
    tax            ; Store it in the X register
    pla            ; Pull the character to be added into A
    sta MESSAGE,y  ; Store it at the current location
    
    iny            ; Inc. counter
    txa            ; Get the current y:th character back
    pha            ; Push it back onto the stack for the next iteration
    bne add_loop   ; If the character was not the null terminator, loop back

    pla            ; Pull the null terminator off the stack
    sta MESSAGE,y  ; And store it to the back
    rts


wait_for_lcd:
    pha
    lda #%00000000 ; Set all pins on port B to input
    sta DIRB
read_flag:
    lda #RWB       ; Enable RWB; clear RS, EN
    sta PORTA
    lda #(RWB | EN); Enable EN, RWB bit (send instruction)
    sta PORTA

    lda PORTB      ; Read busy flag
    and #%10000000 ; Isolate busy flag
    bne read_flag  ; Jump back if result was not 0 (busy flag is 1)

    lda #%11111111 ; Set all pins on port B to output
    sta DIRB
    lda #RWB
    sta PORTA

    pla
    rts

send_instruction:
    jsr wait_for_lcd
    sta PORTB
    lda #0         ; Clear RS, RWB, EN bits
    sta PORTA
    lda #EN        ; Enable EN bit (send instruction)
    sta PORTA
    lda #0         ; Clear RS, RWB, EN bits
    sta PORTA
    rts

send_data:
    jsr wait_for_lcd
    sta PORTB
    lda #RS         ; Set RS; clear RWB, EN bits
    sta PORTA
    lda #(EN | RS)  ; Enable EN, RS bit (send data)
    sta PORTA
    lda #RS         ; Set RS; clear RWB, EN bits
    sta PORTA
    rts

; Interrupts
irqb:
nmib:
    inc COUNTER
    bne exit_nmib
    inc COUNTER + 1
exit_nmib:
    rti

; Vectors
    .org $fffa
    .word nmib
    .word setup
    .word irqb