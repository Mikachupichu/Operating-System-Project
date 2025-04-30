[BITS 16] ; 16-bit registers
[ORG 0x7C00] ; location (default location where the BIOS loads the bootloader)
message: db "Hello, World!", 0 ; '0' to indicate the end of the string
start: mov si, message
print_loop:
    lodsb ; Move a byte from 'si' to 'al' and prepare to access the next byte
    cmp al, 0 ; Compare
    je done ; If true, run 'done'
    mov ah, 0x0E ; BIOS teletype function: indicates that a character is to be printed
    int 0x10 ; Interrupt:'0x10' to indicate BIOS video services (showing something on screen)
    jmp print_loop
done:
    cli ; Disable interrupts
    hlt ; Halt CPU
times 510-($ - $$) db 0 ; 512 bytes (code above + 0's + 2-byte next line)