global read_line_and_trim
global strlen_z
global convert_s64_to_string
global print_signed_64_in_parens

extern print_string

SECTION .text
read_line_and_trim:
    push rbp
    mov rbp, rsp
    sub rsp, 8
    push rbx
    mov r8, rdi
    mov r9, rsi
    mov rcx, r9
    dec rcx
    mov rax, 0
    mov rdi, 0
    mov rsi, r8
    mov rdx, rcx
    syscall
    cmp rax, 1
    jl .done_zero
    mov rcx, rax
    xor rbx, rbx

.trim_loop:
    cmp rbx, rcx
    jge .finish_trim
    mov dl, [r8 + rbx]
    cmp dl, 10
    je .store_zero
    cmp dl, 13
    je .store_zero
    inc rbx
    jmp .trim_loop

.store_zero:
    mov byte [r8 + rbx], 0

.finish_trim:
    cmp rax, rcx
    jb .done

    mov byte [r8 + rcx], 0

.done:
    mov rax, rcx
    jmp .end_func

.done_zero:
    mov byte [r8], 0
    xor rax, rax

.end_func:
    pop rbx
    add rsp, 8
    mov rsp, rbp
    pop rbp
    ret

strlen_z:
    push rbp
    mov rbp, rsp
    xor rax, rax

.len_loop:
    mov dl, [rdi + rax]
    cmp dl, 0
    je .done
    inc rax
    jmp .len_loop

.done:
    mov rsp, rbp
    pop rbp
    ret

convert_s64_to_string:
    push rbp
    mov rbp, rsp
    sub rsp, 16
    mov r8, rsi
    mov rax, r8
    cmp r8, 0
    jge .abs_ok
    neg rax

.abs_ok:
    mov rbx, rdi
    add rbx, 63
    mov byte [rbx], 0
    mov rsi, rbx
    cmp rax, 0
    jne .digit_loop
    mov byte [rsi - 1], '0'
    lea rsi, [rsi - 1]
    jmp .done_digits

.digit_loop:
    xor rdx, rdx
    mov rcx, 10
    div rcx
    add rdx, '0'
    dec rsi
    mov [rsi], dl
    cmp rax, 0
    jne .digit_loop

.done_digits:
    push rsi
    push rdi

.copy_loop:
    mov al, [rsi]
    mov [rdi], al
    inc rsi
    inc rdi
    cmp al, 0
    jne .copy_loop
    pop rdi
    pop rsi
    mov rax, r8
    add rsp, 16
    mov rsp, rbp
    pop rbp
    ret

print_signed_64_in_parens:
    push rbp
    mov rbp, rsp
    sub rsp, 128
    mov [rbp - 8], rdi
    lea rdi, [rbp - 64]
    mov rsi, [rbp - 8]
    call convert_s64_to_string
    cmp rax, 0
    jl .print_negative
    lea rdi, [rbp - 64]
    call strlen_z
    mov rsi, rax
    lea rdi, [rbp - 64]
    call print_string
    jmp .done

.print_negative:
    mov rdi, paren_open_str
    mov rsi, paren_open_str_len
    call print_string
    mov rdi, minus_sign_str
    mov rsi, minus_sign_str_len
    call print_string
    lea rdi, [rbp - 64]
    call strlen_z
    mov rsi, rax
    lea rdi, [rbp - 64]
    call print_string
    mov rdi, paren_close_str
    mov rsi, paren_close_str_len
    call print_string

.done:
    add rsp, 128
    mov rsp, rbp
    pop rbp
    ret

SECTION .rodata
paren_open_str       db "(",0
paren_open_str_len   equ $ - paren_open_str
paren_close_str      db ")",0
paren_close_str_len  equ $ - paren_close_str
minus_sign_str       db "-",0
minus_sign_str_len   equ $ - minus_sign_str

SECTION .note.GNU-stack noalloc noexec nowrite progbit