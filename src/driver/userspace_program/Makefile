CC=arm-linux-gnueabihf-gcc
CFLAGS=-Wall -O2

all: nes nes2

nes2: nes2.c
	$(CC) $(CFLAGS) $(LDFLAGS) $< -o $@


nes: nes.c
	$(CC) $(CFLAGS) $(LDFLAGS) $< -o $@

clean:
	rm -f nes
