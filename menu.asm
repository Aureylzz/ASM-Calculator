;-------------------------------------------------------------------------------------------------;
; Filename: menu.asm                                                                              ;
;-------------------------------------------------------------------------------------------------;
; Author: Aureylz                                                                                 ;
; Creation Date: 2025-02-09                                                                       ;
;                                                                                                 ;
; Description:                                                                                    ;
;   Manages the calculator's main menu. Displays available operations (addition, subtraction,     ;
;   multiplication, division) and handles the user's selection by calling the corresponding       ;
;   functions. Also handles the "quit" option.                                                    ;
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
global show_menu

extern print_string
extern print_newline

extern menu_title_msg
extern menu_title_msg_len
extern menu_option1_msg
extern menu_option1_msg_len
extern menu_option2_msg
extern menu_option2_msg_len
extern menu_option3_msg
extern menu_option3_msg_len
extern menu_option4_msg
extern menu_option4_msg_len
extern menu_option5_msg
extern menu_option5_msg_len
extern menu_ask_choice_msg
extern menu_ask_choice_msg_len
extern menu_invalid_choice_msg
extern menu_invalid_choice_msg_len
extern menu_goodbye_msg
extern menu_goodbye_msg_len

extern add_numbers
extern subtract_numbers
extern multiply_numbers
extern divide_numbers

extern read_line_and_trim
extern strlen_z


;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~;
;                                          BSS SECTION                                            ;
;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~;
SECTION .bss

; Holds the user’s menu choice as input (maximum 32 bytes, including null terminator).
;--------------------------------------------------------------------------------------------------
choice_buffer resb 32


;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~;
;                                          TEXT SECTION                                           ;
;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~;
SECTION .text

;=================================================================================================;
; Function Name: show_menu                                                                        ;
;-------------------------------------------------------------------------------------------------;
; Arguments:                                                                                      ;
;   - None (uses external data references and internal calls).                                    ;
;-------------------------------------------------------------------------------------------------;
; Description:                                                                                    ;
;   Displays a menu of operations (add, subtract, multiply, divide, quit). Waits for the user     ;
;   to enter a single choice, validates it, and calls the corresponding function. Continues until ;
;   the user chooses the "quit" option.                                                           ;
;=================================================================================================;
show_menu:
    ;---------------------------------------------------------------------------------------------;
    ; Setup stack frame                                                                           ;
    ;---------------------------------------------------------------------------------------------;
    push rbp
    mov rbp, rsp

.menu_loop:
    ;---------------------------------------------------------------------------------------------;
    ; Print the menu header and each menu option                                                  ;
    ;---------------------------------------------------------------------------------------------;
    mov rdi, menu_title_msg                 ; RDI <- address of the menu title
    mov rsi, menu_title_msg_len             ; RSI <- length of the menu title
    call print_string                       ; Print the menu title

    mov rdi, menu_option1_msg               ; RDI <- address of "1. Perform an addition"
    mov rsi, menu_option1_msg_len           ; RSI <- length of option1 message
    call print_string                       ; Print the option1 message

    mov rdi, menu_option2_msg               ; RDI <- address of "2. Perform a subtraction"
    mov rsi, menu_option2_msg_len           ; RSI <- length of option2 message
    call print_string                       ; Print the option2 message

    mov rdi, menu_option3_msg               ; RDI <- address of "3. Perform a multiplication"
    mov rsi, menu_option3_msg_len           ; RSI <- length of option3 message
    call print_string                       ; Print the option3 message

    mov rdi, menu_option4_msg               ; RDI <- address of "4. Perform a division"
    mov rsi, menu_option4_msg_len           ; RSI <- length of option4 message
    call print_string                       ; Print the option4 message

    mov rdi, menu_option5_msg               ; RDI <- address of "5. Quit the calculator"
    mov rsi, menu_option5_msg_len           ; RSI <- length of option5 message
    call print_string                       ; Print the option5 message

    call print_newline                      ; Print an empty line for spacing

    ;---------------------------------------------------------------------------------------------;
    ; Prompt the user for their choice                                                            ;
    ;---------------------------------------------------------------------------------------------;
    mov rdi, menu_ask_choice_msg            ; RDI <- address of "What is your choice ? "
    mov rsi, menu_ask_choice_msg_len        ; RSI <- length of the choice prompt
    call print_string                       ; Print the choice prompt

    ;---------------------------------------------------------------------------------------------;
    ; Read input from user and store in choice_buffer                                             ;
    ;---------------------------------------------------------------------------------------------;
    mov rdi, choice_buffer                  ; RDI <- buffer address
    mov rsi, 32                             ; RSI <- buffer size
    call read_line_and_trim                 ; Reads user input (up to 31 chars + null)
    cmp rax, 1                              ; Check how many bytes read
    jl .invalid_choice                      ; If less than 1 byte, it's invalid

    ;---------------------------------------------------------------------------------------------;
    ; Ensure the user entered exactly 1 character (plus null terminator)                          ;
    ;---------------------------------------------------------------------------------------------;
    mov rdi, choice_buffer                  ; RDI <- address of user input
    call strlen_z                           ; RAX <- length of the zero-terminated string
    cmp rax, 1                              ; Must be exactly 1 character (plus null)
    jne .invalid_choice                     ; If not exactly 1 character, it's invalid

    ;---------------------------------------------------------------------------------------------;
    ; Check which choice was typed (1,2,3,4,5) and call corresponding function                    ;
    ;---------------------------------------------------------------------------------------------;
    mov al, [choice_buffer]                 ; Load the single char typed by user
    cmp al, '1'                             ; Compare with '1'
    je .choice_1                            ; Jump if choice is '1'
    cmp al, '2'                             ; Compare with '2'
    je .choice_2                            ; Jump if choice is '2'
    cmp al, '3'                             ; Compare with '3'
    je .choice_3                            ; Jump if choice is '3'
    cmp al, '4'                             ; Compare with '4'
    je .choice_4                            ; Jump if choice is '4'
    cmp al, '5'                             ; Compare with '5'
    je .choice_5                            ; Jump if choice is '5'
    jmp .invalid_choice                     ; Otherwise, it's invalid

.choice_1:
    call print_newline                      ; Print a blank line before operation
    call add_numbers                        ; Call the addition routine
    jmp .menu_loop                          ; Loop back to the menu

.choice_2:
    call print_newline                      ; Print a blank line before operation
    call subtract_numbers                   ; Call the subtraction routine
    jmp .menu_loop                          ; Loop back to the menu

.choice_3:
    call print_newline                      ; Print a blank line before operation
    call multiply_numbers                   ; Call the multiplication routine
    jmp .menu_loop                          ; Loop back to the menu

.choice_4:
    call print_newline                      ; Print a blank line before operation
    call divide_numbers                     ; Call the division routine
    jmp .menu_loop                          ; Loop back to the menu

.choice_5:
    ;---------------------------------------------------------------------------------------------;
    ; Print a goodbye message and exit the menu (return to main)                                  ;
    ;---------------------------------------------------------------------------------------------;
    mov rdi, menu_goodbye_msg               ; RDI <- address of goodbye message
    mov rsi, menu_goodbye_msg_len           ; RSI <- length of goodbye message
    call print_string                       ; Print the goodbye message
    call print_newline                      ; Print a newline for spacing

    ;---------------------------------------------------------------------------------------------;
    ; Cleanup stack frame and return                                                              ;
    ;---------------------------------------------------------------------------------------------;
    mov rsp, rbp                            ; Restore stack pointer
    pop rbp                                 ; Restore old base pointer
    ret                                     ; Return to caller

.invalid_choice:
    ;---------------------------------------------------------------------------------------------;
    ; Inform user of invalid choice and jump back to menu loop                                    ;
    ;---------------------------------------------------------------------------------------------;
    mov rdi, menu_invalid_choice_msg        ; RDI <- address of invalid choice message
    mov rsi, menu_invalid_choice_msg_len    ; RSI <- length of invalid choice message
    call print_string                       ; Print the invalid choice message
    call print_newline                      ; Print a newline for spacing
    jmp .menu_loop                          ; Return to menu loop


;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~;
;                                  NOTE SECTION FOR GNU STACK                                     ;
;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~;
SECTION .note.GNU-stack noalloc noexec nowrite progbits