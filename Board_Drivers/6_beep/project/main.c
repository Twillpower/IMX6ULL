#include "main.h"

int main(void)
{
    clk_enable();   /* 使能外设时钟 */
    led_init();     /* 初始化LED */
    beep_init();
    
    /* 设置LED闪烁 */
    while(1) {
        led_on();
        beep_switch(ON);
        delay(500);

        led_off();
        beep_switch(OFF);
        delay(500);
    }
    return 0;
}