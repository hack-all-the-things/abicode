# ABI="ELF32"
# compile : gcc -fstack-protector-all -s -Wl,-z,relro,-z,now -fPIE elf32-full-interp-basefinder.s -o elf32-full-interp-basefinder
# Works with or without the above compile options.
.text
.global main

main:
  mov 0x80480bc, %ebx   # move pointer to _DYNAMIC_ into ebx
  push %ebx
  pop %esi              # copy ptr to esi


find_got:               # loop until the GOT is found
  lodsl
  cmp %ebx, %eax
  jne find_got


find_debug:             # loop backwards until a pointer
  xchg %ebx, %esi       # to GOT is found
  sub $0x4, %ebx

find_debug_loop:
  lodsl
  cmp %ebx, %eax
  jne find_debug_loop


found_debug:
  mov -0xc(%esi), %eax  # Grab the entry in the symbol table 
                        # before GOT (r_debug)

get_interp_base:        # move the fifth pointer in DEBUG
  mov 0x10(%eax), %ebx  # into ebx - ptr to ld-linux base
