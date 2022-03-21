CC = arm-none-eabi
CORE = -mcpu=cortex-m0 -mthumb -mfloat-abi=soft
TARGET = temp
SYMBOLS = -DSTM32F091xC -DUSE_HAL_DRIVER

VPATH = App/Source cmsis/startup HALF0/Src 
INCLUDES = -I App/Include -I cmsis/core -I cmsis/registers -I HALF0/Inc

F_SECTIONS = -ffunction-sections -fdata-sections
SPECS_V = -Wl,--gc-sections --specs=rdimon.specs --specs=nano.specs

CFLAGS = -g3 -c $(CORE) -std=gnu99 -Wall -O0 $(F_SECTIONS) $(INCLUDES) $(SYMBOLS)
LDFLAGS = $(CORE) $(SPECS_V) -T cmsis/linker/STM32F091RCTx_FLASH.ld -Wl,-Map=$(OUTPUT_F)/$(TARGET).map
OBJS_F = Build/Obj
OUTPUT_F = Build

SRCS  = main.c App_ints.c App_msps.c startup_stm32f091xc.c system_stm32f0xx.c 
SRCS += stm32f0xx_hal.c stm32f0xx_hal_cortex.c stm32f0xx_hal_rcc.c stm32f0xx_hal_flash.c
SRCS += stm32f0xx_hal_gpio.c stm32f0xx_hal_uart.c stm32f0xx_hal_dma.c stm32f0xx_hal_rtc.c

OBJS = $(SRCS:%.c=$(OBJS_F)/%.o)

all:$(TARGET)

$(TARGET) : $(addprefix $(OUTPUT_F)/,$(TARGET).elf)
	$(CC)-objcopy -Oihex $< Build/$(TARGET).hex
	$(CC)-objdump -S $< > Build/$(TARGET).lst
	$(CC)-size --format=berkeley $<

$(addprefix $(OUTPUT_F)/,$(TARGET).elf): $(OBJS)
	@$(CC)-gcc $(LDFLAGS) -o $@ $^	

$(addprefix $(OBJS_F)/,%.o) : %.c
	@mkdir -p $(OBJS_F)
	@$(CC)-gcc -MD $(CFLAGS) -o $@ $<

$(addprefix $(OBJS_F)/,%.o) : %.s
	@$(CC)-as -c $(CORE) -o $@ $<

-include $(OBJS_F)/*.d

.PHONY: clean flash open debug test_generation test_execution

test_generation:
	@read -p "Enter Module Name:" module; \
	echo "Making Unit Test for:" $$module;\
	ceedling new Test/UnitTest/$$module 
test_execution:
	@(cd Test/UnitTest && ls)
	@read -p "What module do you need to test:" module; \
	(cd Test/UnitTest/$$module && ceedling test)  

clean:
	@rm -rf Build
clean_full:
	@echo "clean"
flash:
	@echo flash
open:
	@echo open
debug:
	@echo debug