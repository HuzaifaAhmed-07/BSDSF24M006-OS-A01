CC = gcc
CFLAGS = -Wall -Wextra -Iinclude
AR = ar
ARFLAGS = rcs

SRC_DIR = src
OBJ_DIR = obj
BIN_DIR = bin
LIB_DIR = lib

# Source files
LIB_SRCS = $(SRC_DIR)/mystrfunctions.c $(SRC_DIR)/myfilefunctions.c
LIB_OBJS = $(OBJ_DIR)/mystrfunctions.o $(OBJ_DIR)/myfilefunctions.o
DRIVER_SRC = $(SRC_DIR)/main.c

# Static library and binary targets
STATIC_LIB = $(LIB_DIR)/libmyutils.a
STATIC_BIN = $(BIN_DIR)/client_static
MULTIFILE_BIN = $(BIN_DIR)/client

.PHONY: all clean static

all: static

# Feature 3: Static library build
static: $(STATIC_BIN)

$(STATIC_BIN): $(DRIVER_SRC) $(STATIC_LIB) | $(BIN_DIR)
	$(CC) $(CFLAGS) $(DRIVER_SRC) -L$(LIB_DIR) -lmyutils -o $@

$(STATIC_LIB): $(LIB_OBJS) | $(LIB_DIR)
	$(AR) $(ARFLAGS) $@ $^

# Feature 2 fallback: Multi-file build target
multifile: $(MULTIFILE_BIN)

$(MULTIFILE_BIN): $(LIB_OBJS) $(OBJ_DIR)/main.o | $(BIN_DIR)
	$(CC) $(CFLAGS) $^ -o $@

$(OBJ_DIR)/%.o: $(SRC_DIR)/%.c | $(OBJ_DIR)
	$(CC) $(CFLAGS) -c $< -o $@

$(BIN_DIR) $(OBJ_DIR) $(LIB_DIR):
	mkdir -p $@

clean:
	rm -rf $(OBJ_DIR)/*.o $(BIN_DIR)/* $(LIB_DIR)/*