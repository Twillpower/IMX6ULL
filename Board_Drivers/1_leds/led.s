.global _start @全局标号

_start:
    /* 使能所有外设时钟 */
    ldr r0, =0x020c4068   @ r0存放CCGR0(时钟寄存器)基地址
    ldr r1, = 0xffffffff  @向CCGR0写入的数据
    str r1, [r0]          @将0xffffffff写入CCGR0, 使能CCGR0控制的所有外设时钟 

    ldr r0, =0x020c406c   @ CCGR1基地址，一个寄存器32位，共4字节，所以在CCGR0的基地址上加4
    str r1, [r0]

    ldr r0, =0x020c4070   @ CCGR2
    str r1, [r0]

    ldr r0, =0x020c4074   @ CCGR3
    str r1, [r0]

    ldr r0, =0x020c4078   @ CCGR4
    str r1, [r0]

    ldr r0, =0x020c407c   @ CCGR5
    str r1, [r0]

    ldr r0, =0x020c4080   @ CCGR6
    str r1, [r0]

    /* IO复用，将寄存器IOMUXC_SW_MUX_CTL_PAD_GPIO1_IO03的bit3~0设置为0101=5，
     * 这样GPIO1_IO03就复用为GPIO。
     * IOMUXC_SW_MUX_CTL_PAD_GPIO1_IO03寄存器地址为0x020e0068
     */
    ldr r0, =0x020e0068   @IOMUXC_SW_MUX_CTL_PAD_GPIO1_IO03寄存器地址
    ldr r1, = 0x5         @要写入的数据
    str r1, [r0]          @将5写入IOMUXC_SW_MUX_CTL_PAD_GPIO1_IO03中

    /* 寄存器IOMUXC_SW_PAD_CTL_PAD_GPIO1_IO03是设置GPIO1_IO03的电气属性。
     * 包括压摆率、速度、驱动能力、开漏、上下拉等。
     * IOMUXC_SW_PAD_CTL_PAD_GPIO1_IO03寄存器地址为0x020e02f4
     * bit0    (SRE: Slew Rate Field)：               0    低速率(Slow Slew Rate)
     * bit2~1：                                       保留位
     * bit5~3  (DSE: Drive Strength Field):           110  R0/6  驱动能力
     * bit7~6  (SPEED: Speed Field):                  10   100MHz
     * bit10~8:                                       保留位
     * bit11   (ODE: Open Drain Enable Field):        0    关闭开漏输出
     * bit12   (PKE: Pull / Keep Enable Field):       1    使能Pull / Keepper
     * bit13   (PUE: Pull / Keep Select Field):       0    设置为keepper
     * bit15~14(PUS: Pull Up / Down Config. Field):   00   100k下拉
     * bit16   (HYS: Hyst. Enable Field):             0    关闭Hysteresis
     * bit31~17：                                     保留位
     * 汇总：...0001 0000 1011 0000 = 10B0
     */
    ldr r0, =0x020e02f4   
    ldr r1, = 0x000010B0  
    str r1, [r0]          

    /* 配置GPIO功能，设置输入输出。设置GPIO1_IO03为输出
     * 设置GPIO1_GDIR寄存器bit3为1，也就是设置为输出模式。
     * 设置GPIO1_GDIR寄存器的bit3，为1表示输出高电平，为0表示输出低电平。
     * GPIO1_GDIR基地址为0209c004
     */
    ldr r0, =0x0209c004  
    ldr r1, = 0x8  
    str r1, [r0]  

    /* 打开LED0, 也就是设置GPIO1_IO03为0
     * GPIO1_DR寄存器基地址为0209c000
     */
    ldr r0, =0x0209c000 
    ldr r1, =0
    str r1, [r0]  

loop:        @ 相当于c语言中定义函数，函数名随意
    b loop   @ b: 跳转指令，跳转到loop函数，即死循环
