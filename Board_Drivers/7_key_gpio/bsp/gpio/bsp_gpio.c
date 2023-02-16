#include "bsp_gpio.h"

/* GPIO初始化 */
void gpio_init(GPIO_Type *base, int pin, gpio_pin_config_t *config)
{
    if(config->direction == kGPIO_DigittalInput)  // 输入
    {
        base->GDIR &= ~(1 << pin); // pin位设置为0, 即为输入
    }
    else
    {
        base->GDIR |= (1 << pin); // pin位设置为1, 即为输出
        /* 设置默认输出电平 */
        gpio_pinwrite(base, pin, config->outputLogic);
    }
}

/* 控制GPIO高低电平 */
void gpio_pinwrite(GPIO_Type *base, int pin, int value)
{
    if(value == 0)  // 写0
    {
        base->DR &= ~(1 << pin);
    }
    else // 写1
    {
        base->DR |= (1 << pin);
    }
}

/* 读取指定IO电平 */
int gpio_pinread(GPIO_Type *base, int pin)
{
    return (((base->DR) >> pin) & 0X1);  // 将pin位的数据移到bit0，与0X1，即将其它位清0,bit0位保持不变
}