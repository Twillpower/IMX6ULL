/* 链接脚本 */
SECTIONS{
    /* ".”在链接脚本里面叫做定位计数器，默认的定位计数器为 0。 */
    . = 0X87800000;    /* 我们要求代码链接到以 0X87800000 为起始地址的地方 */

    /* “.text”是段名，后面的冒号是语法要求，冒号后面的大括号里面可以填上要链接到“.text”这个段里面的所有文件，
     * “*(.text)”中的“*”是通配符，表示所有输入文件的.text 段都放到“.text”中(即“*(.text)”表示剩下的所有的代码段)
     * 设置链接到开始位置的文件为start.o，start.o 里面包含着第一个要执行的指令，所以一定要链接到最开始的地方
     * main.o 这个文件，其实可以不用写出来，因为main.o 的位置就无所谓了，可以由编译器自行决定链接 位置
     */
    .text :    
    {
        obj/start.o
       /* main.o */
        *(.text)
    }

    /* ALIGN(4)表示 4 字节对齐。也就是说段“.rodata”的起始地址要能被 4 整除 */
    .rodata ALIGN(4) : {*(.rodata*)}

    .data ALIGN(4)   : {*(.data)}

    . = ALIGN(4);
    /* “__bss_start” 和“__bss_end”是符号，
     * 其实就是对这两个符号进行赋值，其值为定位符“.”， 
     * 这两个符号用来保存.bss 段的起始地址和结束地址。
     */
    __bss_start = .;

    /* .bss 段是定义了但是没有被初始化的变量，我们需要手动对.bss 段的变量清零的，
     * 因此我们需要知道.bss 段的起始和结束地址， 这样我们直接对这段内存赋 0 即可完成清零。
     */
    .bss ALIGN(4)    : {*(.bss) *(COMMON)}

    /* .bss 段的起始地址和结束 地址就保存在了“__bss_start”和“__bss_end”中，我们就可以直接在汇编或者 C 文件里面使用这两个符号 */
    __bss_end = .;
}