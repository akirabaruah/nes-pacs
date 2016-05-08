obj-m := nes.o

KERNEL_SRC_DIR=~/Desktop/linux-socfpga
PWD=$(shell pwd)

all:
	make ARCH=arm CROSS_COMPILE=arm-linux-gnueabihf- -C $(KERNEL_SRC_DIR) \
		M=$(PWD) modules

clean:
	make ARCH=arm CROSS_COMPILE=arm-linux-gnueabihf- -C $(KERNEL_SRC_DIR) \
		M=$(PWD) clean
