;-------------------------------------------------------------------------------------------------;
; Filename: main.asm                                                                              ;
;-------------------------------------------------------------------------------------------------;
; Author: Aureylz                                                                                 ;
; Creation Date: 2025-02-09                                                                       ;
;                                                                                                 ;
; Description:                                                                                    ;
;   This file defines the main entry point for the ASM calculator. It handles multiple attempts   ;
;   to enter a 4-digit code, calls the validation routine, and upon success, shows the main       ;
;   calculator menu. If the attempts are exhausted, it exits.                                     ;
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
global main

extern error_incorrect_code
extern error_exit_no_attempts_left

extern validate_4_digit_code

extern attempts_left_msg
extern attempts_left_msg_len

extern welcome_msg
extern welcome_msg_len

extern print_string
extern print_newline

extern show_menu


;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~;
;                                          TEXT SECTION                                           ;
;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~;
SECTION .text

;=================================================================================================;
; Function Name: main                                                                             ;
;-------------------------------------------------------------------------------------------------;
; Arguments:                                                                                      ;
;   - None (the entry point of the program).                                                      ;
;-------------------------------------------------------------------------------------------------;
; Description:                                                                                    ;
;   The main entry point for the application. Initializes attempts to 3, checks the user's        ;
;   password, calls show_menu upon successful validation, or exits upon failure.                  ;
;=================================================================================================;
main:
    ;---------------------------------------------------------------------------------------------;
    ; Setup stack frame and initialize the maximum number of password attempts                    ;
    ;---------------------------------------------------------------------------------------------;
    push rbp                            ; Save old base pointer
    mov rbp, rsp                        ; Establish new base pointer
    mov rbx, 3                          ; Keep track of remaining attempts in rbx

.loop_pw:
    ;---------------------------------------------------------------------------------------------;
    ; Attempt to validate password: returns 1 => success, 0 => attempts exhausted, 2 => wrong     ;
    ;---------------------------------------------------------------------------------------------;
    call prompt_and_validate_password   ; Call routine that checks the 4-digit code
    cmp rax, 1                          ; Compare RAX to 1 to see if validation succeeded
    je .correct                         ; If password is correct, jump
    cmp rax, 0                          ; Compare RAX to 0 to see if no attempts remain
    je .fail                            ; If no attempts remain, jump
    jmp .loop_pw                        ; Otherwise, try again

.fail:
    ;---------------------------------------------------------------------------------------------;
    ; Print an error message and exit if attempts are exhausted                                   ;
    ;---------------------------------------------------------------------------------------------;
    call error_exit_no_attempts_left    ; Prints "No attempts left" and exits the program

.correct:
    ;---------------------------------------------------------------------------------------------;
    ; On success, print a welcome message, show the menu, then exit                               ;
    ;---------------------------------------------------------------------------------------------;
    mov rdi, welcome_msg                ; RDI <- address of welcome_msg
    mov rsi, welcome_msg_len            ; RSI <- length of welcome_msg
    call print_string                   ; Print the welcome message
    call print_newline                  ; Print first newline
    call print_newline                  ; Print second newline

    ;---------------------------------------------------------------------------------------------;
    ; Show the calculator menu, then exit the program                                             ;
    ;---------------------------------------------------------------------------------------------;
    call show_menu                      ; Display the calculator menu
    mov rax, 60                         ; Syscall number for exit
    xor rdi, rdi                        ; Exit code => 0
    syscall                             ; Exit immediately


;=================================================================================================;
; Function Name: prompt_and_validate_password                                                     ;
;-------------------------------------------------------------------------------------------------;
; Arguments:                                                                                      ;
;   - None (relies on rbx for the current number of attempts).                                    ;
;-------------------------------------------------------------------------------------------------;
; Description:                                                                                    ;
;   Prompts the user for a 4-digit code by calling validate_4_digit_code. If the code is correct, ;
;   returns 1 in RAX. If attempts remain but the code is incorrect, prints an error and returns 2.;
;   If attempts are exhausted, returns 0.                                                         ;
;=================================================================================================;
prompt_and_validate_password:
    ;---------------------------------------------------------------------------------------------;
    ; Initialize stack frame                                                                      ;
    ;---------------------------------------------------------------------------------------------;
    push rbp
    mov rbp, rsp

    ;---------------------------------------------------------------------------------------------;
    ; Call the routine to validate the 4-digit code                                               ;
    ;---------------------------------------------------------------------------------------------;
    call validate_4_digit_code          ; Checks user input for correctness
    cmp rax, 1                          ; Compare RAX to 1 => correct code?
    je .correct_code                    ; Jump if code is correct

    ;---------------------------------------------------------------------------------------------;
    ; Decrement attempts if code is incorrect                                                     ;
    ;---------------------------------------------------------------------------------------------;
    dec rbx                             ; Decrement rbx (remaining attempts)
    cmp rbx, 0                          ; Check if attempts are exhausted
    je .no_more                         ; If no attempts remain, jump

    ;---------------------------------------------------------------------------------------------;
    ; If attempts remain, print "Incorrect code" and current attempts left                        ;
    ;---------------------------------------------------------------------------------------------;
    call error_incorrect_code           ; Print "Incorrect code."
    mov rdi, attempts_left_msg          ; RDI <- address of "Attempts left: "
    mov rsi, attempts_left_msg_len      ; RSI <- length
    call print_string

    ;---------------------------------------------------------------------------------------------;
    ; Convert attempt count (rbx) to ASCII and print it                                           ;
    ;---------------------------------------------------------------------------------------------;
    mov rcx, rbx                        ; Move attempt count into rcx for ASCII conversion
    add rcx, '0'                        ; Convert numeric value to ASCII digit
    mov rax, 1                          ; 'write' syscall
    mov rdi, 1                          ; stdout (file descriptor)
    push rcx                            ; Push ASCII digit onto stack
    mov rsi, rsp                        ; rsi => address of that ASCII digit
    mov rdx, 1                          ; 1 byte to write
    syscall                             ; Perform the write
    add rsp, 8                          ; Pop the stack

    ;---------------------------------------------------------------------------------------------;
    ; Print two newlines, set RAX=2 => code incorrect but attempts remain                         ;
    ;---------------------------------------------------------------------------------------------;
    call print_newline                  ; Print first newline
    call print_newline                  ; Print second newline
    mov rax, 2                          ; Return 2 => incorrect code, attempts remain
    jmp .done                           ; Jump to function cleanup

.correct_code:
    ;---------------------------------------------------------------------------------------------;
    ; Return 1 in RAX to indicate correct code                                                    ;
    ;---------------------------------------------------------------------------------------------;
    mov rax, 1                          ; RAX=1 => correct code
    jmp .done                           ; Jump to function cleanup

.no_more:
    ;---------------------------------------------------------------------------------------------;
    ; Return 0 in RAX to indicate no more attempts left                                           ;
    ;---------------------------------------------------------------------------------------------;
    mov rax, 0                          ; RAX=0 => attempts exhausted

.done:
    ;---------------------------------------------------------------------------------------------;
    ; Cleanup stack frame and return                                                              ;
    ;---------------------------------------------------------------------------------------------;
    mov rsp, rbp                        ; Restore RSP from RBP
    pop rbp                             ; Restore old base pointer
    ret                                 ; Return to the caller


;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~;
;                                  NOTE SECTION FOR GNU STACK                                     ;
;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~;
SECTION .note.GNU-stack noalloc noexec nowrite progbits
