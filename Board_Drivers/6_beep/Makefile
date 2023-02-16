# “:=” : 不会使用后面定义的变量，只能使用前面已经定义好的
# “?=” : curname ?= zuozhongkai : 如果变量 curname 前面没有被赋值，那么此变量就是“zuozhongkai”，
# 如果前面已经赋过值了，那么就使用前面赋的值。
CROSS_COMPILE ?= arm-linux-gnueabihf-
TARGET        ?= beep

# 若CROSS_COMPILE变量在后面改变了，则CC仍然使用前面已经定义好的值
CC 			  := $(CROSS_COMPILE)gcc
#arm-linux-gnueabihf-ld 用来将众多的.o 文件链接到一个指定的链接位置
LD 			  := $(CROSS_COMPILE)ld
#arm-linux-gnueabihf-objcopy 更像一个格式转换工具，我们需要用它将 led.elf 文件转换为led.bin 文件
OBJCOPY		  := $(CROSS_COMPILE)objcopy
#将 elf文件反汇编, “-D”选项表示反汇编所有的段（.dis反汇编文件）
OBJDUMP		  := $(CROSS_COMPILE)objdump

# 头文件目录路径
INCUDIRS      := imx6u \
				 bsp/clk \
				 bsp/beep \
				 bsp/led \
				 bsp/delay 

# 源文件目录路径
SRCDIRS 	  := project \
				 bsp/beep \
				 bsp/clk \
				 bsp/led \
				 bsp/delay 

# $(patsubst <pattern>,<replacement>,<text>)
# 名称：模式字符串替换函数——patsubst。 
# 功能：查找<text>中的单词（单词以“空格”、“Tab”或“回车”“换行”分隔）是否符合模式<pattern>，
# 如果匹配的话，则以<replacement>替换。这里，<pattern>可以包括通 配符“%”，表示任意长度的字串。
# 如果<replacement>中也包含“%”，那么，<replacement> 中的这个“%”将是<pattern>中的那个“%”所代表的字串。
#（可以用“\”来转义，以“\%” 来表示真实含义的“%”字符） 
# 返回：函数返回被替换过后的字符串。
# 此处意思为，将$(INCUDIRS)变量中的每个值，前面加上-I
# 返回值为：-I imx6u -I bsp/clk -I bsp/led -I bsp/delay
INCLUDE		  := $(patsubst %, -I %, $(INCUDIRS))

# 让通配符在变量中展开, 需要使用$(wildcard *.o)函数
# $(wildcard $(dir)/*.S)：$(dir)目录下的所有.S文件
# foreach函数是用来做循环用的：语法：$(foreach <var>,<list>,<text>)
# 把参数<list>中的单词逐一取出放到参数<var>所指定的变量中， 然后再执行<text>所包含的表达式。
# 每一次<text>会返回一个字符串，循环过程中，<text> 的所返回的每个字符串会以空格分隔，最后当整个循环结束时，
# <text>所返回的每个字符串所组成的整个字符串（以空格分隔）将会是 foreach 函数的返回值
# 保存此工程下的所有汇编文件
# 从$(SRCDIRS)变量中取出.S文件，放入dir中，当所有变量找完，返回所有变量，赋值给SFILES
# SFILES = project/start.S
SFILES		  := $(foreach dir, $(SRCDIRS),  $(wildcard $(dir)/*.S))
# 保存此工程下的所有C文件
# CFILES = project/main.c bsp/clk/bsp_clk.c bsp/led/bsp_led.c bsp/delay/bsp_delay.c
CFILES		  := $(foreach dir, $(SRCDIRS),  $(wildcard $(dir)/*.c))

# 不带路径的文件名
# SFILENDIR = start.S
SFILENDIR	  := $(notdir $(SFILES))
# CFILENDIR = main.c bsp_clk.c bsp_led.c bsp_delay.c
CFILENDIR	  := $(notdir $(CFILES))

# $(SFILENDIR:.S=.o): 将$(SFILENDIR)变量的.S后缀改为.o后缀
# SOBJS = obj/start.o
SOBJS		  := $(patsubst %, obj/%, $(SFILENDIR:.S=.o))
# COBJS = obj/main.o obj/bsp_clk.o obj/bsp_led.o obj/bsp_delay.o
COBJS		  := $(patsubst %, obj/%, $(CFILENDIR:.c=.o))

# OBJS即为所有.o文件
# OBJS = obj/start.o obj/main.o obj/bsp_clk.o obj/bsp_led.o obj/bsp_delay.o
OBJS 		  := $(SOBJS)$(COBJS)

# 定义了这个变量，那么，make就会在当当前目录找不到的情况下，到所指定的目录中去找寻文件了
VPATH		  := $(SRCDIRS)

# 声明 clean 为伪目标以后不管当前目录下是否存在名
# 为“clean”的文件，输入“make clean”的话规则后面的 rm 命令都会执行
.PHONY:clean

# $(TARGET).bin的依赖是所有的.o文件
$(TARGET).bin : $(OBJS)
#$^所有依赖文件的集合，使用空格分开，如果在依赖文件中有多个重复的文件， 
#“$^”会去除重复的依赖文件，值保留一份。
#向SD卡中烧录文件以后，启动设备，I.MX6U 的内部 boot rom 程序会将可执行文件拷贝到链接地址处
#这个链接地址可以在 I.MX6U 的内部 128KB RAM 中 (0X900000~0X91FFFF)，也可以在外部的 DDR 中
#本教程所有裸机例程的链接地址都在 DDR 中，链接起始地址为 0X87800000
#.elf文件: 带有各种头部信息的bin文件，可用来反汇编
#-Timx6u.lds(链接脚本) 就是指定链接地址，“-o”选项指定链接生成的 elf文件名
	$(LD) -Timx6u.lds -o $(TARGET).elf $^
# $@规则中的目标集合，在模式规则中，如果有多个目标的话，“$@”表示匹配模式中定义的目标集合
#“-O”选项指定以什么格式输出，后面的“binary”表示以二进制格式输出，
#“-S”表示不要复制源文件中的重定位信息和符号信息，
#“-g”表示不复制源文件中的调试信息
	$(OBJCOPY) -O binary -S $(TARGET).elf $@
	$(OBJDUMP)  -D -m arm $(TARGET).elf > $(TARGET).dis

# 静态模式: 语法：<targets ...>: <target-pattern>: <prereq-patterns ...>
# targets 定义了一系列的目标文件，可以有通配符。是目标的一个集合。
# target-parrtern 是指明了 targets 的模式，也就是的目标集模式。
# prereq-parrterns 是目标的依赖模式，它对 target-parrtern 形成的模式再进行一次依赖目标的定义。
# 此处表示将所有的.S文件编译为.o并且存放到obj目录下去
$(SOBJS) : obj/%.o : %.S 
# $<依赖文件集合中的第一个文件，如果依赖文件是以模式(即“%”)定义的，那么 “$<”就是符合模式的一系列的文件集合。
# -Wall表示显示编译的时候所有警告
# -nostdlib表示不链接系统标准启动文件和库文件，否则编译可能会出错
# -O2表示优化等级，和MDK上的设置含义一样
# $(INCLUDE)指定文件路径 INCLUDE = -I imx6u -I bsp/clk -I bsp/led -I bsp/delay
	$(CC) -Wall -nostdlib -c -O2 $(INCLUDE) -o $@ $<

$(COBJS) : obj/%.o : %.c
	$(CC) -Wall -nostdlib -c -O2 $(INCLUDE) -o $@ $<

print:
	@echo INCLUDE = $(INCLUDE)
	@echo SFILES = $(SFILES)
	@echo CFILES = $(CFILES)
	@echo SFILENDIR = $(SFILENDIR)
	@echo CFILENDIR = $(CFILENDIR)
	@echo SOBJS = $(SOBJS)
	@echo COBJS = $(COBJS)
	@echo OBJS = $(OBJS)

clean:
	rm -rf $(OBJS) $(TARGET).bin $(TARGET).elf $(TARGET).dis

#向 SD卡烧写 bin文件： ./imxdownload beep.bin /dev/sdb