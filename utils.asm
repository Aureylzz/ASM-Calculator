;-------------------------------------------------------------------------------------------------;
; Filename: utils.asm                                                                             ;
;-------------------------------------------------------------------------------------------------;
; Author: Aureylz                                                                                 ;
; Creation Date: 2025-02-09                                                                       ;
;                                                                                                 ;
; Description:                                                                                    ;
;   Provides utility routines used throughout the calculator:                                     ;
;   - read_line_and_trim: Reads input from stdin, trims trailing newlines/carriage returns.       ;
;   - strlen_z: Calculates the length of a null-terminated string.                                ;
;   - convert_s64_to_string: Converts a signed 64-bit integer to a null-terminated string.        ;
;   - print_signed_64_in_parens: Prints a 64-bit integer with optional parentheses for negatives. ;
;                                                                                                 ;
; Version: 1.0                                                                                    ;
;                                                                                                 ;
; License: MIT                                                                                    ;
;-------------------------------------------------------------------------------------------------;
; Modification History:                                                                           ;
; - 2025-02-09: Initial creation (Aureylz)                                                        ;
;-------------------------------------------------------------------------------------------------;


;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~;
;                         GLOBAL DECLARATIONS & EXTERNAL DEPENDENCIES                             ;
;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~;
global read_line_and_trim             ; Exports the read_line_and_trim function
global strlen_z                       ; Exports the strlen_z function
global convert_s64_to_string          ; Exports the convert_s64_to_string function
global print_signed_64_in_parens      ; Exports the print_signed_64_in_parens function

extern print_string                   ; print_string for printing data to stdout


;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~;
;                                          TEXT SECTION                                           ;
;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~;
SECTION .text

;=================================================================================================;
; Function Name: read_line_and_trim                                                               ;
;-------------------------------------------------------------------------------------------------;
; Arguments:                                                                                      ;
;   - RDI: Pointer to the buffer where the input will be stored.                                  ;
;   - RSI: Maximum number of bytes to read.                                                       ;
;-------------------------------------------------------------------------------------------------;
; Description:                                                                                    ;
;   Reads a line of input (up to RSI-1 bytes) from stdin into the buffer at RDI, then trims       ;
;   trailing newline (LF=10) or carriage return (CR=13).                                          ;
;   Returns in RAX the actual number of bytes read, or 0 if none.                                 ;
;=================================================================================================;
read_line_and_trim:
    push rbp                          ; Save old base pointer on the stack
    mov rbp, rsp                      ; Establish a new base pointer
    sub rsp, 8                        ; Reserve 8 bytes for local usage
    push rbx                          ; Save rbx because it will be used

    mov r8, rdi                       ; r8 = pointer to destination buffer (RDI)
    mov r9, rsi                       ; r9 = max number of bytes to read (RSI)
    mov rcx, r9                       ; rcx = keep a copy of r9
    dec rcx                           ; rcx = r9 - 1 => we read up to r9-1 for a trailing null
    mov rax, 0                        ; rax = syscall number for read (0)
    mov rdi, 0                        ; rdi = file descriptor: stdin
    mov rsi, r8                       ; rsi = buffer address
    mov rdx, rcx                      ; rdx = number of bytes to read (r9-1)
    syscall                           ; Perform read(0, buffer, rcx)

    cmp rax, 1                        ; Compare the number of bytes read to 1
    jl .done_zero                     ; If < 1, jump => no valid input

    mov rcx, rax                      ; rcx = number of bytes actually read
    xor rbx, rbx                      ; rbx = 0 => loop index

.trim_loop:
    cmp rbx, rcx                      ; Compare rbx with actual bytes read
    jge .finish_trim                  ; If rbx >= rcx, we are done trimming
    mov dl, [r8 + rbx]                ; dl = buffer[rbx] => current character
    cmp dl, 10                        ; Compare with 10 (LF)
    je .store_zero                    ; If LF, store zero terminator
    cmp dl, 13                        ; Compare with 13 (CR)
    je .store_zero                    ; If CR, store zero terminator
    inc rbx                           ; Move to next character
    jmp .trim_loop                    ; Repeat until we find LF/CR or end

.store_zero:
    mov byte [r8 + rbx], 0            ; Store null terminator at current position

.finish_trim:
    cmp rax, rcx                      ; Compare total read (rax) with rcx (the loop limit)
    jb .done                          ; If rax < rcx, we skip storing zero at end

    mov byte [r8 + rcx], 0            ; Otherwise, ensure we have a null terminator at end

.done:
    mov rax, rcx                      ; Return the number of bytes read in RAX
    jmp .end_func                     ; Jump to end of function

.done_zero:
    mov byte [r8], 0                  ; If no valid input, store a null terminator at buffer[0]
    xor rax, rax                      ; rax = 0 (no bytes read)

.end_func:
    pop rbx                           ; Restore rbx
    add rsp, 8                        ; Free the 8 local bytes
    mov rsp, rbp                      ; Restore stack pointer
    pop rbp                           ; Restore old base pointer
    ret                               ; Return to caller with RAX = number of bytes read


;=================================================================================================;
; Function Name: strlen_z                                                                         ;
;-------------------------------------------------------------------------------------------------;
; Arguments:                                                                                      ;
;   - RDI: Pointer to a null-terminated string.                                                   ;
;-------------------------------------------------------------------------------------------------;
; Description:                                                                                    ;
;   Computes the length of a zero-terminated string by iterating through bytes until a null       ;
;   character (0) is encountered. Returns length in RAX.                                          ;
;=================================================================================================;
strlen_z:
    push rbp                          ; Save old base pointer
    mov rbp, rsp                      ; Establish new base pointer
    xor rax, rax                      ; rax = 0 => will be used as a counter

.len_loop:
    mov dl, [rdi + rax]               ; dl = current character at (rdi + rax)
    cmp dl, 0                         ; Compare with null terminator
    je .done                          ; If zero, end of string => jump
    inc rax                           ; Increment length counter
    jmp .len_loop                     ; Repeat until null is found

.done:
    mov rsp, rbp                      ; Restore stack pointer
    pop rbp                           ; Restore old base pointer
    ret                               ; Return => RAX holds the string length


;=================================================================================================;
; Function Name: convert_s64_to_string                                                            ;
;-------------------------------------------------------------------------------------------------;
; Arguments:                                                                                      ;
;   - RDI: Pointer to a buffer where the resulting string can be placed (64+ bytes recommended).  ;
;   - RSI: A signed 64-bit integer to convert.                                                    ;
;-------------------------------------------------------------------------------------------------;
; Description:                                                                                    ;
;   Converts a signed 64-bit integer (RSI) to its decimal ASCII representation in the buffer      ;
;   pointed to by RDI. The resulting string is null-terminated. RAX returns the original RSI.     ;
;   The buffer must be large enough (64 bytes recommended).                                       ;
;=================================================================================================;
convert_s64_to_string:
    push rbp                          ; Save old base pointer
    mov rbp, rsp                      ; Establish new base pointer
    sub rsp, 16                       ; Reserve 16 bytes for local usage

    mov r8, rsi                       ; r8 = the signed integer we want to convert
    mov rax, r8                       ; rax = r8 => local copy for manipulation
    cmp r8, 0                         ; Compare the original integer to 0
    jge .abs_ok                       ; If >= 0, jump => no negation needed
    neg rax                           ; If < 0, negate rax to get absolute value

.abs_ok:
    mov rbx, rdi                      ; rbx = pointer to the output buffer
    add rbx, 63                       ; Move rbx to the end of a 64-byte area
    mov byte [rbx], 0                 ; Set the last byte to null terminator
    mov rsi, rbx                      ; rsi => points to the end of the buffer now
    cmp rax, 0                        ; Check if the absolute value is zero
    jne .digit_loop                   ; If not zero, we do digit conversions

    ; If rax == 0, directly store "0" in the buffer
    mov byte [rsi - 1], '0'          ; Place '0' just before the terminator
    lea rsi, [rsi - 1]               ; Adjust rsi => now points to that '0'
    jmp .done_digits                  ; Jump => skip the digit loop

.digit_loop:
    xor rdx, rdx                      ; Clear rdx => will store remainder
    mov rcx, 10                       ; rcx = 10 => decimal divisor
    div rcx                           ; rax / 10 => quotient in rax, remainder in rdx
    add rdx, '0'                      ; Convert remainder digit to ASCII
    dec rsi                           ; Move rsi one character backward
    mov [rsi], dl                     ; Store the digit character
    cmp rax, 0                        ; Check if quotient is zero
    jne .digit_loop                   ; If not zero, repeat

.done_digits:
    push rsi                          ; Save the start of our digits
    push rdi                          ; Save the base pointer for the final string

.copy_loop:
    mov al, [rsi]                     ; al = character at rsi
    mov [rdi], al                     ; store al into [rdi]
    inc rsi                           ; increment rsi
    inc rdi                           ; increment rdi
    cmp al, 0                         ; check if we hit the null terminator
    jne .copy_loop                    ; if not, keep copying
    pop rdi                           ; restore original buffer pointer (unused now)
    pop rsi                           ; restore rsi (unused now)
    mov rax, r8                       ; return the original integer in RAX
    add rsp, 16                       ; free local space
    mov rsp, rbp                      ; restore stack pointer
    pop rbp                           ; restore old base pointer
    ret                               ; done => RAX is the original integer

;=================================================================================================;
; Function Name: print_signed_64_in_parens                                                        ;
;-------------------------------------------------------------------------------------------------;
; Arguments:                                                                                      ;
;   - RDI: The signed 64-bit integer to be printed.                                               ;
;-------------------------------------------------------------------------------------------------;
; Description:                                                                                    ;
;   Converts the integer to string via convert_s64_to_string. If negative, prints "(" + "-" +     ;
;   absolute value + ")". Otherwise, prints the integer directly.                                 ;
;=================================================================================================;
print_signed_64_in_parens:
    push rbp                          ; Save old base pointer
    mov rbp, rsp                      ; Establish new base pointer
    sub rsp, 128                      ; Reserve 128 bytes for local usage

    mov [rbp - 8], rdi                ; Store the integer argument into [rbp - 8]
    lea rdi, [rbp - 64]               ; rdi => buffer for conversion
    mov rsi, [rbp - 8]                ; rsi => the signed 64-bit integer
    call convert_s64_to_string        ; Convert integer to string at [rbp-64]

    cmp rax, 0                        ; Compare the original integer with 0
    jl .print_negative                ; If < 0, we do the parentheses method

    ; If non-negative, print the string as-is
    lea rdi, [rbp - 64]               ; RDI => address of the converted string
    call strlen_z                     ; RAX => length of the string
    mov rsi, rax                      ; RSI => length
    lea rdi, [rbp - 64]               ; RDI => address of the converted string again
    call print_string                 ; Print the number
    jmp .done                         ; Skip negative printing

.print_negative:
    ; Print "("
    mov rdi, paren_open_str           ; RDI => "("
    mov rsi, paren_open_str_len       ; RSI => length of "("
    call print_string                 ; Print "("

    ; Print "-"
    mov rdi, minus_sign_str           ; RDI => "-"
    mov rsi, minus_sign_str_len       ; RSI => length of "-"
    call print_string                 ; Print "-"

    ; Print the absolute value string
    lea rdi, [rbp - 64]               ; RDI => converted number
    call strlen_z                     ; RAX => length
    mov rsi, rax                      ; RSI => length
    lea rdi, [rbp - 64]               ; RDI => pointer to the number string
    call print_string                 ; Print the absolute value

    ; Print ")"
    mov rdi, paren_close_str          ; RDI => ")"
    mov rsi, paren_close_str_len      ; RSI => length
    call print_string                 ; Print ")"

.done:
    add rsp, 128                      ; Free local space
    mov rsp, rbp                      ; Restore stack pointer
    pop rbp                           ; Restore old base pointer
    ret                               ; Return to caller


;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~;
;                                        RODATA SECTION                                           ;
;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~;
SECTION .rodata

paren_open_str       db "(",0                   ; "(" null-terminated
paren_open_str_len   equ $ - paren_open_str     ; length of "("

paren_close_str      db ")",0                   ; ")" null-terminated
paren_close_str_len  equ $ - paren_close_str    ; length of ")"

minus_sign_str       db "-",0                   ; "-" null-terminated
minus_sign_str_len   equ $ - minus_sign_str     ; length of "-"

;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~;
;                                  NOTE SECTION FOR GNU STACK                                     ;
;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~;
SECTION .note.GNU-stack noalloc noexec nowrite progbits   ; Indicate stack usage specifics