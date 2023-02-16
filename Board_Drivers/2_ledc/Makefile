objs = start.o main.o 

led.bin : $(objs)
#$^所有依赖文件的集合，使用空格分开，如果在依赖文件中有多个重复的文件， 
#“$^”会去除重复的依赖文件，值保留一份。
	arm-linux-gnueabihf-ld -Timx6ull.lds $^ -o led.elf
	arm-linux-gnueabihf-objcopy -O binary -S -g led.elf $@
	arm-linux-gnueabihf-objdump -D led.elf > led.dis

%.o : %.c
# -Wall表示显示编译的时候所有警告
# -nostdlib表示不链接系统标准启动文件和库文件，否则编译可能会出错
# -O2表示优化等级，和MDK上的设置含义一样
# $@规则中的目标集合，在模式规则中，如果有多个目标的话，“$@”表示匹配模 式中定义的目标集合
# $<依赖文件集合中的第一个文件，如果依赖文件是以模式(即“%”)定义的，那么 “$<”就是符合模式的一系列的文件集合。
	arm-linux-gnueabihf-gcc -Wall -nostdlib -c -O2 -o $@ $<

%.o : %.s
	arm-linux-gnueabihf-gcc -Wall -nostdlib -c -O2 -o $@ $<

clean:
	rm -rf *.o led.bin led.elf led.dis