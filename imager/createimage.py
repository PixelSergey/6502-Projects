exe = bytearray([
    # set data direction register b to all output
    0xa9, 0xff,  # lda 0xff
    0x8d, 0x02, 0x60,  # sta 0x6002
    
    0xa2, 0x00,  # ldx 0x00
    
    0xbd, 0x11, 0x80,  # lda 0x8011 + x
    0x8d, 0x00, 0x60,  # sta 0x6000
    
    0xe8,  # inx
    
    # jmp 0x8007
    0x4c, 0x07, 0x80,
    
    # binary data: lights (prints 314158, a bad approximation of pi)
    0b00101010, 0b00010000, 0b00111100, 0b00010000, 0b11001011, 0b11111111
    ])

rom = exe + bytearray([0xea] * (32768-len(exe)))

# init at 0x8000 = 0x0000
rom[0x7ffc] = 0x00
rom[0x7ffd] = 0x80

with open("rom.bin", "wb") as f:
    f.write(rom)