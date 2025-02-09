;-------------------------------------------------------------------------------------------------;
; Filename: errors.asm                                                                            ;
;-------------------------------------------------------------------------------------------------;
; Author: Aureylz                                                                                 ;
; Creation Date: 2025-02-09                                                                       ;
;                                                                                                 ;
; Description:                                                                                    ;
;   This file contains routines that handle error messages and program termination scenarios      ;
;   related to incorrect codes and attempts left.                                                 ;
;                                                                                                 ;
; Version: 1.0                                                                                    ;
;                                                                                                 ;
; License: MIT                                                                                    ;
;-------------------------------------------------------------------------------------------------;
; Modification History:                                                                           ;
; - 2025-02-09: Initial creation (Aureylz)                                                        ;
;-------------------------------------------------------------------------------------------------;


;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~;
;                              GLOBAL DECLARATION AND EXTERNAL IMPORT                             ;
;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~;
global error_incorrect_code
global error_invalid_code_format
global error_exit_no_attempts_left

extern err_incorrect_code_msg
extern err_incorrect_code_msg_len

extern err_code_format_msg
extern err_code_format_msg_len

extern err_no_attempts_left_msg
extern err_no_attempts_left_msg_len

extern print_string
extern print_newline


;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~;
;                                           TEXT SECTION                                          ;
;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~;
SECTION .text

;=================================================================================================;
; Function Name: error_incorrect_code                                                             ;
;-------------------------------------------------------------------------------------------------;
; Arguments:                                                                                      ;
;   - None (uses external data references and registers internally)                               ;
;-------------------------------------------------------------------------------------------------;
; Description:                                                                                    ;
;   Prints an "incorrect code" error message, then a newline.                                     ;
;   Returns to the caller immediately after printing.                                             ;
;=================================================================================================;
error_incorrect_code:
    ;---------------------------------------------------------------------------------------------;
    ; Initialize stack frame                                                                      ;
    ;---------------------------------------------------------------------------------------------;
    push rbp                                ; Save old base pointer on the stack
    mov rbp, rsp                            ; Establish a new base pointer

    ;---------------------------------------------------------------------------------------------;
    ; We want to print "Incorrect code."                                                          ;
    ;---------------------------------------------------------------------------------------------;
    mov rdi, err_incorrect_code_msg         ; RDI <- address of the error message
    mov rsi, err_incorrect_code_msg_len     ; RSI <- length of the error message
    call print_string                       ; Call function to print the string

    ;---------------------------------------------------------------------------------------------;
    ; Print a newline                                                                             ;
    ;---------------------------------------------------------------------------------------------;
    call print_newline                      ; Print a newline

    ;---------------------------------------------------------------------------------------------;
    ; Cleanup stack frame and return                                                              ;
    ;---------------------------------------------------------------------------------------------;
    mov rsp, rbp                            ; Restore stack pointer
    pop rbp                                 ; Restore old base pointer
    ret                                     ; Return to caller


;=================================================================================================;
; Function Name: error_invalid_code_format                                                        ;
;-------------------------------------------------------------------------------------------------;
; Arguments:                                                                                      ;
;   - None (uses external data references and registers internally)                               ;
;-------------------------------------------------------------------------------------------------;
; Description:                                                                                    ;
;   Prints a message indicating the code contains invalid characters or length, then prints       ;
;   a newline.                                                                                    ;
;=================================================================================================;
error_invalid_code_format:
    ;---------------------------------------------------------------------------------------------;
    ; Initialize stack frame                                                                      ;
    ;---------------------------------------------------------------------------------------------;
    push rbp                                ; Save old base pointer on the stack
    mov rbp, rsp                            ; Establish a new base pointer

    ;---------------------------------------------------------------------------------------------;
    ; We want to print "The code can only contain digits, exactly 4 of them..."                   ;
    ;---------------------------------------------------------------------------------------------;
    mov rdi, err_code_format_msg            ; RDI <- address of format error message
    mov rsi, err_code_format_msg_len        ; RSI <- length of the error message
    call print_string                       ; Call function to print the string

    ;---------------------------------------------------------------------------------------------;
    ; Print a newline                                                                             ;
    ;---------------------------------------------------------------------------------------------;
    call print_newline                      ; Print a newline

    ;---------------------------------------------------------------------------------------------;
    ; Cleanup stack frame and return                                                              ;
    ;---------------------------------------------------------------------------------------------;
    mov rsp, rbp                            ; Restore stack pointer
    pop rbp                                 ; Restore old base pointer
    ret                                     ; Return to caller

;=================================================================================================;
; Function Name: error_exit_no_attempts_left                                                      ;
;-------------------------------------------------------------------------------------------------;
; Arguments:                                                                                      ;
;   - None (uses external data references and registers internally)                               ;
;-------------------------------------------------------------------------------------------------;
; Description:                                                                                    ;
;   Prints a "No attempts left" message, a newline, and then exits the program via syscall 60.    ;
;=================================================================================================;
error_exit_no_attempts_left:
    ;---------------------------------------------------------------------------------------------;
    ; Initialize stack frame                                                                      ;
    ;---------------------------------------------------------------------------------------------;
    push rbp                                ; Save old base pointer on the stack
    mov rbp, rsp                            ; Establish a new base pointer

    ;---------------------------------------------------------------------------------------------;
    ; Print "No attempts left."                                                                   ;
    ;---------------------------------------------------------------------------------------------;
    mov rdi, err_no_attempts_left_msg       ; RDI <- address of the "No attempts" message
    mov rsi, err_no_attempts_left_msg_len   ; RSI <- length of the message
    call print_string                       ; Print the string

    ;---------------------------------------------------------------------------------------------;
    ; Print a newline                                                                             ;
    ;---------------------------------------------------------------------------------------------;
    call print_newline                      ; Print a newline

    ;---------------------------------------------------------------------------------------------;
    ; Exit system call (60)                                                                       ;
    ;---------------------------------------------------------------------------------------------;
    mov rax, 60                             ; 60 is the exit syscall
    xor rdi, rdi                            ; RDI <- 0 (exit code)
    syscall                                 ; Make syscall to terminate the program immediately