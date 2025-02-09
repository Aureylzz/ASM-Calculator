;-------------------------------------------------------------------------------------------------;
; Filename: io.asm                                                                                ;
;-------------------------------------------------------------------------------------------------;
; Author: Aureylz                                                                                 ;
; Creation Date: 2025-02-09                                                                       ;
;                                                                                                 ;
; Description:                                                                                    ;
;   Provides basic I/O routines for reading a single character, printing a string, and printing   ;
;   a newline character. Serves as a helper module for the ASM calculator.                        ;
;                                                                                                 ;
; Version: 1.0                                                                                    ;
;                                                                                                 ;
; License: MIT                                                                                    ;
;-------------------------------------------------------------------------------------------------;
; Modification History:                                                                           ;
; - 2025-02-09: Initial creation (Aureylz)                                                        ;
;-------------------------------------------------------------------------------------------------;


;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~;
;                                       GLOBAL DECLARATIONS                                       ;
;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~;
global read_char
global print_string
global print_newline


;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~;
;                                          DATA SECTION                                           ;
;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~;
SECTION .data

; This single byte holds a line feed (LF) character (ASCII code 10) used by print_newline.
;--------------------------------------------------------------------------------------------------
lf db 10


;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~;
;                                          TEXT SECTION                                           ;
;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~;
SECTION .text

;=================================================================================================;
; Function Name: read_char                                                                        ;
;-------------------------------------------------------------------------------------------------;
; Arguments:                                                                                      ;
;   - RDX: Address of the buffer where the character will be read into.                           ;
;-------------------------------------------------------------------------------------------------;
; Description:                                                                                    ;
;   Reads exactly one character from stdin (file descriptor 0) and stores it into the buffer      ;
;   pointed to by RDX. Only one byte is read.                                                     ;
;=================================================================================================;
read_char:
    ;---------------------------------------------------------------------------------------------;
    ; Initialize stack frame                                                                      ;
    ;---------------------------------------------------------------------------------------------;
    push rbp                         ; Save old base pointer on the stack
    mov rbp, rsp                     ; Establish a new base pointer

    ;---------------------------------------------------------------------------------------------;
    ; Setup the read syscall: read(0, buffer, 1)                                                  ;
    ;---------------------------------------------------------------------------------------------;
    mov rax, 0                       ; rax <- 0 : 'read' syscall number
    mov rdi, 0                       ; rdi <- 0 : file descriptor (stdin)
    mov rsi, rdx                     ; rsi <- rdx: address of the buffer (passed by caller)
    mov rdx, 1                       ; rdx <- 1 : number of bytes to read (1 byte)
    syscall                          ; Make syscall to read from stdin

    ;---------------------------------------------------------------------------------------------;
    ; Cleanup stack frame and return                                                              ;
    ;---------------------------------------------------------------------------------------------;
    mov rsp, rbp                     ; Restore stack pointer
    pop rbp                          ; Restore old base pointer
    ret                              ; Return to caller


;=================================================================================================;
; Function Name: print_string                                                                     ;
;-------------------------------------------------------------------------------------------------;
; Arguments:                                                                                      ;
;   - RDI: Address of the string to be printed.                                                   ;
;   - RSI: Length of the string to be printed.                                                    ;
;-------------------------------------------------------------------------------------------------;
; Description:                                                                                    ;
;   Prints the string (in RDI) of length (in RSI) to stdout (file descriptor 1) using the write   ;
;   syscall.                                                                                      ;
;=================================================================================================;
print_string:
    ;---------------------------------------------------------------------------------------------;
    ; Initialize stack frame                                                                      ;
    ;---------------------------------------------------------------------------------------------;
    push rbp                         ; Save old base pointer
    mov rbp, rsp                     ; Establish a new base pointer

    ;---------------------------------------------------------------------------------------------;
    ; Backup registers to temporary registers (r8, r9)                                            ;
    ;---------------------------------------------------------------------------------------------;
    mov r8, rdi                      ; Save string address (RDI) into r8
    mov r9, rsi                      ; Save string length (RSI) into r9

    ;---------------------------------------------------------------------------------------------;
    ; Setup the write syscall: write(1, string_address, string_length)                            ;
    ;---------------------------------------------------------------------------------------------;
    mov rax, 1                       ; rax <- 1 : 'write' syscall number
    mov rdi, 1                       ; rdi <- 1 : file descriptor (stdout)
    mov rsi, r8                      ; rsi <- r8 : address of the string to print
    mov rdx, r9                      ; rdx <- r9 : length of the string to print
    syscall                          ; Make syscall to write to stdout

    ;---------------------------------------------------------------------------------------------;
    ; Cleanup stack frame and return                                                              ;
    ;---------------------------------------------------------------------------------------------;
    mov rsp, rbp                     ; Restore stack pointer
    pop rbp                          ; Restore old base pointer
    ret                              ; Return to caller


;=================================================================================================;
; Function Name: print_newline                                                                    ;
;-------------------------------------------------------------------------------------------------;
; Arguments:                                                                                      ;
;   - None (uses the lf character from data section).                                             ;
;-------------------------------------------------------------------------------------------------;
; Description:                                                                                    ;
;   Prints a single newline character (LF) to stdout (file descriptor 1).                         ;
;=================================================================================================;
print_newline:
    ;---------------------------------------------------------------------------------------------;
    ; Initialize stack frame                                                                      ;
    ;---------------------------------------------------------------------------------------------;
    push rbp                         ; Save old base pointer
    mov rbp, rsp                     ; Establish a new base pointer

    ;---------------------------------------------------------------------------------------------;
    ; Setup the write syscall for a single LF: write(1, lf, 1)                                    ;
    ;---------------------------------------------------------------------------------------------;
    mov rax, 1                       ; rax <- 1 : 'write' syscall number
    mov rdi, 1                       ; rdi <- 1 : file descriptor (stdout)
    mov rsi, lf                      ; rsi <- lf : address of the LF character in data section
    mov rdx, 1                       ; rdx <- 1 : number of bytes to write
    syscall                          ; Make syscall to write to stdout

    ;---------------------------------------------------------------------------------------------;
    ; Cleanup stack frame and return                                                              ;
    ;---------------------------------------------------------------------------------------------;
    mov rsp, rbp                     ; Restore stack pointer
    pop rbp                          ; Restore old base pointer
    ret                              ; Return to caller