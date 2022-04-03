.globl __start
.rodata
.text

__start:
        li      t0, 0x10
loop:
        j       tst1
tst0:
        blt     t1, t0, loop
tst1:
        addi    t1, t1, 0x1
        bgt     t1, t0, tst2
        j       tst0
tst2:
        li      t2, 0xDEADBEEF
          
