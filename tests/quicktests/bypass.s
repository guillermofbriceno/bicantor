.globl __start
.rodata
.text

__start:
        li      t0, 0x1
        li      t1, 0xDEADBEEF
        add     t2, t0, t1
        add     t3, t1, t2
