#include "bsp_led.h"

/* 初始化LED */
void led_init(void)
{
    gpio_pin_config_t led_config;
    IOMUXC_SetPinMux(IOMUXC_GPIO1_IO03_GPIO1_IO03, 0);

    IOMUXC_SetPinConfig(IOMUXC_GPIO1_IO03_GPIO1_IO03, 0x10B0);

    /* GPIO初始化 */
    // 因为是IO03所以设置0x8即bit4(8421;3210)
    led_config.direction = kGPIO_DigittalOutput;
    led_config.outputLogic = 0; /* 打开LED灯 */
    gpio_init(GPIO1, 3, &led_config);
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
    switch(led)
    {
        case LED0:
            if(status == ON)
                gpio_pinwrite(GPIO1, 3, 0);
            else if(status == OFF)
                gpio_pinwrite(GPIO1, 3, 1);
            break;
    }
}