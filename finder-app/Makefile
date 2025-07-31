# Name of the output binary
TARGET = writer

# Source file
SRC = writer.c

# Cross-compiler (change this to your actual toolchain if needed)
CC ?= gcc

# Compilation flags
CFLAGS = -Wall -Wextra -std=c11

# Install path (optional, used if you run `make install`)
DESTDIR ?= /usr/bin

.PHONY: all clean install

all: $(TARGET)

$(TARGET): $(SRC)
	$(CC) $(CFLAGS) -o $@ $^

install: $(TARGET)
	cp $(TARGET) $(DESTDIR)/$(TARGET)

clean:
	rm -f $(TARGET)

