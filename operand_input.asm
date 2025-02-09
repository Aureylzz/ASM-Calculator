extern print_string
extern print_newline
extern invalid_operand_msg
extern invalid_operand_msg_len
extern read_line_and_trim

global read_valid_operand

SECTION .bss
operand_buffer resb 64

SECTION .text

read_valid_operand:
    push rbp
    mov rbp, rsp
    sub rsp, 16
    mov [rbp-8], rdi
    mov [rbp-16], rsi

.read_loop:
    mov rdi, [rbp-8]
    mov rsi, [rbp-16]
    call print_string
    mov rdi, operand_buffer
    mov rsi, 64
    call read_line_and_trim
    call parse_and_validate_integer
    jc .invalid_input
    jmp .done

.invalid_input:
    mov rdi, invalid_operand_msg
    mov rsi, invalid_operand_msg_len
    call print_string
    call print_newline
    jmp .read_loop

.done:
    add rsp, 16
    mov rsp, rbp
    pop rbp
    ret

parse_and_validate_integer:
    push rbp
    mov rbp, rsp
    mov r8, 1
    lea r9, [operand_buffer]
    mov al, [r9]
    cmp al, '-'
    jne .skip_minus
    mov r8, -1
    add r9, 1

.skip_minus:
    mov al, [r9]
    cmp al, 0
    je .invalid
    xor rax, rax

.convert_loop:
    mov dl, [r9]
    cmp dl, 0
    je .apply_sign
    cmp dl, '0'
    jb .invalid
    cmp dl, '9'
    ja .invalid
    imul rax, rax, 10
    sub dl, '0'
    movzx rdx, dl
    add rax, rdx
    add r9, 1
    jmp .convert_loop

.apply_sign:
    cmp r8, 1
    je .check_bounds
    neg rax

.check_bounds:
    mov r10, 1000000000
    cmp rax, r10
    jg .invalid
    neg r10
    cmp rax, r10
    jl .invalid
    clc
    jmp .done

.invalid:
    stc

.done:
    mov rsp, rbp
    pop rbp
    ret

SECTION .note.GNU-stack noalloc noexec nowrite progbits