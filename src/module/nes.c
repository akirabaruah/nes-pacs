#include <linux/init.h>
#include <linux/module.h>
#include <linux/kernel.h>
#include <linux/device.h>
#include <linux/platform_device.h>
#include <linux/uaccess.h>
#include <linux/ioport.h>
#include <linux/io.h>

// memory region we want access to
#define BLINKER_BASE 0xff200000
#define BLINKER_SIZE PAGE_SIZE

void *blink_mem;

// declare and register a device_driver struct
// to get driver entry in Sysfs
// must have a name and a bus that connects device to CPU
// module accessed directly from system mem, use generic platform type
static struct device_driver nes_driver = {
	.name = "nes",
	.bus = &platform_bus_type,
};

// dont read, write only
ssize_t nes_read(struct device_driver *drv, char *buf)
{
	return 0;
}

// write
ssize_t nes_write(struct device_driver *drv, const char *buf, size_t count)
{
	u8 delay;

	if (buf == NULL) {
		pr_err("Error, string must not be NULL\n");
		return -EINVAL;
	}

	if (kstrtou8(buf, 10, &delay) < 0) {
		pr_err("Could not convert string to integer\n");
		return -EINVAL;
	}

	// check if within bounds, write num between 1 and 15
	if (delay < 1 || delay > 15) {
		pr_err("Invalid delay %d\n", delay);
		return -EINVAL;
	}

	// write a single byte
	iowrite8(delay, blink_mem);

	return count;
}

// declare driver_attribute struct
// func pointers to show or store funcs run when userspace
// reads or writse to sysfs file
// declares a driver_attr struct called driver_attr_blinker
// Write access for user S_IWUSR
static DRIVER_ATTR(nes, S_IWUSR, nes_read, nes_write);

MODULE_LICENSE("Dual BSD/GPL");

static int __init nes_init(void)
{
	int ret;
	struct resource *res;

	// register driver
	// file will be created at:
	// /sys/bus/platform/drivers/blinker/blinker

	// writing to file will trigger blinker_store func
	ret = driver_register(&nes_driver);
	if (ret < 0)
		return ret;

	ret = driver_create_file(&nes_driver, &driver_attr_nes);
	if (ret < 0) {
		driver_unregister(&nes_driver);
		return ret;
	}
	
	// request exclusive access to memory region we want to write
	// BLINKER_BASE = base addr we want
	// BLINKER_SIZE = page size
	// can only get memory a page at a time, req a whole page
	res = request_mem_region(BLINKER_BASE, BLINKER_SIZE, "blinker");
	if (res == NULL) {
		driver_remove_file(&nes_driver, &driver_attr_nes);
		driver_unregister(&nes_driver);
		return -EBUSY;
	}
	// map the address into virtual memory, return pointer
	blink_mem = ioremap(BLINKER_BASE, BLINKER_SIZE);
	if (blink_mem == NULL) {
		driver_remove_file(&nes_driver, &driver_attr_nes);
		driver_unregister(&nes_driver);
		release_mem_region(BLINKER_BASE, BLINKER_SIZE);
		return -EFAULT;
	}
	// we can now write to blink_mem to trigger write func
	return 0;
}

static void __exit nes_exit(void)
{
	// unregister driver
	driver_remove_file(&nes_driver, &driver_attr_nes);
	driver_unregister(&nes_driver);
	release_mem_region(BLINKER_BASE, BLINKER_SIZE);
	iounmap(blink_mem);
}

module_init(nes_init);
module_exit(nes_exit);
