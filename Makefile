#TOOLCHAIN=~/toolchain/gcc-arm-none-eabi-4_9-2014q4/bin
#PREFIX=$(TOOLCHAIN)/arm-none-eabi-
PREFIX=arm-none-eabi-
ARCHFLAGS=-mthumb -mcpu=cortex-m0plus
CFLAGS=-DCPU_MKL46Z128VLH4 -I./drivers/ -I./includes/ -g3 -O2 -Wall -Werror
LDFLAGS=--specs=nano.specs -Wl,--gc-sections,-Map,$(TARGET_HEL).map,-Tlink.ld

CC=$(PREFIX)gcc
LD=$(PREFIX)gcc
OBJCOPY=$(PREFIX)objcopy
SIZE=$(PREFIX)size
RM=rm -f

TARGET_HEL=hello_world
TARGET_LED=led_blinky

SRC_HEL:=$(wildcard drivers/*.c hello_world.c)
OBJ_HEL=$(patsubst %.c, %.o, $(SRC_HEL))

SRC_LED:=$(wildcard drivers/*.c led_blinky.c)
OBJ_LED=$(patsubst %.c, %.o, $(SRC_LED))

all: build_hel build_led size

build_hel: elf_hel srec_hel bin_hel
elf_hel: $(TARGET_HEL).elf
srec_hel: $(TARGET_HEL).srec
bin_hel: $(TARGET_HEL).bin

build_led: elf_led srec_led bin_led
elf_led: $(TARGET_LED).elf
srec_led: $(TARGET_LED).srec
bin_led: $(TARGET_LED).bin

clean:
	$(RM) $(TARGET_HEL).srec $(TARGET_HEL).elf $(TARGET_HEL).bin $(TARGET_HEL).map $(OBJ_HEL) $(TARGET_LED).srec $(TARGET_LED).elf $(TARGET_LED).bin $(TARGET_LED).map $(OBJ_LED)

clean_hel:
	$(RM) $(TARGET_HEL).srec $(TARGET_HEL).elf $(TARGET_HEL).bin $(TARGET_HEL).map $(OBJ_HEL)

clean_led:
	$(RM) $(TARGET_LED).srec $(TARGET_LED).elf $(TARGET_LED).bin $(TARGET_LED).map $(OBJ_LED)

%.o: %.c
	$(CC) -c $(ARCHFLAGS) $(CFLAGS) -o $@ $<

$(TARGET_HEL).elf: $(OBJ_HEL)
	$(LD) $(LDFLAGS) -o $@ $(OBJ_HEL)

$(TARGET_LED).elf: $(OBJ_LED)
	$(LD) $(LDFLAGS) -o $@ $(OBJ_LED)

%.srec: %.elf
	$(OBJCOPY) -O srec $< $@

%.bin: %.elf
	    $(OBJCOPY) -O binary $< $@

size:
	$(SIZE) $(TARGET_HEL).elf

flash_hello: clean build_hel
	openocd -f openocd.cfg -c "program $(TARGET_HEL).elf verify reset exit"

flash_led: clean build_led
	openocd -f openocd.cfg -c "program $(TARGET_LED).elf verify reset exit"