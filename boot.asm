[BITS 16]
[ORG 0x7C00]

start:
    mov ax, 0x07C0
    mov ds, ax
    mov ax, 0x07E0  ; Beginning of stack segment
    mov ss, ax
    mov sp, 0x2000  ; 8k of stack space

    call clearscreen

    push word 0x0000
    call movecursor
    add sp, 2

    push word msg
    call print
    add sp, 2

    cli
    hlt

clearscreen:
    push bp         ; Save base pointer
    mov bp, sp
    pusha           ; Push all general-purpose registers

    mov ah, 0x06    ; Scroll up function
    mov al, 0       ; Clear entire screen
    mov bh, 0x07    ; Attribute (white on black)
    mov cx, 0x0000  ; Upper-left corner (row=0, col=0)
    mov dx, 0x184F  ; Lower-right corner (row=24, col=79)
    int 0x10        ; BIOS video service

    popa            ; Restore registers
    mov sp, bp
    pop bp          ; Restore base pointer
    ret

movecursor:
    push bp
    mov bp, sp
    pusha

    mov dx, [bp + 4] ; Get the argument from the stack
    mov ah, 0x02     ; Set cursor position
    mov bh, 0x00     ; Page number
    int 0x10

    popa
    mov sp, bp
    pop bp
    ret

print:
    push bp
    mov bp, sp
    pusha

    mov si, [bp + 4] ; Get pointer to string
    mov ah, 0x0E     ; Teletype output
    mov bh, 0x00     ; Page number
    mov bl, 0x07     ; Text attribute (white on black)

.print_char:
    lodsb            ; Load byte at [SI] into AL and increment SI
    cmp al, 0
    je .done
    int 0x10         ; BIOS teletype output
    jmp .print_char

.done:
    popa
    mov sp, bp
    pop bp
    ret

msg: db 'I hate assembly!', 0

; Pad the rest of the sector with zeros
times 510 - ($ - $$) db 0

; Boot sector signature
dw 0xAA55
