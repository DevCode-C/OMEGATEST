#include "App_bsp.h"
#include "stdint.h"
#include <stdint.h>

#if defined(SEMIHOSTING)
#include "stdio.h"
extern void initialise_monitor_handles(void);
#endif

uint32_t valor = 0;

int main(void)
{
    #if defined(SEMIHOSTING)
    initialise_monitor_handles();
    printf("\n");
    #endif
    HAL_Init();
    /* code */
    valor = HAL_GetTick();
    for (; ; )
    {
        
        if ((HAL_GetTick() - valor) >= 1000)
        {
            printf("Hola mundo\n");
            valor = HAL_GetTick();
        }
        
    }
    
    return 0;
}
