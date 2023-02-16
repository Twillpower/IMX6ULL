#include "bsp_key.h"
// 按键KEY0链接到了UART1_CTS引脚上。默认情况下UART1_CTS为高，当按下KEY0以后UART1_CTS为低。

/* 初始化LED */
void key_init(void)
{
    gpio_pin_config_t key_config;
    // 初始化UART1_CTS这个IO复用为GPIO1_IO18
    // 0: Software Input On Field.查IMX6ULL参考手册IOMUXC_SW_MUX_CTL_PAD_UART1_CTS_B字段说明
    IOMUXC_SetPinMux(IOMUXC_UART1_CTS_B_GPIO1_IO18, 0);

    // 设置UART1_CTS这个IO的电气属性。
    // 0x10b0: 查IMX6ULL参考手册IOMUXC_SW_MUX_CTL_PAD_UART1_CTS_B字段说明
    IOMUXC_SetPinConfig(IOMUXC_UART1_CTS_B_GPIO1_IO18, 0xF080);

    /* GPIO初始化 */
    key_config.direction = kGPIO_DigittalInput;
    gpio_init(GPIO1, 18, &key_config);
}

/* 读取按键值 
 * 返回值：0 按下，1 未按下
 */
int read_key(void)
{
    int ret = 0;
    ret = gpio_pinread(GPIO1, 18);  // 将bit18位的数据移到bit0，与0X1，即将其它位清0,bit0位保持不变
    return ret;
}

int key_getvalue(void)
{
    int ret = 0;
    static unsigned char release = 1; /* 为1表示按键释放 */

    if((release==1) && (gpio_pinread(GPIO1, 18) == 0)) /* 按下 */
    {
        delay(10);
        release = 0;
        if(gpio_pinread(GPIO1, 18)== 0) /* 如果延时10ms以后KEY0还是0,表示按键有效 */
        {
            ret = KEY0_VALUE;
        }
    }
    else if(gpio_pinread(GPIO1, 18) == 1) /* 未按下 */
    {
        ret = KEY_NONE;
        release = 1;
    }
    return ret;
}
