#include <stdio.h>
#include "nes.h"
#include <sys/ioctl.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <fcntl.h>
#include <string.h>
#include <unistd.h>

int nes_fd;
nes_arg_t nes;

void put_nes(char d_in) 
{
    nes.d_in = (unsigned char) d_in;
    if (ioctl(nes_fd, NES_WRITE, &nes)) {
        perror("ioctl(NES_WRITE) failed");
        return;
    }
}

void get_nes() 
{
    if (ioctl(nes_fd, NES_READ, &nes)) {
        perror("ioctl(NES_READ) failed");
        return;
    }
}

void print_state() 
{
    printf("current state: \n");
    printf( "d_in: %c\n", nes.d_in);
    printf("d_out: %c\n", nes.d_out);
    printf( "addr: %u\n", nes.addr);
}

// unsigned char convert_instr(const char *instr)
// {
//     int num = atoi(instr);
//     reutrn (unsigned char) num;
// }

int main()
{ 
    int instr_fd;
    unsigned char d_in;
    unsigned int temp;
    char buffer[100];
    char *p;
    static const char memory[] = "/dev/nes";
    static const char instructions[] = "test";
    
    printf("NES userspace program started\n\n");
    if ((nes_fd = open(memory, O_RDWR)) == -1) {
        fprintf(stderr, "could not open %s\n", memory);
        return -1;
    }
    if ((instr_fd = fopen(instructions, "r")) == -1) {
        fprintf(stderr, "could not open %s\n", instructions);
        return -1;
    }
    for (;;) {
        fgets(buffer, 100, instr_fd);
        if (buffer[0] == '\0' || buffer[0] == '\n' || buffer[0] == '#')
            fclose(instr_fd);
            close(nes_fd);
            break;
        while (*p) {
            if (*p == '\n' || *p == '#')
                *p = '\0';
                break;
            p++;
        }
        // for each token, convert to byte and put_nes()
        p = strtok(buffer," ");
        while (p != NULL) {
            p = strtok (NULL, " ");
            char i;
            sscanf(buffer, "%u", &temp);
            d_in = (char) temp;
            put_nes(d_in);
        }
        get_nes();
        print_state();  // print
        usleep(10000);
    }
    print_state();
    printf("NES userspace program terminating\n\n");
    return 0;
}
