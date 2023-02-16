led.bin : led.s
#“-g”选项是产生调试信息; “-c”选项是编译源文件，但是不链接。“-o”选项是指定编译产生的文件名字
	arm-linux-gnueabihf-gcc -g -c led.s -o led.o 
#向SD卡中烧录文件以后，启动设备，I.MX6U 的内部 boot rom 程序会将可执行文件拷贝到链接地址处
#这个链接地址可以在 I.MX6U 的内部 128KB RAM 中 (0X900000~0X91FFFF)，也可以在外部的 DDR 中
#本教程所有裸机例程的链接地址都在 DDR 中，链接起始地址为 0X87800000
#.elf文件: 带有各种头部信息的bin文件，可用来反汇编
#arm-linux-gnueabihf-ld 用来将众多的.o 文件链接到一个指定的链接位置
#-Ttext 就是指定链接地址，“-o”选项指定链接生成的 elf文件名
	arm-linux-gnueabihf-ld -Ttext 0x87800000 led.o -o led.elf
#arm-linux-gnueabihf-objcopy 更像一个格式转换工具，我们需要用它将 led.elf 文件转换为led.bin 文件
#“-O”选项指定以什么格式输出，后面的“binary”表示以二进制格式输出，“-S”表示不要复制源文件中的重定位信息和符号信息，
#“-g”表示不复制源文件中的调试信息
	arm-linux-gnueabihf-objcopy -O binary -S -g led.elf led.bin
#将 elf文件反汇编, “-D”选项表示反汇编所有的段（.dis反汇编文件）
	arm-linux-gnueabihf-objdump -D led.elf > led.dis

clean:
	rm -rf *.o led.bin led.elf led.dis

#向 SD卡烧写 bin文件： ./imxdownload led.bin /dev/sdb
