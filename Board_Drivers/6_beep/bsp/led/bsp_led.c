#include "bsp_led.h"

/* 初始化LED */
void led_init(void)
{
    IOMUXC_SetPinMux(IOMUXC_GPIO1_IO03_GPIO1_IO03, 0);

    IOMUXC_SetPinConfig(IOMUXC_GPIO1_IO03_GPIO1_IO03, 0x10B0);

    /* GPIO初始化 */
    // 因为是IO03所以设置0x8即bit4(8421;3210)
    GPIO1->GDIR = 0x8;           /* 设置为输出 */
    GPIO1->DR = 0X0;             /* 打开LED灯 */
}

/* 打开LED灯 */
void led_on(void)
{
    // 因为是IO03所以左移3位
    GPIO1->DR &= ~(1<<3); /* bit3清零 */
}

/* 关闭LED灯 */
void led_off(void)
{
    // 因为是IO03所以左移3位
    GPIO1->DR |= (1<<3); /* bit3置1 */
}

/* LED灯控制函数 */
void led_switch(int led, int status)
{
    switch(status)
    {
        case LED0:
            if(status == ON)
                GPIO1->DR &= ~(1<<3); /* bit3清零 */
            else if(status == OFF)
                GPIO1->DR |= (1<<3); /* bit3置1 */
            break;
    }
}