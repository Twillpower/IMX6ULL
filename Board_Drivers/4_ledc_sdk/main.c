#include "fsl_iomuxc.h"
#include "MCIMX6Y2.h"

/* 使能外设时钟 */
void clk_enable(void)
{
    CCM->CCGR0 = 0xFFFFFFFF;
    CCM->CCGR1 = 0xFFFFFFFF;
    CCM->CCGR2 = 0xFFFFFFFF;
    CCM->CCGR3 = 0xFFFFFFFF;
    CCM->CCGR4 = 0xFFFFFFFF;
    CCM->CCGR5 = 0xFFFFFFFF;
    CCM->CCGR6 = 0xFFFFFFFF;
}

/* 初始化LED */
void led_init(void)
{
    IOMUXC_SetPinMux(IOMUXC_GPIO1_IO03_GPIO1_IO03, 0);

    IOMUXC_SetPinConfig(IOMUXC_GPIO1_IO03_GPIO1_IO03, 0x10B0);

    /* GPIO初始化 */
    GPIO1->GDIR = 0x8;           /* 设置为输出 */
    GPIO1->DR = 0X0;             /* 打开LED灯 */
}

/* 短延时 */
void delay_short(volatile unsigned int n)
{
    while(n--){}
}

/* 延时，一次循环大概是1ms，在主频396MHz
 * n ：延时ms数
  */
void delay(volatile unsigned int n)
{
    while(n--) {
        delay_short(0x7ff);
    }
}

/* 打开LED灯 */
void led_on(void)
{
    GPIO1->DR &= ~(1<<3); /* bit3清零 */
}

/* 关闭LED灯 */
void led_off(void)
{
    GPIO1->DR |= (1<<3); /* bit3置1 */
}

int main(void)
{
    clk_enable();   /* 使能外设时钟 */
    led_init();     /* 初始化LED */
    /* 初始化LED */
    
    /* 设置LED闪烁 */
    while(1) {
        led_on();
        delay(500);

        led_off();
        delay(500);
    }
    return 0;
}