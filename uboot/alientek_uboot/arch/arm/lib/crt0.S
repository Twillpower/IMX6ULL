/*
 *  crt0 - C-runtime startup Code for ARM U-Boot
 *
 *  Copyright (c) 2012  Albert ARIBAUD <albert.u.boot@aribaud.net>
 *
 * SPDX-License-Identifier:	GPL-2.0+
 */

#include <config.h>
#include <asm-offsets.h>
#include <linux/linkage.h>
#ifdef CONFIG_CPU_V7M
#include <asm/armv7m.h>
#endif

/*
 * This file handles the target-independent stages of the U-Boot
 * start-up where a C runtime environment is needed. Its entry point
 * is _main and is branched into from the target's start.S file.
 *
 * _main execution sequence is:
 *
 * 1. Set up initial environment for calling board_init_f().
 *    This environment only provides a stack and a place to store
 *    the GD ('global data') structure, both located in some readily
 *    available RAM (SRAM, locked cache...). In this context, VARIABLE
 *    global data, initialized or not (BSS), are UNAVAILABLE; only
 *    CONSTANT initialized data are available. GD should be zeroed
 *    before board_init_f() is called.
 *
 * 2. Call board_init_f(). This function prepares the hardware for
 *    execution from system RAM (DRAM, DDR...) As system RAM may not
 *    be available yet, , board_init_f() must use the current GD to
 *    store any data which must be passed on to later stages. These
 *    data include the relocation destination, the future stack, and
 *    the future GD location.
 *
 * 3. Set up intermediate environment where the stack and GD are the
 *    ones allocated by board_init_f() in system RAM, but BSS and
 *    initialized non-const data are still not available.
 *
 * 4a.For U-Boot proper (not SPL), call relocate_code(). This function
 *    relocates U-Boot from its current location into the relocation
 *    destination computed by board_init_f().
 *
 * 4b.For SPL, board_init_f() just returns (to crt0). There is no
 *    code relocation in SPL.
 *
 * 5. Set up final environment for calling board_init_r(). This
 *    environment has BSS (initialized to 0), initialized non-const
 *    data (initialized to their intended value), and stack in system
 *    RAM (for SPL moving the stack and GD into RAM is optional - see
 *    CONFIG_SPL_STACK_R). GD has retained values set by board_init_f().
 *
 * 6. For U-Boot proper (not SPL), some CPUs have some work left to do
 *    at this point regarding memory, so call c_runtime_cpu_setup.
 *
 * 7. Branch to board_init_r().
 *
 * For more information see 'Board Initialisation Flow in README.
 */

/*
 * entry point of crt0 sequence
 */

ENTRY(_main)

/*
 * Set up initial C runtime environment and call board_init_f(0).
 */

#if defined(CONFIG_SPL_BUILD) && defined(CONFIG_SPL_STACK)
	ldr	sp, =(CONFIG_SPL_STACK)
#else
	ldr	sp, =(CONFIG_SYS_INIT_SP_ADDR)
#endif
#if defined(CONFIG_CPU_V7M)	/* v7M forbids using SP as BIC destination */
	mov	r3, sp
	bic	r3, r3, #7
	mov	sp, r3
#else
	bic	sp, sp, #7	/* 8-byte alignment for ABI compliance. sp 做 8 字节对齐 */
#endif
	mov	r0, sp
	bl	board_init_f_alloc_reserve /* 此函数有一个参数，参数为 r0 中的值，此函数定义在文件 common/init/board_init.c 中,分配完uboot早期的malloc内存池大小后,返回新的top值 */
	mov	sp, r0  /* 将 r0 写入到 sp 里面，r0 保存着函数board_init_f_alloc_reserve 的返回值 */
	/* set up gd here, outside any C code */
	mov	r9, r0 /* 将 r0 寄存器的值写到寄存器 r9 里面，因为 r9 寄存器存放着全局变量 gd 的地址， 在文件 arch/arm/include/asm/global_data.h 中 */
	bl	board_init_f_init_reserve /* 此函数在文件common/init/board_init.c 中有定义 */

	mov	r0, #0
	bl	board_init_f /* 定义在文件 common/board_f.c 中, 主要用来初始化DDR，定时器，完成代码拷贝等等 */

#if ! defined(CONFIG_SPL_BUILD)

/*
 * Set up intermediate environment (new sp and gd) and call
 * relocate_code(addr_moni). Trick here is that we'll return
 * 'here' but relocated.
 */

	ldr	sp, [r9, #GD_START_ADDR_SP]	/* sp = gd->start_addr_sp */ /* 重新设置环境(sp 和 gd)、获取 gd->start_addr_sp 的值赋给 sp,说明新的 sp 和 gd将会存 放到DDR中，而不是内部的 RAM了 */
#if defined(CONFIG_CPU_V7M)	/* v7M forbids using SP as BIC destination */
	mov	r3, sp
	bic	r3, r3, #7
	mov	sp, r3
#else
	bic	sp, sp, #7	/* 8-byte alignment for ABI compliance */
#endif
	ldr	r9, [r9, #GD_BD]		/* r9 = gd->bd */ /* 获取 gd->bd 的地址赋给 r9，此时 r9 存放的是老的 gd，这里通过获取 gd->bd 的地址来计算出新的 gd的位置 */
	sub	r9, r9, #GD_SIZE		/* new GD is below bd */ /* 新的 gd在 bd 下面，所以 r9 减去 gd的大小就是新的 gd 的位置，获取到新的 gd的位置以后赋值给 r9 */

	adr	lr, here /* 设置 lr 寄存器为 here，这样后面执行其他函数返回的时候就返回到了 here 位置处 */
	ldr	r0, [r9, #GD_RELOC_OFF]		/* r0 = gd->reloc_off */
	add	lr, lr, r0 /* lr 寄存器的值加上 r0 寄存器的值，重新赋值给 lr 寄存器。因为接下来要重定位代码，也就是把代码拷贝到新的地方去
					(现在的 uboot 存放的起始地址为 0X87800000，下面要 将 uboot 拷贝到 DDR 最后面的地址空间出，将 0X87800000 开始的内存空出来)，
					其中就包括 here，因此 lr 中的 here 要使用重定位后的位置 */
#if defined(CONFIG_CPU_V7M)
	orr	lr, #1				/* As required by Thumb-only */
#endif
	ldr	r0, [r9, #GD_RELOCADDR]		/* r0 = gd->relocaddr */ /* 读取 gd->relocaddr 的值赋给 r0 寄存器，此时 r0 寄存器就保存着 uboot 要拷贝的目的地址 */
	b	relocate_code /* 此函数负责将 uboot 拷贝到新的地方去，此函数定义在文件 arch/arm/lib/relocate.S 中 */
here:
/*
 * now relocate vectors
 */

	bl	relocate_vectors /* 调用函数 relocate_vectors，对中断向量表做重定位，此函数定义在文件 arch/arm/lib/relocate.S 中 */

/* Set up final (full) environment */

	bl	c_runtime_cpu_setup	/* we still call old routine here */ /* 此函数定义在文件arch/arm/cpu/armv7/start.S 中 */
#endif
#if !defined(CONFIG_SPL_BUILD) || defined(CONFIG_SPL_FRAMEWORK)
# ifdef CONFIG_SPL_BUILD
	/* Use a DRAM stack for the rest of SPL, if requested */
	bl	spl_relocate_stack_gd
	cmp	r0, #0
	movne	sp, r0
	movne	r9, r0
# endif
	ldr	r0, =__bss_start	/* this is auto-relocated! */

#ifdef CONFIG_USE_ARCH_MEMSET
	ldr	r3, =__bss_end		/* this is auto-relocated! */
	mov	r1, #0x00000000		/* prepare zero to clear BSS */

	subs	r2, r3, r0		/* r2 = memset len */
	bl	memset
#else
	ldr	r1, =__bss_end		/* this is auto-relocated! */
	mov	r2, #0x00000000		/* prepare zero to clear BSS */

clbss_l:cmp	r0, r1			/* while not at end of BSS */
#if defined(CONFIG_CPU_V7M)
	itt	lo
#endif
	strlo	r2, [r0]		/* clear 32-bit BSS word */
	addlo	r0, r0, #4		/* move to next */
	blo	clbss_l
#endif

#if ! defined(CONFIG_SPL_BUILD)
	bl coloured_LED_init
	bl red_led_on
#endif
	/* call board_init_r(gd_t *id, ulong dest_addr) 设置函数 board_init_r 的两个参数, 此函数定义在文件 common/board_r.c 中 */
	mov     r0, r9                  /* gd_t */ /* 第一个参数是 gd，因此读取 r9 保存到 r0 里面 */
	ldr	r1, [r9, #GD_RELOCADDR]	/* dest_addr */ /* 第二个参数是目的地址，因此 r1= gd->relocaddr */
	/* call board_init_r */
#if defined(CONFIG_SYS_THUMB_BUILD)
	ldr	lr, =board_init_r	/* this is auto-relocated! */
	bx	lr
#else
	ldr	pc, =board_init_r	/* this is auto-relocated! */
#endif
	/* we should not return here. */
#endif

ENDPROC(_main)
