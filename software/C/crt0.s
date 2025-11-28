    .section .text
    .globl _start
    .extern _stack_top

    # Per-thread stack size in bytes
    .equ STACK_SIZE, 128     # 128 bytes per thread

_start:
    # a0 := hartid
    csrr    a0, mhartid

    # t0 := &_stack_top
    la      t0, _stack_top

    # Limit to 4 threads (NUM_THREADS = 4): local_hart = hartid & 0x3
    andi    t1, a0, 0x3      # t1 := local_hart (uses valid RV32E temp)

    # t2 := local_hart * STACK_SIZE = local_hart << 7  (since STACK_SIZE = 128)
    slli    t2, t1, 7

    # sp := _stack_top - t2
    sub     sp, t0, t2

    # Call main(hartid=a0)
    jal     ra, main



