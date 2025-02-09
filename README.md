# ASM Calculator - Educational Project

This project is an **educational program** written in **x86-64 Assembly** for Linux. Its purpose is to demonstrate how to structure a multi-file assembly project, build a rudimentary calculator (with addition, subtraction, multiplication, division), and implement password-based protection.  

> Note that the default password is 8888.

**Table of Contents**
1. [Overview](#overview)  
2. [Features](#features)  
3. [Architecture](#architecture)  
4. [Assembly Instructions Used](#assembly-instructions-used)  
5. [Registers Usage Table](#registers-usage-table)  
6. [Dependencies & Setup](#dependencies--setup)  
7. [Compilation & Execution](#compilation--execution)  
8. [Usage Instructions](#usage-instructions)  
9. [License](#license)


## Overview

This program asks the user to enter a **4-digit unlock code** before giving access to a calculator that can perform:
- Addition
- Subtraction
- Multiplication
- Division

If the correct code is entered, the user sees a welcome message and can use the calculator’s menu. If they enter the wrong code multiple times, the program eventually exits. 

It includes:
- **Validation** of the password.
- **Validation** of user inputs (operand ranges).
- **Menus** that allow repeated operations until the user chooses to quit.
- **Custom Functions** for each arithmetic operation and for handling input/output.


## Features

1. **Password Protection**  
   - The user is prompted for a 4-digit code.  
   - The code must be exactly 4 digits, all numeric.  
   - Incorrect attempts lead to error messages, and after the maximum tries, the program exits.

2. **Calculator Menu**  
   - A textual menu with options to **Add**, **Subtract**, **Multiply**, **Divide**, or **Quit**.  
   - After choosing an operation, the user is asked for two operands (validated to be within `[-1000000000, 1000000000]`).

3. **Operand Validation**  
   - Input is checked to ensure it is numeric and within valid bounds.  
   - If the user enters something invalid, they are re-prompted.

4. **Error Handling**  
   - Detailed error messages for wrong code, invalid code format, out-of-range operands, or zero division.

5. **Clean Project Structure**  
   - Multiple assembly files grouped by functionality (I/O, menu, operations, etc.).  
   - Clearly commented code following the x86-64 SysV ABI calling convention.


## Architecture

The project is split into several **.asm** files, each with a specific role:

1. **`main.asm`**  
   - The main entry point. It initializes the number of password attempts, prompts for the password, and if successful, calls the main menu.

2. **`password.asm`**  
   - Contains the function `validate_4_digit_code` which verifies the user’s input against the correct password. Checks length, digits only, etc.

3. **`menu.asm`**  
   - Shows the text-based menu, reads the user’s choice, and calls the appropriate arithmetic operation or quits.

4. **`operations.asm`**  
   - Implements `add_numbers`, `subtract_numbers`, `multiply_numbers`, and `divide_numbers`.  
   - Each function prompts for two operands, performs the calculation, and prints the formatted result.

5. **`operand_input.asm`**  
   - Provides `read_valid_operand`, which repeatedly prompts the user until a valid integer is entered.  
   - Also includes a helper function to parse the string into a 64-bit integer within range.

6. **`errors.asm`**  
   - Contains error-handling routines (e.g., for incorrect code, exit with no attempts left).

7. **`io.asm`**  
   - Simple routines to read a single char (`read_char`) and to print strings or newlines.

8. **`utils.asm`**  
   - Provides utilities such as `read_line_and_trim`, `strlen_z`, integer-to-string conversion, and printing signed 64-bit integers with optional parentheses.

9. **`globals.asm`**  
   - Holds constants (strings, messages, correct code) in the read-only data section.

10. **`Makefile`**  
    - Defines how to assemble and link all modules into the final executable.


## Assembly Instructions Used

Below is a table of some key assembly instructions and their usage within the project:

| Instruction               | Description / Usage                                                                                                    |
|---------------------------|------------------------------------------------------------------------------------------------------------------------|
| **`mov`**                 | Moves data between registers or between memory and registers.                                                          |
| **`push`**                | Pushes a register or memory value onto the stack.                                                                      |
| **`pop`**                 | Pops the top value from the stack into a register.                                                                     |
| **`call`**                | Calls a procedure (function). The return address is pushed onto the stack.                                             |
| **`ret`**                 | Returns from the current procedure (function).                                                                         |
| **`jmp`**                 | Unconditional jump to a label.                                                                                         |
| **`je`**                  | Jump if equal (ZF=1). Used for branching after a compare instruction.                                                  |
| **`jne`**                 | Jump if not equal (ZF=0).                                                                                              |
| **`jb`**, **`ja`**, etc.  | Other conditional jumps used when comparing for out-of-range conditions (digits, code length, etc.).                   |
| **`cmp`**                 | Compares two operands by subtracting them internally and setting flags.                                                |
| **`add`**                 | Adds the source operand to the destination operand (e.g., `add rax, rbx`).                                             |
| **`sub`**                 | Subtracts the source operand from the destination operand (e.g., `sub rax, rbx`).                                      |
| **`imul`**                | Signed multiplication instruction. (e.g., `imul rax, rdx`).                                                            |
| **`idiv`**                | Signed division. Divides the combined `RDX:RAX` by a register operand, placing quotient in RAX and remainder in RDX.   |
| **`cqo`**                 | Sign-extends RAX into RDX, used before `idiv` for signed division.                                                     |
| **`xor`**                 | Bitwise XOR, often used to quickly set a register to 0 (e.g., `xor rax, rax`).                                         |
| **`inc`**, **`dec`**      | Increments/decrements a register by 1.                                                                                 |
| **`jb`**, **`ja`**        | Jump if below, jump if above; often used to check digit ranges.                                                        |
| **`call syscall`**        | In Linux, we load `rax` with the syscall number and use `syscall`. Not used in all files, but present in I/O routines. |



## Registers Usage Table

Below is a simplified register usage overview for the entire project under the **SysV AMD64 ABI**:

| Register                              | Primary Usage in This Project                                                                                 |
|---------------------------------------|---------------------------------------------------------------------------------------------------------------|
| **RAX**                               | Function return register; also used for arithmetic results, system call numbers, etc.                         |
| **RBX**                               | Sometimes used as a loop counter or to store local values. Preserved across function calls.                   |
| **RCX**                               | Used in compare loops, local counters, or leftover 3rd integer operand. Also used by some `rep` instructions. |
| **RDX**                               | Commonly used to hold the remainder in division, or extra arguments.                                          |
| **RSI**                               | 2nd function argument in SysV ABI. Often used for string lengths, buffer sizes, etc.                          |
| **RDI**                               | 1st function argument in SysV ABI. Typically used for string addresses or prompt addresses.                   |
| **RBP**                               | Base pointer for the current stack frame, local variables, saved previous RBP.                                |
| **RSP**                               | Stack pointer. Grows downward on push; moves up on pop. Maintains function call stack.                        |
| **R8**/**R9**/...                     | Additional function arguments (3rd, 4th, etc.) on SysV AMD64. Also used for temporary storage.                |
| **R12**, **R13**, **R14**, **R15**    | Often used in larger arithmetic or to store intermediate results.                                             |


## Dependencies & Setup

1. **Assembler**: [Yasm](http://yasm.tortall.net/) or [NASM](https://www.nasm.us/) for assembling `.asm` files.  
2. **GCC**: A C compiler to link the object files and produce an executable (using `-no-pie` for classic linking).  
3. **Linux environment**: The code relies on Linux syscall conventions.

Make sure you have them installed:
```bash
sudo apt-get update
sudo apt-get install yasm gcc
