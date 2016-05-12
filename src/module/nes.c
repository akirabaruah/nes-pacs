#include <linux/init.h>
#include <linux/module.h>
#include <linux/kernel.h>
#include <linux/device.h>
#include <linux/platform_device.h>
#include <linux/uaccess.h>
#include <linux/ioport.h>
#include <linux/io.h>

#define NES_BASE 0xff200000
#define NES_SIZE PAGE_SIZE

void *nes_mem;

static struct device_driver nes_driver = {
	.name = "nes",
	.bus = &platform_bus_type,
};

ssize_t nes_show(struct device_driver *drv, char *buf)
{
	return 0;
}

ssize_t nes_store(struct device_driver *drv, const char *buf, size_t count)
{
	u32 nes_args;

	if (buf == NULL) {
		pr_err("Error, string must not be NULL\n");
		return -EINVAL;
	}

	if (kstrtou32(buf, 16, &nes_args) < 0) {
		pr_err("Could not convert string to integer\n");
		return -EINVAL;
	}

	iowrite32(nes_args, nes_mem);

	return count;
}

static DRIVER_ATTR(nes, S_IWUSR, nes_show, nes_store);

static int __init nes_init(void)
{
	int ret;
	struct resource *res;

	ret = driver_register(&nes_driver);
	if (ret < 0)
		return ret;

	ret = driver_create_file(&nes_driver, &driver_attr_nes);
	if (ret < 0) {
		driver_unregister(&nes_driver);
		return ret;
	}

	res = request_mem_region(NES_BASE, NES_SIZE, "nes");
	if (res == NULL) {
		driver_remove_file(&nes_driver, &driver_attr_nes);
		driver_unregister(&nes_driver);
		return -EBUSY;
	}

	nes_mem = ioremap(NES_BASE, NES_SIZE);
	if (nes_mem == NULL) {
		driver_remove_file(&nes_driver, &driver_attr_nes);
		driver_unregister(&nes_driver);
		release_mem_region(NES_BASE, NES_SIZE);
		return -EFAULT;
	}

	return 0;
}

static void __exit nes_exit(void)
{
	driver_remove_file(&nes_driver, &driver_attr_nes);
	driver_unregister(&nes_driver);
	release_mem_region(NES_BASE, NES_SIZE);
	iounmap(nes_mem);
}

module_init(nes_init);
module_exit(nes_exit);

MODULE_LICENSE("Dual BSD/GPL");
