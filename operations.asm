extern print_string
extern print_newline
extern prompt_first_operand_msg
extern prompt_first_operand_msg_len
extern prompt_second_operand_msg
extern prompt_second_operand_msg_len
extern read_valid_operand

extern print_signed_64_in_parens

global add_numbers
global subtract_numbers
global multiply_numbers
global divide_numbers

SECTION .text
add_numbers:
    push rbp
    mov rbp, rsp
    mov rdi, prompt_first_operand_msg
    mov rsi, prompt_first_operand_msg_len
    call read_valid_operand
    mov r12, rax
    mov rdi, prompt_second_operand_msg
    mov rsi, prompt_second_operand_msg_len
    call read_valid_operand
    mov r13, rax
    mov rax, r12
    add rax, r13
    mov r14, rax
    mov rdi, message_result_str
    mov rsi, message_result_str_len
    call print_string
    mov rdi, r12
    call print_signed_64_in_parens
    mov rdi, message_plus_sign_str
    mov rsi, message_plus_sign_str_len
    call print_string
    mov rdi, r13
    call print_signed_64_in_parens
    mov rdi, message_equal_sign_str
    mov rsi, message_equal_sign_str_len
    call print_string
    mov rdi, r14
    call print_signed_64_in_parens
    call print_newline
    call print_newline
    mov rsp, rbp
    pop rbp
    ret

subtract_numbers:
    push rbp
    mov rbp, rsp
    mov rdi, prompt_first_operand_msg
    mov rsi, prompt_first_operand_msg_len
    call read_valid_operand
    mov r12, rax
    mov rdi, prompt_second_operand_msg
    mov rsi, prompt_second_operand_msg_len
    call read_valid_operand
    mov r13, rax
    mov rax, r12
    sub rax, r13
    mov r14, rax
    mov rdi, message_result_str
    mov rsi, message_result_str_len
    call print_string
    mov rdi, r12
    call print_signed_64_in_parens
    mov rdi, message_minus_sign_str
    mov rsi, message_minus_sign_str_len
    call print_string
    mov rdi, r13
    call print_signed_64_in_parens
    mov rdi, message_equal_sign_str
    mov rsi, message_equal_sign_str_len
    call print_string
    mov rdi, r14
    call print_signed_64_in_parens
    call print_newline
    call print_newline
    mov rsp, rbp
    pop rbp
    ret

multiply_numbers:
    push rbp
    mov rbp, rsp
    mov rdi, prompt_first_operand_msg
    mov rsi, prompt_first_operand_msg_len
    call read_valid_operand
    mov r12, rax
    mov rdi, prompt_second_operand_msg
    mov rsi, prompt_second_operand_msg_len
    call read_valid_operand
    mov r13, rax
    mov rax, r12
    imul rax, r13
    mov r14, rax
    mov rdi, message_result_str
    mov rsi, message_result_str_len
    call print_string
    mov rdi, r12
    call print_signed_64_in_parens
    mov rdi, message_mult_sign_str
    mov rsi, message_mult_sign_str_len
    call print_string
    mov rdi, r13
    call print_signed_64_in_parens
    mov rdi, message_equal_sign_str
    mov rsi, message_equal_sign_str_len
    call print_string
    mov rdi, r14
    call print_signed_64_in_parens
    call print_newline
    call print_newline
    mov rsp, rbp
    pop rbp
    ret

divide_numbers:
    push rbp
    mov rbp, rsp
    mov rdi, prompt_first_operand_msg
    mov rsi, prompt_first_operand_msg_len
    call read_valid_operand
    mov r12, rax
    mov rdi, prompt_second_operand_msg
    mov rsi, prompt_second_operand_msg_len
    call read_valid_operand
    mov r13, rax
    cmp r13, 0
    je .div_by_zero
    mov rax, r12
    cqo
    idiv r13
    mov r14, rax
    mov r15, rdx
    mov rdi, message_result_str
    mov rsi, message_result_str_len
    call print_string
    mov rdi, r12
    call print_signed_64_in_parens
    mov rdi, message_div_sign_str
    mov rsi, message_div_sign_str_len
    call print_string
    mov rdi, r13
    call print_signed_64_in_parens
    mov rdi, message_equal_sign_str
    mov rsi, message_equal_sign_str_len
    call print_string
    mov rdi, r14
    call print_signed_64_in_parens
    cmp r15, 0
    je .done
    mov rdi, message_with_rest_str
    mov rsi, message_with_rest_str_len
    call print_string
    mov rdi, r15
    call print_signed_64_in_parens

.done:
    call print_newline
    call print_newline
    jmp .finish

.div_by_zero:
    mov rdi, message_div_zero_str
    mov rsi, message_div_zero_str_len
    call print_string
    call print_newline
    call print_newline

.finish:
    mov rsp, rbp
    pop rbp
    ret


SECTION .rodata
message_result_str db "==> RESULT: ",0
message_result_str_len equ $ - message_result_str
message_plus_sign_str db " + ",0
message_plus_sign_str_len equ $ - message_plus_sign_str
message_minus_sign_str db " - ",0
message_minus_sign_str_len equ $ - message_minus_sign_str
message_mult_sign_str db " * ",0
message_mult_sign_str_len  equ $ - message_mult_sign_str
message_div_sign_str db " % ",0
message_div_sign_str_len equ $ - message_div_sign_str
message_equal_sign_str db " = ",0
message_equal_sign_str_len equ $ - message_equal_sign_str
message_with_rest_str db ", with a rest to ",0
message_with_rest_str_len equ $ - message_with_rest_str
message_div_zero_str db "Error: division by zero not allowed",0
message_div_zero_str_len equ $ - message_div_zero_str

SECTION .note.GNU-stack noalloc noexec nowrite progbits