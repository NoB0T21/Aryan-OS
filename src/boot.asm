[BITS 16]
[ORG 0x7c00]

CODE_OFFSET equ 0x8
DATA_OFFSET equ 0x10

KERNEL_LOAD_SEG equ 0x1000
KERNEL_START_ADDR equ 0x10000

start:
    cli ;clear interrupts
    mov ax, 0x00
    mov ds, ax ;set data segment to 0
    mov es, ax ;set extra segment to 0
    mov ss, ax ;set stack segment to 0
    mov sp, 0x7c00 ;set stack pointer to 0x7c00
    sti ;enable interrupts

;load kernel
mov ax, KERNEL_LOAD_SEG
mov es, ax
mov bx, 0x0000
mov dh, 0x00
mov dl, 0x80 ;first hard disk
mov ch, 0x00 ;cylinder number
mov cl, 0x02 ;number of sectors to read
mov ah, 0x02 ; BIOS read sector function
mov al, 8 ;number of sectors to read
int 0x13 ;call BIOS interrupt

jc disk_read_error

load_PM:
    cli ;clear interrupts
    lgdt [gdt_descriptor] ;load GDT
    mov eax, cr0 ;read CR0
    or al, 1 ;set PE bit in CR0 to enable protected mode
    mov cr0, eax ;write back to CR0
    jmp CODE_OFFSET:PModeMain ;jump to protected mode code

disk_read_error:
    hlt

;GDT implemantation
gdt_start:
    dd 0x0
    dd 0x0 ;null descriptor 

    ;code segment descriptor
    dw 0xFFFF ; limit low
    dw 0x0000 ; base
    db 0x00 ; base
    db 10011010b ; access byte
    db 11001111b ; flags and limit high
    db 0x00 ; base

    ;data segment descriptor
    dw 0xFFFF ; limit low
    dw 0x0000 ; base
    db 0x00 ; base
    db 10010010b ; access byte
    db 11001111b ; flags and limit high
    db 0x00 ; base

gdt_end:

gdt_descriptor:
    dw gdt_end - gdt_start - 1 ; size of GDT
    dd gdt_start ; address of GDT

[BITS 32]
PModeMain:
    mov ax, DATA_OFFSET ; load data segment selector
    mov ds, ax ; set data segment
    mov es, ax ; set extra segment
    mov fs, ax ; set fs segment
    mov ss, ax ; set stack segment
    mov gs, ax ; set gs segment
    mov ebp, 0x9c00 ; set base pointer to 0x9c00
    mov esp, ebp ; set stack pointer to base pointer

    in al, 0x92 ; read from port 0x92
    or al, 2 ; set the A20 gate
    out 0x92, al ; write back to port 0x92

    jmp CODE_OFFSET:KERNEL_START_ADDR ; jump to kernel entry point

times 510 - ($ - $$) db 0 ; fill the rest of the boot sector with zeros
dw 0xAA55