# “:=” : 不会使用后面定义的变量，只能使用前面已经定义好的
# “?=” : curname ?= zuozhongkai : 如果变量 curname 前面没有被赋值，那么此变量就是“zuozhongkai”，
# 如果前面已经赋过值了，那么就使用前面赋的值。
CROSS_COMPILE ?= arm-linux-gnueabihf-
NAME          ?= ledc

# 若CROSS_COMPILE变量在后面改变了，则CC仍然使用前面已经定义好的值
CC 			  := $(CROSS_COMPILE)gcc
#arm-linux-gnueabihf-ld 用来将众多的.o 文件链接到一个指定的链接位置
LD 			  := $(CROSS_COMPILE)ld
#arm-linux-gnueabihf-objcopy 更像一个格式转换工具，我们需要用它将 led.elf 文件转换为led.bin 文件
OBJCOPY		  := $(CROSS_COMPILE)objcopy
#将 elf文件反汇编, “-D”选项表示反汇编所有的段（.dis反汇编文件）
OBJDUMP		  := $(CROSS_COMPILE)objdump

OBJS := start.o main.o

$(NAME).bin : $(OBJS)
#$^所有依赖文件的集合，使用空格分开，如果在依赖文件中有多个重复的文件， 
#“$^”会去除重复的依赖文件，值保留一份。
#向SD卡中烧录文件以后，启动设备，I.MX6U 的内部 boot rom 程序会将可执行文件拷贝到链接地址处
#这个链接地址可以在 I.MX6U 的内部 128KB RAM 中 (0X900000~0X91FFFF)，也可以在外部的 DDR 中
#本教程所有裸机例程的链接地址都在 DDR 中，链接起始地址为 0X87800000
#.elf文件: 带有各种头部信息的bin文件，可用来反汇编
#-Timx6u.lds(链接脚本) 就是指定链接地址，“-o”选项指定链接生成的 elf文件名
	$(LD) -Timx6u.lds -o $(NAME).elf $^
# $@规则中的目标集合，在模式规则中，如果有多个目标的话，“$@”表示匹配模式中定义的目标集合
#“-O”选项指定以什么格式输出，后面的“binary”表示以二进制格式输出，
#“-S”表示不要复制源文件中的重定位信息和符号信息，
#“-g”表示不复制源文件中的调试信息
	$(OBJCOPY) -O binary -S $(NAME).elf $@
	$(OBJDUMP)  -D -m arm $(NAME).elf > $(NAME).dis

%.o : %.c 
# $<依赖文件集合中的第一个文件，如果依赖文件是以模式(即“%”)定义的，那么 “$<”就是符合模式的一系列的文件集合。
# -Wall表示显示编译的时候所有警告
# -nostdlib表示不链接系统标准启动文件和库文件，否则编译可能会出错
# -O2表示优化等级，和MDK上的设置含义一样
	$(CC) -Wall -nostdlib -c -O2 -o $@ $<

%.o : %.s 
	$(CC) -Wall -nostdlib -c -O2 -o $@ $<

clean:
	rm -rf *.o $(NAME).bin $(NAME).elf $(NAME).dis

#向 SD卡烧写 bin文件： ./imxdownload ledc.bin /dev/sdb