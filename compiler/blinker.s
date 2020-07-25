    .org $8000

setup:
    lda #%11111111 ; Set all pins on port B to output
    sta $6002

    lda #%00011000 ; Load pattern into A register
loop:
    rol
    sta $6000
    jmp loop
    
    .org $fffc
    .word setup
    .word $0000