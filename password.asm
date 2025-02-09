extern enter_code_msg
extern enter_code_msg_len
extern err_code_format_msg
extern err_code_format_msg_len
extern correct_code
extern print_string
extern print_newline
extern error_invalid_code_format
extern strlen_z
extern read_line_and_trim

global validate_4_digit_code

SECTION .bss
pw_buffer resb 32

SECTION .text

validate_4_digit_code:
    push rbp
    mov rbp, rsp
    push rbx

.ask_again:
    mov rdi, enter_code_msg
    mov rsi, enter_code_msg_len
    call print_string
    mov rdi, pw_buffer
    mov rsi, 32
    call read_line_and_trim
    cmp rax, 1
    jl .format_error
    mov rdi, pw_buffer
    call strlen_z
    cmp rax, 4
    jne .format_error
    xor rbx, rbx
.digit_loop:
    cmp rbx, 4
    jge .compare
    mov dl, [pw_buffer + rbx]
    cmp dl, '0'
    jb .format_error
    cmp dl, '9'
    ja .format_error
    inc rbx
    jmp .digit_loop

.compare:
    mov rdi, pw_buffer
    mov rsi, correct_code
    mov rcx, 4
    repe cmpsb
    jne .no_match
    mov rax, 1
    jmp .done

.no_match:
    mov rax, 0
    jmp .done

.format_error:
    call error_invalid_code_format
    jmp .ask_again

.done:
    pop rbx
    mov rsp, rbp
    pop rbp
    ret

SECTION .note.GNU-stack noalloc noexec nowrite progbits