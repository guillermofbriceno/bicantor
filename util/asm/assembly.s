.globl __start
.rodata
.text

__start:
        li       t0, 0x5
loop:
        addi     t1, t1, 0x1
        #jalr     sp, t0, 0
        blt      t1, t0,loop
        
        #li      t0, 0xDEADBEEF
        #li      t1, 0xAAAABBBB
        #li      t2, 0xCCCCDDDD
        #li      t3, 0xEEEEFFFF

        #li      t1, 0x1
        #add     t2, t0, t1
        #add     t3, t0, t1
        #auipc   t4, 0x4
        #bne     zero, t0, __start

        #li      t0, 0x9999
        #li      t1, 0xBEEF
