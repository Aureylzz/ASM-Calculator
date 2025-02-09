;-------------------------------------------------------------------------------------------------;
; Filename: password.asm                                                                          ;
;-------------------------------------------------------------------------------------------------;
; Author: Aureylz                                                                                 ;
; Creation Date: 2025-02-09                                                                       ;
;                                                                                                 ;
; Description:                                                                                    ;
;   Provides the routine for validating a 4-digit code entered by the user. Checks whether the    ;
;   code is exactly 4 digits, numeric only, and matches the correct code. If invalid, it shows    ;
;   an error message.                                                                             ;
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
global validate_4_digit_code               ; Export the validate_4_digit_code function

extern enter_code_msg                      ; Prompt to "Enter the 4-digit code:"
extern enter_code_msg_len                  ; Length of the above message

extern err_code_format_msg                 ; Message for "The code can only contain digits..."
extern err_code_format_msg_len             ; Length of the above message

extern correct_code                        ; The correct 4-digit code string

extern print_string                        ; Prints a string to stdout
extern print_newline                       ; Prints a newline to stdout
extern error_invalid_code_format           ; Prints invalid format error message
extern strlen_z                            ; Returns the length of a zero-terminated string
extern read_line_and_trim                  ; Reads a line from stdin, trims whitespace, stores in buffer


;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~;
;                                          BSS SECTION                                            ;
;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~;
SECTION .bss

; A buffer to store the user's entered code (up to 31 chars + null terminator).
;--------------------------------------------------------------------------------------------------
pw_buffer resb 32


;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~;
;                                          TEXT SECTION                                           ;
;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~;
SECTION .text

;=================================================================================================;
; Function Name: validate_4_digit_code                                                            ;
;-------------------------------------------------------------------------------------------------;
; Arguments:                                                                                      ;
;   - None (the function uses internal logic to prompt and read code).                            ;
;-------------------------------------------------------------------------------------------------;
; Description:                                                                                    ;
;   Prompts the user to enter a 4-digit code. Checks if it is exactly 4 digits long, and all      ;
;   numeric. If valid and matches the 'correct_code', returns RAX=1. Otherwise, returns RAX=0 if  ;
;   code mismatch, or re-prompts if the format is incorrect.                                      ;
;=================================================================================================;
validate_4_digit_code:
    push rbp                                   ; Save old base pointer on the stack
    mov rbp, rsp                               ; Establish a new base pointer
    push rbx                                   ; Save rbx because it will be used as a loop counter

.ask_again:
    ;---------------------------------------------------------------------------------------------;
    ; Prompt user to enter the code, and read into pw_buffer                                      ;
    ;---------------------------------------------------------------------------------------------;
    mov rdi, enter_code_msg                    ; RDI <- address of "Enter the 4-digit code: "
    mov rsi, enter_code_msg_len                ; RSI <- length of that message
    call print_string                          ; Print the prompt
    mov rdi, pw_buffer                         ; RDI <- address of pw_buffer
    mov rsi, 32                                ; RSI <- max bytes to read
    call read_line_and_trim                    ; Read user input into pw_buffer (up to 31 chars + null)
    cmp rax, 1                                 ; Compare # of bytes read to 1
    jl .format_error                           ; If less than 1, format is invalid => jump

    ;---------------------------------------------------------------------------------------------;
    ; Check length is exactly 4                                                                   ;
    ;---------------------------------------------------------------------------------------------;
    mov rdi, pw_buffer                         ; RDI <- address of pw_buffer
    call strlen_z                              ; RAX <- length of the zero-terminated string
    cmp rax, 4                                 ; Must be exactly 4 chars
    jne .format_error                          ; If not 4, jump => format error

    xor rbx, rbx                               ; rbx = 0 (loop counter to check digits)
.digit_loop:
    cmp rbx, 4                                 ; Compare rbx with 4
    jge .compare                               ; If rbx >= 4, done checking digits
    mov dl, [pw_buffer + rbx]                  ; DL <- character at index rbx in pw_buffer
    cmp dl, '0'                                ; Compare character with ASCII '0'
    jb .format_error                           ; If below '0', not a digit => format error
    cmp dl, '9'                                ; Compare character with ASCII '9'
    ja .format_error                           ; If above '9', not a digit => format error
    inc rbx                                    ; Increment rbx for next character
    jmp .digit_loop                            ; Loop until all 4 chars are checked

.compare:
    ;---------------------------------------------------------------------------------------------;
    ; Compare the input code (pw_buffer) with the correct_code (length 4)                         ;
    ;---------------------------------------------------------------------------------------------;
    mov rdi, pw_buffer                         ; RDI <- address of user input
    mov rsi, correct_code                      ; RSI <- address of correct_code
    mov rcx, 4                                 ; RCX <- compare length
    repe cmpsb                                 ; Compares 4 bytes at [RDI] & [RSI]
    jne .no_match                              ; If mismatch, jump => code is incorrect
    mov rax, 1                                 ; If it matches exactly, RAX=1 => success
    jmp .done                                  ; Jump to function cleanup

.no_match:
    mov rax, 0                                 ; RAX=0 => code mismatch
    jmp .done                                  ; Jump to function cleanup

.format_error:
    ;---------------------------------------------------------------------------------------------;
    ; If the code is not exactly 4 digits, call error_invalid_code_format and re-ask              ;
    ;---------------------------------------------------------------------------------------------;
    call error_invalid_code_format             ; Prints "The code can only contain digits..."
    jmp .ask_again                             ; Re-prompt the user

.done:
    pop rbx                                    ; Restore rbx
    mov rsp, rbp                               ; Restore stack pointer from base pointer
    pop rbp                                    ; Restore old base pointer
    ret                                        ; Return => RAX=1 if correct, 0 otherwise


;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~;
;                                  NOTE SECTION FOR GNU STACK                                     ;
;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~;
SECTION .note.GNU-stack noalloc noexec nowrite progbits