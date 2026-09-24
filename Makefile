CC = gcc
CFLAGS = -Wall -Wextra -Iinclude
PIC_FLAGS = -fPIC
AR = ar
ARFLAGS = rcs

SRC_DIR = src
OBJ_DIR = obj
BIN_DIR = bin
LIB_DIR = lib

# Source files
LIB_SRCS = $(SRC_DIR)/mystrfunctions.c $(SRC_DIR)/myfilefunctions.c
STATIC_OBJS = $(OBJ_DIR)/mystrfunctions.o $(OBJ_DIR)/myfilefunctions.o
PIC_OBJS = $(OBJ_DIR)/mystrfunctions_pic.o $(OBJ_DIR)/myfilefunctions_pic.o
DRIVER_SRC = $(SRC_DIR)/main.c

# Artifacts
STATIC_LIB = $(LIB_DIR)/libmyutils.a
STATIC_BIN = $(BIN_DIR)/client_static

DYNAMIC_LIB = $(LIB_DIR)/libmyutils.so
DYNAMIC_BIN = $(BIN_DIR)/client_dynamic

MULTIFILE_BIN = $(BIN_DIR)/client

.PHONY: all clean static dynamic multifile

all: dynamic

# Feature 4: Dynamic library target
dynamic: $(DYNAMIC_BIN)

$(DYNAMIC_BIN): $(DRIVER_SRC) $(DYNAMIC_LIB) | $(BIN_DIR)
	$(CC) $(CFLAGS) $(DRIVER_SRC) -L$(LIB_DIR) -lmyutils -o $@

$(DYNAMIC_LIB): $(PIC_OBJS) | $(LIB_DIR)
	$(CC) -shared -o $@ $^

$(OBJ_DIR)/%_pic.o: $(SRC_DIR)/%.c | $(OBJ_DIR)
	$(CC) $(CFLAGS) $(PIC_FLAGS) -c $< -o $@

# Feature 3: Static library target
static: $(STATIC_BIN)

$(STATIC_BIN): $(DRIVER_SRC) $(STATIC_LIB) | $(BIN_DIR)
	$(CC) $(CFLAGS) $(DRIVER_SRC) -L$(LIB_DIR) -lmyutils -o $@

$(STATIC_LIB): $(STATIC_OBJS) | $(LIB_DIR)
	$(AR) $(ARFLAGS) $@ $^

# Feature 2: Multi-file target
multifile: $(MULTIFILE_BIN)

$(MULTIFILE_BIN): $(STATIC_OBJS) $(OBJ_DIR)/main.o | $(BIN_DIR)
	$(CC) $(CFLAGS) $^ -o $@

$(OBJ_DIR)/%.o: $(SRC_DIR)/%.c | $(OBJ_DIR)
	$(CC) $(CFLAGS) -c $< -o $@

$(BIN_DIR) $(OBJ_DIR) $(LIB_DIR):
	mkdir -p $@

clean:
	rm -rf $(OBJ_DIR)/*.o $(BIN_DIR)/* $(LIB_DIR)/*