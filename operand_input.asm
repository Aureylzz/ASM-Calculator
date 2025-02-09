;-------------------------------------------------------------------------------------------------;
; Filename: operand_input.asm                                                                     ;
;-------------------------------------------------------------------------------------------------;
; Author: Aureylz                                                                                 ;
; Creation Date: 2025-02-09                                                                       ;
;                                                                                                 ;
; Description:                                                                                    ;
;   Prompts the user for valid integer input, reading from stdin. Ensures input is within the     ;
;   allowed numeric range and is in correct numeric format. If invalid, re-prompts until a valid  ;
;   integer is entered. Returns the valid operand in RAX.                                         ;
;                                                                                                 ;
; Version: 1.0                                                                                    ;
;                                                                                                 ;
; License: MIT                                                                                    ;
;-------------------------------------------------------------------------------------------------;
; Modification History:                                                                           ;
; - 2025-02-09: Initial creation (Aureylz)                                                        ;
;-------------------------------------------------------------------------------------------------;


;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~;
;                                GLOBAL DECLARATIONS & EXTERNAL IMPORTS                           ;
;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~;
global read_valid_operand

extern print_string
extern print_newline

extern invalid_operand_msg
extern invalid_operand_msg_len

extern read_line_and_trim


;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~;
;                                          BSS SECTION                                            ;
;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~;
SECTION .bss

; This buffer stores the user's raw input for an operand (up to 63 chars + null terminator).
;--------------------------------------------------------------------------------------------------
operand_buffer resb 64


;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~;
;                                          TEXT SECTION                                           ;
;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~;
SECTION .text

;=================================================================================================;
; Function Name: read_valid_operand                                                               ;
;-------------------------------------------------------------------------------------------------;
; Arguments:                                                                                      ;
;   - RDI: Address of the prompt string to display before input.                                  ;
;   - RSI: Length of the prompt string.                                                           ;
;-------------------------------------------------------------------------------------------------;
; Description:                                                                                    ;
;   Repeatedly prompts the user for an operand input by printing a prompt message. Reads the      ;
;   user input into operand_buffer, then calls parse_and_validate_integer. If the input is valid, ;
;   returns it in RAX. If invalid, it prints an error message, then re-prompts until a valid      ;
;   operand is entered.                                                                           ;
;=================================================================================================;
read_valid_operand:
    ;---------------------------------------------------------------------------------------------;
    ; Setup stack frame and reserve space for local variables                                     ;
    ;---------------------------------------------------------------------------------------------;
    push rbp                            ; Save the old base pointer on the stack
    mov rbp, rsp                        ; Establish a new base pointer
    sub rsp, 16                         ; Reserve 16 bytes for local usage

    ;---------------------------------------------------------------------------------------------;
    ; Store function arguments (prompt msg address & length) in local variables                   ;
    ;---------------------------------------------------------------------------------------------;
    mov [rbp-8], rdi                    ; Save prompt string address in [rbp - 8]
    mov [rbp-16], rsi                   ; Save prompt string length in [rbp - 16]

.read_loop:
    ;---------------------------------------------------------------------------------------------;
    ; Print the prompt string to ask for operand                                                  ;
    ;---------------------------------------------------------------------------------------------;
    mov rdi, [rbp-8]                    ; RDI <- address of the prompt message
    mov rsi, [rbp-16]                   ; RSI <- length of the prompt message
    call print_string                   ; Print the prompt message

    ;---------------------------------------------------------------------------------------------;
    ; Read input from the user into operand_buffer                                                ;
    ;---------------------------------------------------------------------------------------------;
    mov rdi, operand_buffer             ; RDI <- address of operand_buffer
    mov rsi, 64                         ; RSI <- maximum bytes to read
    call read_line_and_trim             ; Read user input (up to 63 chars + null)

    ;---------------------------------------------------------------------------------------------;
    ; Parse and validate the integer input                                                        ;
    ;---------------------------------------------------------------------------------------------;
    call parse_and_validate_integer     ; Returns valid int in RAX if success, or CF=1 if invalid
    jc .invalid_input                   ; If CF=1, input is invalid, jump

    ;---------------------------------------------------------------------------------------------;
    ; If valid, jump to .done, returning RAX (the parsed integer)                                 ;
    ;---------------------------------------------------------------------------------------------;
    jmp .done

.invalid_input:
    ;---------------------------------------------------------------------------------------------;
    ; Print an error message, then re-prompt                                                      ;
    ;---------------------------------------------------------------------------------------------;
    mov rdi, invalid_operand_msg        ; RDI <- address of the invalid input message
    mov rsi, invalid_operand_msg_len    ; RSI <- length of the invalid message
    call print_string                   ; Print the error message
    call print_newline                  ; Print a newline
    jmp .read_loop                      ; Loop back to prompt again

.done:
    ;---------------------------------------------------------------------------------------------;
    ; Cleanup local stack space and restore base pointer                                          ;
    ;---------------------------------------------------------------------------------------------;
    add rsp, 16                         ; Free the 16 bytes of local space
    mov rsp, rbp                        ; Restore stack pointer
    pop rbp                             ; Restore old base pointer
    ret                                 ; Return to caller (RAX has the valid integer)


;=================================================================================================;
; Function Name: parse_and_validate_integer                                                       ;
;-------------------------------------------------------------------------------------------------;
; Arguments:                                                                                      ;
;   - None (works with operand_buffer in BSS).                                                    ;
;-------------------------------------------------------------------------------------------------;
; Description:                                                                                    ;
;   Parses the string in operand_buffer as a signed 64-bit integer, ensuring it is within         ;
;   [-1000000000, 1000000000]. If valid, clears the carry flag (CF=0) and returns the value in    ;
;   RAX. If invalid, sets the carry flag (CF=1).                                                  ;
;=================================================================================================;
parse_and_validate_integer:
    ;---------------------------------------------------------------------------------------------;
    ; Setup stack frame                                                                           ;
    ;---------------------------------------------------------------------------------------------;
    push rbp                            ; Save the old base pointer on the stack
    mov rbp, rsp                        ; Establish a new base pointer

    ;---------------------------------------------------------------------------------------------;
    ; r8 will hold the sign multiplier (+1 or -1). r9 is a pointer to operand_buffer.             ;
    ;---------------------------------------------------------------------------------------------;
    mov r8, 1                           ; r8 = +1 by default
    lea r9, [operand_buffer]            ; r9 = address of operand_buffer

    ;---------------------------------------------------------------------------------------------;
    ; Check if the first character is a minus sign                                                ;
    ;---------------------------------------------------------------------------------------------;
    mov al, [r9]                        ; AL = first character of the input
    cmp al, '-'                         ; Compare with '-'
    jne .skip_minus                     ; If it's not '-', jump to .skip_minus
    mov r8, -1                          ; If minus sign, set r8 to -1
    add r9, 1                           ; Advance pointer to skip the '-'

.skip_minus:
    ;---------------------------------------------------------------------------------------------;
    ; Check if the string is empty after skipping minus sign                                      ;
    ;---------------------------------------------------------------------------------------------;
    mov al, [r9]                        ; AL = next character
    cmp al, 0                           ; Compare with 0 (null terminator)
    je .invalid                         ; If string is now empty, it's invalid

    ;---------------------------------------------------------------------------------------------;
    ; Clear RAX so we can start building the result                                               ;
    ;---------------------------------------------------------------------------------------------;
    xor rax, rax                        ; RAX = 0 (initialize accumulator)

.convert_loop:
    ;---------------------------------------------------------------------------------------------;
    ; Read next character and check for end of string or invalid digits                           ;
    ;---------------------------------------------------------------------------------------------;
    mov dl, [r9]                        ; DL = current character
    cmp dl, 0                           ; Compare with 0 (null terminator)
    je .apply_sign                      ; If null terminator, jump to .apply_sign
    cmp dl, '0'                         ; Compare character with '0'
    jb .invalid                         ; If below '0', it's invalid
    cmp dl, '9'                         ; Compare character with '9'
    ja .invalid                         ; If above '9', it's invalid

    ;---------------------------------------------------------------------------------------------;
    ; Multiply current RAX by 10 and add the new digit                                            ;
    ;---------------------------------------------------------------------------------------------;
    imul rax, rax, 10                   ; RAX = RAX * 10
    sub dl, '0'                         ; Convert ASCII digit to numeric value
    movzx rdx, dl                       ; Zero-extend DL into RDX
    add rax, rdx                        ; RAX += digit
    add r9, 1                           ; Advance pointer to the next character
    jmp .convert_loop                   ; Repeat until string ends or invalid digit

.apply_sign:
    ;---------------------------------------------------------------------------------------------;
    ; Apply sign if needed                                                                        ;
    ;---------------------------------------------------------------------------------------------;
    cmp r8, 1                           ; Check if sign multiplier is +1
    je .check_bounds                    ; If +1, skip negation
    neg rax                             ; If -1, negate RAX to apply negative sign

.check_bounds:
    ;---------------------------------------------------------------------------------------------;
    ; Compare RAX to the allowed range [-1000000000, 1000000000]                                  ;
    ;---------------------------------------------------------------------------------------------;
    mov r10, 1000000000                 ; r10 = 1000000000
    cmp rax, r10                        ; Compare RAX with 1000000000
    jg .invalid                         ; If RAX > 1000000000, it's invalid

    ;---------------------------------------------------------------------------------------------;
    ; Now check lower bound (r10 = -1000000000)                                                   ;
    ;---------------------------------------------------------------------------------------------;
    neg r10                             ; r10 = -1000000000
    cmp rax, r10                        ; Compare RAX with -1000000000
    jl .invalid                         ; If RAX < -1000000000, it's invalid

    ;---------------------------------------------------------------------------------------------;
    ; If within range, clear the carry flag and exit                                              ;
    ;---------------------------------------------------------------------------------------------;
    clc                                 ; CF = 0 (valid integer)
    jmp .done                           ; Jump to .done

.invalid:
    stc                                 ; CF = 1 (invalid integer)

.done:
    ;---------------------------------------------------------------------------------------------;
    ; Cleanup stack frame and return                                                              ;
    ;---------------------------------------------------------------------------------------------;
    mov rsp, rbp                        ; Restore stack pointer from base pointer
    pop rbp                             ; Restore the old base pointer
    ret                                 ; Return to caller (RAX holds the int if CF=0)
    

;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~;
;                                  NOTE SECTION FOR GNU STACK                                     ;
;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~;
SECTION .note.GNU-stack noalloc noexec nowrite progbits