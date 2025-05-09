[BITS 16]    ; 16-bit real mode
[ORG 0x7C00] ; BIOS loads the bootloader at 0x7C00
CODE_SEG equ 0x08
DATA_SEG equ 0x10
start:
    cli            ; Disable interrupts
    xor ax, ax     ; Clear AX (0)
    mov ds, ax     ; Clear all segment registers; data segment register
    mov es, ax     ; Extra segment register
    mov ss, ax     ; Stack segment register
    mov sp, 0x7C00 ; Stack pointer
load_kernel:
    mov bx, 0x0000 ; Offset to zero
    mov ax, 0x1000 ; Segment where kernel will be loaded
    mov es, ax
    mov si, 17     ; Number of sectors to read
    mov di, 0      ; Segment read counter
.read_sector:
    mov ah, 0x02    ; Tells BIOS to read a sector
    mov al, 1       ; Read 1 sector at a time
    mov ch, 0       ; Cylinder
    mov dh, 0       ; Head
    mov cx, di
    add cx, 2       ; Sector 2 + di
    mov cl, cl      ; For safety reasons
    mov dl, 0x00    ; Drive (floppy) number zero
    mov bx, di
    shl bx, 9       ; bx = di * 512 (sector size)
    int 0x13        ; BIOS interrupt to read disk
    inc di          ; Increment by one
    cmp di, si      ; Compare (==)
    jl .read_sector ; Jump if false
lgdt [gdt_descriptor] ; Load the Global Descriptor Table
call enable_a20       ; Enable the line A20, which allows access to memory above 1MB
mov ah, 0x00          ; Set video mode
mov al, 0x03          ; Mode 3: 80x25 text mode (and clears screen)
int 0x10              ; BIOS interrupt to enter video mode
mov eax, cr0
or eax, 1             ; Protection Enable bit set to 1
mov cr0, eax          ; Enter protected mode
jmp CODE_SEG:init_pm  ; Far jump to 32-bit code
[BITS 32] ; 32-bit protected mode
init_pm:
    mov ax, DATA_SEG
    mov ds, ax              ; Set all segment registers to the data segment
    mov es, ax
    mov fs, ax
    mov gs, ax
    mov ss, ax
    mov esp, 0x90000        ; New stack pointer (new stack needed for 32-bit code)
    jmp CODE_SEG:0x00010000 ; Jump to kernel at 0x00010000
[BITS 16]
halt:
    cli
    hlt
    jmp $ ; Infinite loop
enable_a20:
    in al, 0x92  ; Read I/O port 92
    or al, 0x02  ; Set bit 1
    out 0x92, al ; Enable the A20 line
    ret          ; Return
gdt_start:
    dq 0x0000000000000000 ; Null descriptor
    dq 0x00CF9A000000FFFF ; Code segment descriptor
    dq 0x00CF92000000FFFF ; Data segment descriptor
gdt_descriptor:
    dw gdt_descriptor - gdt_start - 1 ; Size of the GDT (this label - start of the GDT label - 1)
    dd gdt_start                      ; Start of the GDT
times 510-($ - $$) db 0 ; Fill the rest of the bootloader sector with zeros
dw 0xAA55 ; Boot signature (for the BIOS to recognize the bootloader)