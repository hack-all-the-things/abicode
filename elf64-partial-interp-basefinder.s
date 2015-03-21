# ABI="ELF64"
# gcc elf64-partial-interp-basefinder.s -o elf64-partial-interp-basefinder
main:             
  # read the dynamic header
  push $0x400130ff
  pop %rbx
  shr $0x08, %ebx          #  %rbx  = 0x400130
                           # (%rbx) = location of dynamic section

skip_to_dynamic:  
  # this is a vma, so 32 bit reg is fine.
  mov (%rbx), %esi         # put dynamic section location into %rsi

fix_dflag:        
  cld                      # make the dflag go forwards...

find_got_plt:     
  # Search past the dynamic section until it finds
  # another pointer to the dynamic section.  This
  # will be the beginning of .got.plt
  lodsl                    # lodsl for magically short searching
  cmpl %eax, (%rbx)        # save a couple bytes because its a vma.
  jne find_got_plt

found_resolver:   
  mov 0xc(%rsi), %rcx      # %rcx = qword pointer to resolver
                           # usually _dl_runtime_resolve (.got.plt[2])

find_base:        
  xor %cl, %cl             # it'll be an address ending in 00
                           # if this doesn't happen, it may also find false bases
                           
  cmpl $0x464c457f, (%rcx) # check for ELF magic
  loopne find_base         # loopne automatically does a dec %rcx

libdl_base_found: 
  # Make %rcx a direct pointer to libdl_base after that,
  # the loop decrements it one too many times.
  inc %rcx
