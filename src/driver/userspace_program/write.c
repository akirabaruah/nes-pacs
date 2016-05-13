#include <sys/mman.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <fcntl.h>
#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <stdint.h>
#include <string.h>

#define PAGE_SIZE 4096
#define LWHPS2FPGA_BRIDGE_BASE 0xff200000
#define NES_OFFSET 0x0
#define MEMSIZE 65536

typedef struct {
  unsigned char nes_op;
  unsigned char nes_in;
  unsigned char nes_out;
  unsigned short address; 
} nes_args;

volatile unsigned char *nes_mem;
void *bridge_map;
int nes_fd;

void print_state(nes_args *nes) 
{
    printf("current state: \n");
    printf( "nes_op: %x\n", nes->nes_op);
    printf( "nes_in: %x\n", nes->nes_in);
    printf("nes_out: %x\n", nes->nes_out);
    printf("address: %x\n", nes->address);
}

int main(int argc, char *argv[])
{
	int mem_fd;
	int ret = EXIT_FAILURE;
	off_t nes_base = LWHPS2FPGA_BRIDGE_BASE;
   char memory[MEMSIZE];
   memset((char *)memory, 0, sizeof(memory));

	if (argc < 2) {
		fprintf(stderr, "Usage: %s <filename>\n", argv[0]);
		exit(EXIT_FAILURE);
	}

    /* Read assembled binary into simulated memory */
    char *filename = argv[1];
    FILE *binary = fopen(filename, "r");
    if (binary == NULL) {
        perror(filename);
        return 2;
    }
    size_t len = fread(memory, 1, MEMSIZE, binary);


	printf("userspace NES program started, read %d bytes.\n\n", len);

	/* open the memory device file */
	// char *mem_file = "/sys/bus/platform/devices/nes/nes";
   char *mem_file = "/dev/mem";
	mem_fd = open(mem_file, O_RDWR|O_SYNC);
	if (mem_fd < 0) {
		perror("open");
		exit(EXIT_FAILURE);
	}
	
	printf("open done: %s\n", mem_file);	

	/* map the LWHPS2FPGA bridge into process memory */
	bridge_map = mmap(NULL, PAGE_SIZE, PROT_WRITE, MAP_SHARED,
				mem_fd, nes_base);
	if (bridge_map == MAP_FAILED) {
		perror("mmap");
		goto cleanup;
	}

	printf("mmap done\n");

	printf("loading program into memory\n");

    /* get the delay_ctrl peripheral's base address */
	nes_mem = (unsigned char *) (bridge_map + NES_OFFSET);
  	printf("passed nes_mem\n"); 

   int x = 0;
   while (x < len) {
		printf("%d: writing %x to memory\n", x, memory[x]);
		nes_mem[2 * x] = memory[x];
		nes_mem[1] = (char)3; //CPU_WRITE
		x++;
	}


	printf("munmap\n");
	if (munmap(bridge_map, PAGE_SIZE) < 0) {
		perror("munmap");
		goto cleanup;
	}

	ret = 0;

cleanup:
	fclose(binary);
	return ret;
}
