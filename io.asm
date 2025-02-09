global read_char
global print_string
global print_newline

SECTION .data
lf db 10

SECTION .text

read_char:
    push rbp
    mov rbp, rsp
    mov rax, 0
    mov rdi, 0
    mov rsi, rdx
    mov rdx, 1
    syscall
    mov rsp, rbp
    pop rbp
    ret

print_string:
    push rbp
    mov rbp, rsp
    mov r8, rdi
    mov r9, rsi
    mov rax, 1
    mov rdi, 1
    mov rsi, r8
    mov rdx, r9
    syscall
    mov rsp, rbp
    pop rbp
    ret

print_newline:
    push rbp
    mov rbp, rsp
    mov rax, 1
    mov rdi, 1
    mov rsi, lf
    mov rdx, 1
    syscall
    mov rsp, rbp
    pop rbp
    ret

SECTION .note.GNU-stack noalloc noexec nowrite progbits