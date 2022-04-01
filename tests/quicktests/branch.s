.globl __start
.rodata
.text

__start:
        li       t0, 0x5
loop:
        addi     t1, t1, 0x1
        blt      t1, t0,loop
