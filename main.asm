extern validate_4_digit_code
extern error_incorrect_code
extern error_exit_no_attempts_left
extern attempts_left_msg
extern attempts_left_msg_len
extern print_string
extern print_newline
extern welcome_msg
extern welcome_msg_len
extern show_menu

global main

SECTION .text

main:
    push rbp
    mov rbp, rsp
    mov rbx, 3

.loop_pw:
    call prompt_and_validate_password
    cmp rax, 1
    je .correct
    cmp rax, 0
    je .fail
    jmp .loop_pw

.fail:
    call error_exit_no_attempts_left

.correct:
    mov rdi, welcome_msg
    mov rsi, welcome_msg_len
    call print_string
    call print_newline
    call print_newline
    call show_menu
    mov rax, 60
    xor rdi, rdi
    syscall

prompt_and_validate_password:
    push rbp
    mov rbp, rsp
    call validate_4_digit_code
    cmp rax, 1
    je .correct_code
    dec rbx
    cmp rbx, 0
    je .no_more
    call error_incorrect_code
    mov rdi, attempts_left_msg
    mov rsi, attempts_left_msg_len
    call print_string
    mov rcx, rbx
    add rcx, '0'
    mov rax, 1
    mov rdi, 1
    push rcx
    mov rsi, rsp
    mov rdx, 1
    syscall
    add rsp, 8
    call print_newline
    call print_newline
    mov rax, 2
    jmp .done

.correct_code:
    mov rax, 1
    jmp .done

.no_more:
    mov rax, 0

.done:
    mov rsp, rbp
    pop rbp
    ret

SECTION .note.GNU-stack noalloc noexec nowrite progbits