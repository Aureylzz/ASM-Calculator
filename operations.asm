;-------------------------------------------------------------------------------------------------;
; Filename: operations.asm                                                                        ;
;-------------------------------------------------------------------------------------------------;
; Author: Aureylz                                                                                 ;
; Creation Date: 2025-02-09                                                                       ;
;                                                                                                 ;
; Description:                                                                                    ;
;   Defines the arithmetic operations (addition, subtraction, multiplication, division) for the   ;
;   ASM calculator. Each operation is handled in a dedicated function.                            ;
;                                                                                                 ;
; Version: 1.0                                                                                    ;
;                                                                                                 ;
; License: MIT                                                                                    ;
;-------------------------------------------------------------------------------------------------;
; Modification History:                                                                           ;
; - 2025-02-09: Initial creation (Aureylz)                                                        ;
;-------------------------------------------------------------------------------------------------;


;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~;
;                               GLOBAL DECLARATIONS & EXTERNAL IMPORTS                            ;
;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~;
global add_numbers                     ; Export add_numbers as a global symbol
global subtract_numbers                ; Export subtract_numbers as a global symbol
global multiply_numbers                ; Export multiply_numbers as a global symbol
global divide_numbers                  ; Export divide_numbers as a global symbol

extern print_string                    ; print_string function (prints a string to stdout)
extern print_newline                   ; print_newline function (prints a single newline to stdout)
extern prompt_first_operand_msg        ; Prompt: "Type your first operand: "
extern prompt_first_operand_msg_len    ; Length of the above prompt
extern prompt_second_operand_msg       ; Prompt: "Type your second operand: "
extern prompt_second_operand_msg_len   ; Length of the above prompt
extern read_valid_operand              ; Function that reads and validates an integer operand
extern print_signed_64_in_parens       ; Prints a signed 64-bit integer, possibly in parentheses if negative


;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~;
;                                         RODATA SECTION                                          ;
;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~;

SECTION .rodata                           ; Read-only data section

; This message is printed before showing the calculation result.
;--------------------------------------------------------------------------------------------------
message_result_str       db "==> RESULT: ",0  ; A null-terminated string for result labeling
message_result_str_len   equ $ - message_result_str ; Compute length of the string above

; Used as the plus sign in expressions.
;--------------------------------------------------------------------------------------------------
message_plus_sign_str    db " + ",0           ; A null-terminated string for the plus sign
message_plus_sign_str_len equ $ - message_plus_sign_str ; Length of the plus-sign string

; Used as the minus sign in expressions.
;--------------------------------------------------------------------------------------------------
message_minus_sign_str   db " - ",0           ; A null-terminated string for the minus sign
message_minus_sign_str_len equ $ - message_minus_sign_str ; Length of the minus-sign string

; Used as the multiplication sign in expressions.
;--------------------------------------------------------------------------------------------------
message_mult_sign_str    db " * ",0           ; A null-terminated string for the multiply sign
message_mult_sign_str_len  equ $ - message_mult_sign_str ; Length of the multiply-sign string

; Used as the division sign in expressions (shown as '%').
;--------------------------------------------------------------------------------------------------
message_div_sign_str     db " % ",0           ; A null-terminated string for the division symbol
message_div_sign_str_len equ $ - message_div_sign_str ; Length of the division-symbol string

; Used to display the '=' sign before the result.
;--------------------------------------------------------------------------------------------------
message_equal_sign_str   db " = ",0           ; A null-terminated string for '='
message_equal_sign_str_len equ $ - message_equal_sign_str ; Length of the equal-sign string

; Used to indicate the remainder portion in division results.
;--------------------------------------------------------------------------------------------------
message_with_rest_str    db ", with a rest to ",0 ; A string showing remainder text
message_with_rest_str_len equ $ - message_with_rest_str ; Length of the remainder text

; Error message shown when the user attempts division by zero.
;--------------------------------------------------------------------------------------------------
message_div_zero_str     db "Error: division by zero not allowed",0 ; Div-by-zero error msg
message_div_zero_str_len equ $ - message_div_zero_str ; Length of the error message string


;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~;
;                                          TEXT SECTION                                           ;
;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~;

SECTION .text                             ; Code (text) section

;=================================================================================================;
; Function Name: add_numbers                                                                      ;
;-------------------------------------------------------------------------------------------------;
; Arguments:                                                                                      ;
;   - None (prompts user for two operands).                                                       ;
;-------------------------------------------------------------------------------------------------;
; Description:                                                                                    ;
;   Prompts the user for two integers and adds them. Displays the result in a formatted manner,   ;
;   including the operands and the sum.                                                           ;
;=================================================================================================;
add_numbers:
    ;---------------------------------------------------------------------------------------------;
    ; Initialize stack frame                                                                      ;
    ;---------------------------------------------------------------------------------------------;
    push rbp                                    ; Save old base pointer on the stack
    mov rbp, rsp                                ; Establish new base pointer

    ;---------------------------------------------------------------------------------------------;
    ; Prompt and read the first operand                                                           ;
    ;---------------------------------------------------------------------------------------------;
    mov rdi, prompt_first_operand_msg           ; RDI <- address of "Type your first operand: "
    mov rsi, prompt_first_operand_msg_len       ; RSI <- length of that prompt
    call read_valid_operand                     ; Calls function to read & validate the operand
    mov r12, rax                                ; Store the first operand in r12

    ;---------------------------------------------------------------------------------------------;
    ; Prompt and read the second operand                                                          ;
    ;---------------------------------------------------------------------------------------------;
    mov rdi, prompt_second_operand_msg          ; RDI <- address of "Type your second operand: "
    mov rsi, prompt_second_operand_msg_len      ; RSI <- length of that prompt
    call read_valid_operand                     ; Calls function to read & validate the operand
    mov r13, rax                                ; Store the second operand in r13

    ;---------------------------------------------------------------------------------------------;
    ; Perform the addition                                                                        ;
    ;---------------------------------------------------------------------------------------------;
    mov rax, r12                                ; RAX <- first operand
    add rax, r13                                ; RAX <- RAX + second operand
    mov r14, rax                                ; Store the result in r14

    ; Print a descriptive message with the operation and result
    mov rdi, message_result_str                 ; RDI <- address of "==> RESULT: "
    mov rsi, message_result_str_len             ; RSI <- length
    call print_string                           ; Print the result label

    mov rdi, r12                                ; RDI <- first operand
    call print_signed_64_in_parens              ; Print the first operand

    mov rdi, message_plus_sign_str              ; RDI <- address of " + "
    mov rsi, message_plus_sign_str_len          ; RSI <- length
    call print_string                           ; Print the plus sign

    mov rdi, r13                                ; RDI <- second operand
    call print_signed_64_in_parens              ; Print the second operand

    mov rdi, message_equal_sign_str             ; RDI <- address of " = "
    mov rsi, message_equal_sign_str_len         ; RSI <- length
    call print_string                           ; Print the equal sign

    mov rdi, r14                                ; RDI <- sum result
    call print_signed_64_in_parens              ; Print the sum

    ; Print two newlines, then restore stack and return
    call print_newline                          ; Print first newline
    call print_newline                          ; Print second newline

    mov rsp, rbp                                ; Restore stack pointer
    pop rbp                                     ; Restore old base pointer
    ret                                         ; Return to caller


;=================================================================================================;
; Function Name: subtract_numbers                                                                 ;
;-------------------------------------------------------------------------------------------------;
; Arguments:                                                                                      ;
;   - None (prompts user for two operands).                                                       ;
;-------------------------------------------------------------------------------------------------;
; Description:                                                                                    ;
;   Prompts the user for two integers and subtracts the second from the first. Prints a           ;
;   descriptive message indicating the operation and its result.                                  ;
;=================================================================================================;
subtract_numbers:
    push rbp                                ; Save old base pointer on the stack
    mov rbp, rsp                            ; Establish new base pointer

    ; Prompt and read the first operand
    mov rdi, prompt_first_operand_msg       ; RDI <- address of "Type your first operand: "
    mov rsi, prompt_first_operand_msg_len   ; RSI <- length of that prompt
    call read_valid_operand                 ; Read & validate first operand -> RAX
    mov r12, rax                            ; Store the first operand in r12

    ; Prompt and read the second operand
    mov rdi, prompt_second_operand_msg      ; RDI <- address of "Type your second operand: "
    mov rsi, prompt_second_operand_msg_len  ; RSI <- length of that prompt
    call read_valid_operand                 ; Read & validate second operand -> RAX
    mov r13, rax                            ; Store the second operand in r13

    ; Perform the subtraction (first operand - second operand)
    mov rax, r12                            ; RAX <- first operand
    sub rax, r13                            ; RAX <- RAX - second operand
    mov r14, rax                            ; Store the result in r14

    ; Print a descriptive message with the operation and result
    mov rdi, message_result_str             ; RDI <- address of "==> RESULT: "
    mov rsi, message_result_str_len         ; RSI <- length
    call print_string                       ; Print the result label

    mov rdi, r12                            ; RDI <- the first operand
    call print_signed_64_in_parens          ; Print first operand in parentheses if negative

    mov rdi, message_minus_sign_str         ; RDI <- address of " - "
    mov rsi, message_minus_sign_str_len     ; RSI <- length
    call print_string                       ; Print the minus sign

    mov rdi, r13                            ; RDI <- the second operand
    call print_signed_64_in_parens          ; Print second operand in parentheses if negative

    mov rdi, message_equal_sign_str         ; RDI <- address of " = "
    mov rsi, message_equal_sign_str_len     ; RSI <- length
    call print_string                       ; Print the equal sign

    mov rdi, r14                            ; RDI <- the result of subtraction
    call print_signed_64_in_parens          ; Print the subtraction result

    ; Print two newlines, then restore stack and return
    call print_newline                      ; Print first newline
    call print_newline                      ; Print second newline

    mov rsp, rbp                            ; Restore stack pointer
    pop rbp                                 ; Restore old base pointer
    ret                                     ; Return to caller


;=================================================================================================;
; Function Name: multiply_numbers                                                                 ;
;-------------------------------------------------------------------------------------------------;
; Arguments:                                                                                      ;
;   - None (prompts user for two operands).                                                       ;
;-------------------------------------------------------------------------------------------------;
; Description:                                                                                    ;
;   Prompts the user for two integers and multiplies them together. Prints a descriptive message  ;
;   showing the operation ("*") and the final product.                                            ;
;=================================================================================================;
multiply_numbers:
    push rbp                                ; Save old base pointer on the stack
    mov rbp, rsp                            ; Establish new base pointer

    ; Prompt and read the first operand
    mov rdi, prompt_first_operand_msg       ; RDI <- address of "Type your first operand: "
    mov rsi, prompt_first_operand_msg_len   ; RSI <- length of that prompt
    call read_valid_operand                 ; Read & validate first operand -> RAX
    mov r12, rax                            ; Store the first operand in r12

    ; Prompt and read the second operand
    mov rdi, prompt_second_operand_msg      ; RDI <- address of "Type your second operand: "
    mov rsi, prompt_second_operand_msg_len  ; RSI <- length of that prompt
    call read_valid_operand                 ; Read & validate second operand -> RAX
    mov r13, rax                            ; Store the second operand in r13

    ; Perform multiplication (first_operand * second_operand)
    mov rax, r12                            ; RAX <- first operand
    imul rax, r13                           ; RAX = RAX * second operand
    mov r14, rax                            ; Store the product in r14

    ; Print a descriptive message with the operation and result
    mov rdi, message_result_str             ; RDI <- address of "==> RESULT: "
    mov rsi, message_result_str_len         ; RSI <- length
    call print_string                       ; Print the result label

    mov rdi, r12                            ; RDI <- the first operand
    call print_signed_64_in_parens          ; Print the first operand

    mov rdi, message_mult_sign_str          ; RDI <- address of " * "
    mov rsi, message_mult_sign_str_len      ; RSI <- length
    call print_string                       ; Print the multiply sign

    mov rdi, r13                            ; RDI <- the second operand
    call print_signed_64_in_parens          ; Print the second operand

    mov rdi, message_equal_sign_str         ; RDI <- address of " = "
    mov rsi, message_equal_sign_str_len     ; RSI <- length
    call print_string                       ; Print the equal sign

    mov rdi, r14                            ; RDI <- the product result
    call print_signed_64_in_parens          ; Print the multiplication result

    ; Print two newlines, then restore stack and return
    call print_newline                      ; Print first newline
    call print_newline                      ; Print second newline

    mov rsp, rbp                            ; Restore stack pointer
    pop rbp                                 ; Restore old base pointer
    ret                                     ; Return to caller


;=================================================================================================;
; Function Name: divide_numbers                                                                   ;
;-------------------------------------------------------------------------------------------------;
; Arguments:                                                                                      ;
;   - None (prompts user for two operands).                                                       ;
;-------------------------------------------------------------------------------------------------;
; Description:                                                                                    ;
;   Prompts the user for two integers and divides the first by the second if nonzero. Displays a  ;
;   descriptive message with the quotient and remainder, or an error if the second operand is 0.  ;
;=================================================================================================;
divide_numbers:
    push rbp                                ; Save old base pointer on the stack
    mov rbp, rsp                            ; Establish new base pointer

    ; Prompt and read the first operand
    mov rdi, prompt_first_operand_msg       ; RDI <- address of "Type your first operand: "
    mov rsi, prompt_first_operand_msg_len   ; RSI <- length of that prompt
    call read_valid_operand                 ; Read & validate first operand -> RAX
    mov r12, rax                            ; Store the first operand in r12

    ; Prompt and read the second operand
    mov rdi, prompt_second_operand_msg      ; RDI <- address of "Type your second operand: "
    mov rsi, prompt_second_operand_msg_len  ; RSI <- length of that prompt
    call read_valid_operand                 ; Read & validate second operand -> RAX
    mov r13, rax                            ; Store the second operand in r13

    ; Check for zero divisor
    cmp r13, 0                              ; Compare second operand with 0
    je .div_by_zero                         ; If zero, jump to error handler

    ; Perform signed division (RAX:RDX / r13 = quotient in RAX, remainder in RDX)
    mov rax, r12                            ; RAX <- first operand (dividend)
    cqo                                     ; Sign-extend RAX into RDX for idiv
    idiv r13                                ; Divide (RAX:RDX) by r13
    mov r14, rax                            ; R14 <- quotient
    mov r15, rdx                            ; R15 <- remainder

    ; Print the descriptive message with both quotient & remainder (if any)
    mov rdi, message_result_str             ; RDI <- address of "==> RESULT: "
    mov rsi, message_result_str_len         ; RSI <- length
    call print_string                       ; Print the result label

    mov rdi, r12                            ; RDI <- the dividend
    call print_signed_64_in_parens          ; Print the dividend

    mov rdi, message_div_sign_str           ; RDI <- " % " for division
    mov rsi, message_div_sign_str_len       ; RSI <- length
    call print_string                       ; Print the division symbol

    mov rdi, r13                            ; RDI <- the divisor
    call print_signed_64_in_parens          ; Print the divisor

    mov rdi, message_equal_sign_str         ; RDI <- address of " = "
    mov rsi, message_equal_sign_str_len     ; RSI <- length
    call print_string                       ; Print the equal sign

    mov rdi, r14                            ; RDI <- the quotient
    call print_signed_64_in_parens          ; Print the quotient

    cmp r15, 0                              ; Compare remainder to zero
    je .done                                ; If no remainder, skip remainder printing

    mov rdi, message_with_rest_str          ; RDI <- address of ", with a rest to "
    mov rsi, message_with_rest_str_len      ; RSI <- length
    call print_string                       ; Print remainder label

    mov rdi, r15                            ; RDI <- the remainder
    call print_signed_64_in_parens          ; Print the remainder

.done:
    call print_newline                      ; Print first newline
    call print_newline                      ; Print second newline
    jmp .finish                             ; Jump to cleanup

.div_by_zero:
    mov rdi, message_div_zero_str           ; RDI <- "Error: division by zero not allowed"
    mov rsi, message_div_zero_str_len       ; RSI <- length
    call print_string                       ; Print the error
    call print_newline                      ; Print a newline
    call print_newline                      ; Print another newline

.finish:
    mov rsp, rbp                            ; Restore stack pointer
    pop rbp                                 ; Restore old base pointer
    ret                                     ; Return to caller


;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~;
;                                  NOTE SECTION FOR GNU STACK                                     ;
;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~;
SECTION .note.GNU-stack noalloc noexec nowrite progbits  ; Indicate no special stack permissions