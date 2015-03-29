# compile: 
# gcc -fstack-protector-all -fPIE -Wl,-z,relro,-z,now -s elf64-full-interp-basefinder.s -o elf64-full-interp-basefinder
# places the imagebase of ld-linux into %rbx.
.section .text
.global main
main:
  push $0x400130ff
  pop %rbx
  shr $0x8, %rbx
  mov (%rbx), %rbx
  mov %rbx, %rsi

find_debug_plt:
  lodsq
  cmp %rax, %rbx
  jne find_debug_plt

find_debug:
  sub $0x8, %rsi
  xchg %rsi, %rbx

find_debug_loop:
  lodsq
  cmp %rbx, %rax
  jne find_debug_loop

found_debug:
  mov -0x18(%rsi), %rax
  mov 0x20(%rax), %rbx
