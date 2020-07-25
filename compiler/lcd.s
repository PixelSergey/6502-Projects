; Symbols
PORTB = $6000
PORTA = $6001
DIRB = $6002
DIRA = $6003

EN = %10000000
RWB = %01000000
RS = %00100000

    .org $8000

setup:
    ldx #$ff       ; Initialise stack pointer to FF
    txs

    lda #%11111111 ; Set all pins on port B to output
    sta DIRB

    lda #%11100000 ; Set relevant pins on port A to output
    sta DIRA

    lda #%00111000 ; Function set: 8-bit mode, 2 lines, 5x8 font
    jsr send_instruction

    lda #%00001111 ; Display control: display on, cursor on, blinking on
    jsr send_instruction

    lda #%00000110 ; Entry mode: increment character position, do not shift screen
    jsr send_instruction

    lda #%00000001 ; Clear display
    jsr send_instruction

    lda #"B"
    jsr send_data

    lda #"e"
    jsr send_data

    lda #"e"
    jsr send_data

    lda #"p"
    jsr send_data

    lda #","
    jsr send_data

    lda #" "
    jsr send_data

    lda #"b"
    jsr send_data

    lda #"o"
    jsr send_data

    lda #"o"
    jsr send_data

    lda #"p"
    jsr send_data

    lda #"!"
    jsr send_data

    lda #%00110000 ; Set DDRAM address to start of next line 
    jsr send_instruction

loop:
    jmp loop

send_instruction:
    sta PORTB
    lda #0         ; Clear RS, RWB, EN bits
    sta PORTA
    lda #EN        ; Enable EN bit (send instruction)
    sta PORTA
    lda #0         ; Clear RS, RWB, EN bits
    sta PORTA
    rts

send_data:
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