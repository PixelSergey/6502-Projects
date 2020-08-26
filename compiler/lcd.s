; Symbols
PORTB = $6000
PORTA = $6001
DIRB = $6002
DIRA = $6003

EN = %10000000
RWB = %01000000
RS = %00100000

    .org $8000

; Data section

; LCD startup commands:
; Function set: 8-bit mode, 2 lines, 5x8 font
; Display control: display on, cursor on, blinking on
; Entry mode: increment character position, do not shift screen
; Clear display
; Null byte
startup_cmds: .db %00111000,%00001111,%00000110,%00000001,0
; String to send to the display
to_print: .asciiz "Beep, boop! (2)"

; Text section
setup:
    ldx #$ff       ; Initialise stack pointer to FF
    txs
    lda #%11111111 ; Set all pins on port B to output
    sta DIRB
    lda #%11100000 ; Set relevant pins on port A to output
    sta DIRA

    ldx #0
instr_loop:        ; Loop to send the instructions found in the data section
    lda startup_cmds,x
    beq print_setup
    jsr send_instruction
    inx
    jmp instr_loop

print_setup:
    ldx #0
print_loop:        ; Loop to send the data to the screen 
    lda to_print,x
    beq before_loop
    jsr send_data
    inx
    jmp print_loop

before_loop:
    lda #%11000000 ; Set the DDRAM address to line 2
    jsr send_instruction

loop:
    jmp loop


; Subroutines

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


; Reset vector
    .org $fffc
    .word setup
    .word $0000