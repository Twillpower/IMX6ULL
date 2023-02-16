.global _start
/* 相当于定义_bss_start变量，使其等于__bss_start */
.global _bss_start
_bss_start:
    .word __bss_start

.global _bss_end
_bss_end:
    .word __bss_end

_start:
    /* 设置处理器进入SVC模式(超级管理员模式，特权模式，供操作系统使用): 
     * 即设置程序状态寄存器CPSR的位[4:0]为10011 = 0x13
     */

    /* MRS 指令用于将特殊寄存器中的数据传递给通用寄存器 */
    mrs r0, cpsr    /* 读取cpsr到r0 */   

    /* BIC: 位清除(将要清除的位置一)
     * 指令: BIC Rd, Rn, #immed
     * 计算公式: Rd = Rn & (~#immed)
     */
    bic r0, r0, #0x1f    @[4:0]位置一: 要清除的数据为后五位，即11111 = 0x1f

    /* ORR: 按位或
     * 指令: ORR Rd, Rn, #immed
     * 计算公式: Rd = Rn | #immed
     */
    orr r0, r0, #0x13    @使用SVC模式

    /* MSR指令用来将普通寄存器的数据传递给特殊寄存器 */
    msr cpsr, r0    @将r0写入到cpsr

    /* 清除BSS段 */
    ldr r0, _bss_start
    ldr r1, _bss_end
    mov r2, #0

bss_loop:
/* 将r2的值保存到r0指向的存储单元中(r0自动加1) */
    stmia r0!, {r2}
    cmp r0, r1    /* 比较r0和r1里面的值 */
    ble bss_loop    /* b: 跳转； le：r0 <= r1; 即当r0 <= r1, 则跳转到bss_loop */

    /* 设置SP指针 */
    /* 注：使用其他处理器，要看他的启动方式，若此处理器无法初始化DDR，则必须手动初始化在设置 */
    ldr sp, =0x80200000
    b main    @跳转到c语言main函数
