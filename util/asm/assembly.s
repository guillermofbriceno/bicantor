.globl __start
.rodata
.text

__start:
        #addi    t0, zero, 0x9
        #addi    t1, t0, 0x3
        #add     t3, t0, t1

        li      t0, 0xDEADBEEF
        li      t1, 0x1
        add     t3, t0, t1
        add     t4, t0, t1
        bne     zero, t0, __start

        #addi      t0, zero, 0x4
        #nop
        #lui       t1, 1280

        #li      t0, 0x9999
        #li      t1, 0xBEEF
