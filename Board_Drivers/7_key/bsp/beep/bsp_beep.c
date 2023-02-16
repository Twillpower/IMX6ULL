#include "bsp_beep.h"
/* BEEP控制IO为SNVS_TAMPER1，当输出高电平的时候蜂鸣器关闭，输出低电平的时候蜂鸣器打开 */

/* BEEP初始化 */
void beep_init(void)
{
    // 初始化SNVS_TAMPER1这个IO复用为GPIO5_IO01
    // 0: Software Input On Field.查IMX6ULL参考手册IOMUXC_SNVS_SW_MUX_CTL_PAD_SNVS_TAMPER1字段说明
    IOMUXC_SetPinMux(IOMUXC_SNVS_SNVS_TAMPER1_GPIO5_IO01, 0);

    // 设置SNVS_TAMPER1这个IO的电气属性。
    // 0x10b0: 查IMX6ULL参考手册IOMUXC_SNVS_SW_PAD_CTL_PAD_SNVS_TAMPER1字段说明
    IOMUXC_SetPinConfig(IOMUXC_SNVS_SNVS_TAMPER1_GPIO5_IO01, 0x10b0);

    /* GPIO初始化 */
    GPIO5->GDIR |= (1<<1); // 因为是IO01所以左移一位，将bit1设置为1, GPIO设置为output
    GPIO5->DR |= (1<<1); // 将bit1设置为1, 当输出高电平的时候蜂鸣器关闭
}

/* 蜂鸣器控制函数 */
void beep_switch(int status)
{
    if(status == ON)
        GPIO5->DR &= ~(1<<1); // 将bit1设置为0, 输出低电平的时候蜂鸣器打开
    else if(status == OFF)
        GPIO5->DR |= (1<<1); // 将bit1设置为1, 当输出高电平的时候蜂鸣器关闭
}