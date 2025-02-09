;-------------------------------------------------------------------------------------------------;
; Filename: globals.asm                                                                           ;
;-------------------------------------------------------------------------------------------------;
; Author: Aureylz                                                                                 ;
; Creation Date: 2025-02-09                                                                       ;
;                                                                                                 ;
; Description:                                                                                    ;
;   Contains all global data definitions (strings, messages, constants) used across the program,  ;
;   such as the correct password code, menu text, and various error strings.                      ;
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
global correct_code

global enter_code_msg
global enter_code_msg_len

global err_incorrect_code_msg
global err_incorrect_code_msg_len

global err_no_attempts_left_msg
global err_no_attempts_left_msg_len

global err_code_format_msg
global err_code_format_msg_len

global attempts_left_msg
global attempts_left_msg_len

global welcome_msg
global welcome_msg_len

global menu_title_msg
global menu_title_msg_len

global menu_option1_msg
global menu_option1_msg_len

global menu_option2_msg
global menu_option2_msg_len

global menu_option3_msg
global menu_option3_msg_len

global menu_option4_msg
global menu_option4_msg_len

global menu_option5_msg
global menu_option5_msg_len

global menu_ask_choice_msg
global menu_ask_choice_msg_len

global menu_invalid_choice_msg
global menu_invalid_choice_msg_len

global menu_goodbye_msg
global menu_goodbye_msg_len

global invalid_operand_msg
global invalid_operand_msg_len

global prompt_first_operand_msg
global prompt_first_operand_msg_len

global prompt_second_operand_msg
global prompt_second_operand_msg_len



;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~;
;                                           RODATA SECTION                                        ;
;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~;
SECTION .rodata


; This string holds the 4-digit code required to unlock the calculator.
;--------------------------------------------------------------------------------------------------
correct_code db "8888"


; Prompt displayed to the user to enter the 4-digit code.
;--------------------------------------------------------------------------------------------------
enter_code_msg db "Enter the 4-digit code: ",0
enter_code_msg_len equ $ - enter_code_msg


; Error message shown when the user enters a wrong code.
;--------------------------------------------------------------------------------------------------
err_incorrect_code_msg db "Incorrect code.",0
err_incorrect_code_msg_len equ $ - err_incorrect_code_msg
                               
; Error message displayed when the user has exhausted all their attempts.
;--------------------------------------------------------------------------------------------------
err_no_attempts_left_msg db "No attempts left.",0
err_no_attempts_left_msg_len equ $ - err_no_attempts_left_msg


; Error message shown when the code the user entered is not exactly 4 digits.
;--------------------------------------------------------------------------------------------------
err_code_format_msg db "The code can only contain digits, exactly 4 of them.",10,0
err_code_format_msg_len equ $ - err_code_format_msg


; Message displayed to show how many attempts remain to unlock the calculator.
;--------------------------------------------------------------------------------------------------
attempts_left_msg db "Attempts left: ",0
attempts_left_msg_len equ $ - attempts_left_msg


; Welcome message displayed upon successful unlock of the calculator.
;--------------------------------------------------------------------------------------------------
welcome_msg db "Access granted. Welcome to the ASM calculator.",0
welcome_msg_len equ $ - welcome_msg


; Title/heading message displayed at the beginning of the menu.
;--------------------------------------------------------------------------------------------------
menu_title_msg db "Please choose one of the following options:",10,0
menu_title_msg_len equ $ - menu_title_msg


; Menu option 1 text: "Perform an addition".
;--------------------------------------------------------------------------------------------------
menu_option1_msg db "1. Perform an addition",10,0
menu_option1_msg_len equ $ - menu_option1_msg


; Menu option 2 text: "Perform a subtraction".
;--------------------------------------------------------------------------------------------------
menu_option2_msg db "2. Perform a subtraction",10,0
menu_option2_msg_len equ $ - menu_option2_msg


; Menu option 3 text: "Perform a multiplication".
;--------------------------------------------------------------------------------------------------
menu_option3_msg db "3. Perform a multiplication",10,0
menu_option3_msg_len equ $ - menu_option3_msg


; Menu option 4 text: "Perform a division".
;--------------------------------------------------------------------------------------------------
menu_option4_msg db "4. Perform a division",10,0
menu_option4_msg_len equ $ - menu_option4_msg


; Menu option 5 text: "Quit the calculator".
;--------------------------------------------------------------------------------------------------
menu_option5_msg db "5. Quit the calculator",10,0
menu_option5_msg_len equ $ - menu_option5_msg


; Prompt displayed to the user asking which menu option they want to pick.
;--------------------------------------------------------------------------------------------------
menu_ask_choice_msg db "What is your choice ? ",0
menu_ask_choice_msg_len equ $ - menu_ask_choice_msg


; Error message displayed when the user picks an invalid menu option.
;--------------------------------------------------------------------------------------------------
menu_invalid_choice_msg db "Wrong choice! Please choose between 1 and 5...",10,0
menu_invalid_choice_msg_len equ $ - menu_invalid_choice_msg


; Message displayed upon leaving the calculator.
;--------------------------------------------------------------------------------------------------
menu_goodbye_msg db "Thank you for using this calculator, see you soon.",0
menu_goodbye_msg_len equ $ - menu_goodbye_msg


; Error message displayed when the user inputs an operand not within valid numeric ranges or not in
; the correct format.
;--------------------------------------------------------------------------------------------------
invalid_operand_msg db "Invalid value. The operand must be a digital value contained between ",0
                    db "-1000000000 and 1000000000",10,0
invalid_operand_msg_len equ $ - invalid_operand_msg


; Prompt displayed when the user is asked for the first operand in an operation.
;--------------------------------------------------------------------------------------------------
prompt_first_operand_msg db "Type your first operand: ",0
prompt_first_operand_msg_len equ $ - prompt_first_operand_msg


; Prompt displayed when the user is asked for the second operand in an operation.
;--------------------------------------------------------------------------------------------------
prompt_second_operand_msg db "Type your second operand: ",0
prompt_second_operand_msg_len equ $ - prompt_second_operand_msg


;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~;
;                                 NOTE SECTION FOR GNU STACK                                      ;
;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~;
SECTION .note.GNU-stack noalloc noexec nowrite progbits