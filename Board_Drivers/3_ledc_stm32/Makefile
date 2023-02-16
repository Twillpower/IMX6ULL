objs 	:= start.o main.o
ld 		:= arm-linux-gnueabihf-ld
gcc 	:= arm-linux-gnueabihf-gcc
objcopy	:= arm-linux-gnueabihf-objcopy
objdump := arm-linux-gnueabihf-objdump

ledc.bin : $(objs)
#$^所有依赖文件的集合，使用空格分开，如果在依赖文件中有多个重复的文件， 
#“$^”会去除重复的依赖文件，值保留一份。
#向SD卡中烧录文件以后，启动设备，I.MX6U 的内部 boot rom 程序会将可执行文件拷贝到链接地址处
#这个链接地址可以在 I.MX6U 的内部 128KB RAM 中 (0X900000~0X91FFFF)，也可以在外部的 DDR 中
#本教程所有裸机例程的链接地址都在 DDR 中，链接起始地址为 0X87800000
#.elf文件: 带有各种头部信息的bin文件，可用来反汇编
#arm-linux-gnueabihf-ld 用来将众多的.o 文件链接到一个指定的链接位置
#-Ttext 就是指定链接地址，“-o”选项指定链接生成的 elf文件名
	$(ld) -Timx6u.lds -o ledc.elf $^ 
#arm-linux-gnueabihf-objcopy 更像一个格式转换工具，我们需要用它将 led.elf 文件转换为led.bin 文件
#“-O”选项指定以什么格式输出，后面的“binary”表示以二进制格式输出，
#“-S”表示不要复制源文件中的重定位信息和符号信息，
#“-g”表示不复制源文件中的调试信息
	$(objcopy) -O binary -S ledc.elf $@
#将 elf文件反汇编, “-D”选项表示反汇编所有的段（.dis反汇编文件）
	$(objdump) -D -m arm ledc.elf > ledc.dis

%.o : %.c
# -Wall表示显示编译的时候所有警告
# -nostdlib表示不链接系统标准启动文件和库文件，否则编译可能会出错
# -O2表示优化等级，和MDK上的设置含义一样
# $@规则中的目标集合，在模式规则中，如果有多个目标的话，“$@”表示匹配模式中定义的目标集合
# $<依赖文件集合中的第一个文件，如果依赖文件是以模式(即“%”)定义的，那么 “$<”就是符合模式的一系列的文件集合。
	$(gcc) -Wall -nostdlib -c -O2 -o $@ $<

%.o : %.s
	$(gcc) -Wall -nostdlib -c -O2 -o $@ $<

clean:
	rm -rf *.o ledc.bin ledc.elf ledc.dis

#向 SD卡烧写 bin文件： ./imxdownload ledc.bin /dev/sdb

