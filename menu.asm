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

global show_menu

SECTION .bss
choice_buffer resb 32

SECTION .text
show_menu:
    push rbp
    mov rbp, rsp

.menu_loop:
    mov rdi, menu_title_msg
    mov rsi, menu_title_msg_len
    call print_string
    mov rdi, menu_option1_msg
    mov rsi, menu_option1_msg_len
    call print_string
    mov rdi, menu_option2_msg
    mov rsi, menu_option2_msg_len
    call print_string
    mov rdi, menu_option3_msg
    mov rsi, menu_option3_msg_len
    call print_string
    mov rdi, menu_option4_msg
    mov rsi, menu_option4_msg_len
    call print_string
    mov rdi, menu_option5_msg
    mov rsi, menu_option5_msg_len
    call print_string
    call print_newline
    mov rdi, menu_ask_choice_msg
    mov rsi, menu_ask_choice_msg_len
    call print_string
    mov rdi, choice_buffer
    mov rsi, 32
    call read_line_and_trim
    cmp rax, 1
    jl .invalid_choice
    mov rdi, choice_buffer
    call strlen_z
    cmp rax, 1
    jne .invalid_choice
    mov al, [choice_buffer]
    cmp al, '1'
    je .choice_1
    cmp al, '2'
    je .choice_2
    cmp al, '3'
    je .choice_3
    cmp al, '4'
    je .choice_4
    cmp al, '5'
    je .choice_5
    jmp .invalid_choice

.choice_1:
    call print_newline
    call add_numbers
    jmp .menu_loop

.choice_2:
    call print_newline
    call subtract_numbers
    jmp .menu_loop

.choice_3:
    call print_newline
    call multiply_numbers
    jmp .menu_loop

.choice_4:
    call print_newline
    call divide_numbers
    jmp .menu_loop

.choice_5:
    mov rdi, menu_goodbye_msg
    mov rsi, menu_goodbye_msg_len
    call print_string
    call print_newline

    mov rsp, rbp
    pop rbp
    ret

.invalid_choice:
    mov rdi, menu_invalid_choice_msg
    mov rsi, menu_invalid_choice_msg_len
    call print_string
    call print_newline
    jmp .menu_loop

SECTION .note.GNU-stack noalloc noexec nowrite progbits