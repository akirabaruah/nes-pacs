/*
 * Device driver for the NES
 *
 * A Platform device implemented using the misc subsystem
 *
 * References:
 * Linux source: Documentation/driver-model/platform.txt
 *               drivers/misc/arm-charlcd.c
 * http://www.linuxforu.com/tag/linux-device-drivers/
 * http://free-electrons.com/docs/
 *
 * "make" to build
 * insmod nes.ko
 *
 * Check code style with
 * checkpatch.pl --file --no-tree nes.c
 */

#include <linux/module.h>
#include <linux/init.h>
#include <linux/errno.h>
#include <linux/version.h>
#include <linux/kernel.h>
#include <linux/platform_device.h>
#include <linux/miscdevice.h>
#include <linux/slab.h>
#include <linux/io.h>
#include <linux/of.h>
#include <linux/of_address.h>
#include <linux/fs.h>
#include <linux/uaccess.h>
#include "nes.h"

#define DRIVER_NAME "nes"

/* Which "compatible" string(s) to search for in the Device Tree */
#ifdef CONFIG_OF
static const struct of_device_id nes_of_match[] = {
	{ .compatible = "altr,nes" },
	{},
};
MODULE_DEVICE_TABLE(of, nes_of_match);
#endif


/*
 * Information about our device
 */
struct nes_dev {
	struct resource res; /* Resource: our registers */
	void __iomem *virtbase; /* Where registers can be accessed in memory */
	nes_arg_t data; /* Keep track of NES data */
} dev;

/*
 * Write segments of a single coord
 * Assumes coord is in range and the device information has been set up
 */
static void write_data(u32 data)
{
	iowrite32(data, dev.virtbase);
}

/*
 * Handle ioctl() calls from userspace:
 * Read or write the segments on single data.
 */
static long nes_ioctl(struct file *f, unsigned int cmd, unsigned long arg)
{
	nes_arg_t nes;
	switch (cmd) {
		case NES_WRITE:
			if (copy_from_user(&nes, (nes_arg_t *) arg, sizeof(nes_arg_t)))
				return -EACCES;
			dev.data = nes;
			write_data(*((u32 *)&nes));
			break;

		case NES_READ:
			if (copy_from_user(&nes, (nes_arg_t *) arg, sizeof(nes_arg_t)))
				return -EACCES;
			nes = dev.data;
			if (copy_to_user((nes_arg_t *) arg, &nes, sizeof(nes_arg_t)))
				return -EACCES;
			break;

		default:
			return -EINVAL;
	}
	return 0;
}

/* The operations our device knows how to do */
static const struct file_operations nes_fops = {
	.owner			= THIS_MODULE,
	.unlocked_ioctl = nes_ioctl,
};

/* Information about our device for the "misc" framework */
static struct miscdevice nes_misc_device = {
	.minor		= MISC_DYNAMIC_MINOR,
	.name		= DRIVER_NAME,
	.fops		= &nes_fops,
};

/*
 * Initialization code: get resources (registers)
 */
static int __init nes_probe(struct platform_device *pdev)
{
	int ret;

	/* Register ourselves as a misc device: creates /dev/vga_ball */
	ret = misc_register(&nes_misc_device);

	/* Get the address of our registers from the device tree */
	ret = of_address_to_resource(pdev->dev.of_node, 0, &dev.res);
	if (ret) {
		ret = -ENOENT;
		goto out_deregister;
	}

	/* Make sure we can use these registers */
	if (request_mem_region(dev.res.start, resource_size(&dev.res),
			DRIVER_NAME) == NULL) {
		ret = -EBUSY;
		goto out_deregister;
	}

	/* Arrange access to our registers */
	dev.virtbase = of_iomap(pdev->dev.of_node, 0);
	if (dev.virtbase == NULL) {
		ret = -ENOMEM;
		goto out_release_mem_region;
	}

	return 0;

out_release_mem_region:
	release_mem_region(dev.res.start, resource_size(&dev.res));

out_deregister:
	misc_deregister(&nes_misc_device);
	
	return ret;
}

/* Clean-up code: release resources */
static int nes_remove(struct platform_device *pdev)
{
	iounmap(dev.virtbase);
	release_mem_region(dev.res.start, resource_size(&dev.res));
	misc_deregister(&nes_misc_device);
	return 0;
}

/* Information for registering ourselves as a "platform" driver */
static struct platform_driver vga_ball_driver = {
	.driver	= {
		.name			= DRIVER_NAME,
		.owner			= THIS_MODULE,
		.of_match_table = of_match_ptr(nes_of_match),
	},
	.remove	= __exit_p(nes_remove),
};

/* Called when the module is loaded: set things up */
static int __init nes_init(void)
{
	pr_info(DRIVER_NAME ": init\n");
	return platform_driver_probe(&nes_driver, nes_probe);
}

/* Called when the module is unloaded: release resources */
static void __exit nes_exit(void)
{
	platform_driver_unregister(&nes_driver);
	pr_info(DRIVER_NAME ": exit\n");
}

module_init(nes_init);
module_exit(nes_exit);

MODULE_LICENSE("GPL");
MODULE_AUTHOR("Chaiwen, Phil, Akira, Sean");
MODULE_DESCRIPTION("NES");
