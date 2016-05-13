CC=arm-linux-gnueabihf-gcc
CFLAGS=-Wall -O2

all: write read start

write: write.c
	$(CC) $(CFLAGS) $(LDFLAGS) $< -o $@

read: read.c

start: start.c

clean:
	rm -f write start read
