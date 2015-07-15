CC = gcc
PREFIX = /usr/local
BUILD = build
SRC = src
CFLAGS = -D _GNU_SOURCE -fPIC
BINARY = $(BUILD)/amath
TEST = $(BUILD)/test
LIBRARY = $(BUILD)/libamath.so
SOURCES = $(wildcard $(SRC)/*.c)
HEADERS = $(wildcard $(SRC)/*.h)
OBJECTS = $(patsubst $(SRC)/%.c,$(BUILD)/%.o,$(SOURCES))

all: $(LIBRARY) $(BINARY) $(TEST)

test: $(TEST)

install: $(LIBRARY) $(BINARY)
	install -m 0755 $(BINARY) $(PREFIX)/bin
	install -m 0755 $(LIBRARY) $(PREFIX)/lib
	install -m 0644 $(SRC)/amath.h $(PREFIX)/include

uninstall:
	rm -f $(PREFIX)/bin/amath
	rm -f $(PREFIX)/lib/libamath.so
	rm -f $(PREFIX)/include/amath.h

$(SRC)/parser.c: $(SRC)/parser.y
	lemon $<

$(SRC)/scanner.c: $(SRC)/scanner.re
	re2c $< > $@

$(TEST): $(LIBRARY)
	$(CC) test/test.c -o $(TEST) -L$(BUILD) -lamath

$(BINARY): $(OBJECTS)
	$(CC) -o $(BINARY) $(OBJECTS)

$(LIBRARY): $(OBJECTS)
	$(CC) -shared -o $(LIBRARY) $(OBJECTS)

$(BUILD)/%.o: $(SRC)/%.c $(BUILD)
	$(CC) $(CFLAGS) -c $< -o $@

$(BUILD):
	mkdir -p $(BUILD)

clean:
	rm -rf $(BUILD)

.PHONY: all install uninstall clean
