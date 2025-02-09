extern err_incorrect_code_msg
extern err_incorrect_code_msg_len
extern err_code_format_msg
extern err_code_format_msg_len
extern err_no_attempts_left_msg
extern err_no_attempts_left_msg_len
extern print_string
extern print_newline

global error_incorrect_code
global error_invalid_code_format
global error_exit_no_attempts_left

SECTION .text

error_incorrect_code:
    push rbp
    mov rbp, rsp
    mov rdi, err_incorrect_code_msg
    mov rsi, err_incorrect_code_msg_len
    call print_string
    call print_newline
    mov rsp, rbp
    pop rbp
    ret

error_invalid_code_format:
    push rbp
    mov rbp, rsp
    mov rdi, err_code_format_msg
    mov rsi, err_code_format_msg_len
    call print_string
    call print_newline
    mov rsp, rbp
    pop rbp
    ret

error_exit_no_attempts_left:
    push rbp
    mov rbp, rsp
    mov rdi, err_no_attempts_left_msg
    mov rsi, err_no_attempts_left_msg_len
    call print_string
    call print_newline
    mov rax, 60
    xor rdi, rdi
    syscall

SECTION .note.GNU-stack noalloc noexec nowrite progbits