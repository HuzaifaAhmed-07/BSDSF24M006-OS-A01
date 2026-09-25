CC = gcc
CFLAGS = -Wall -Wextra -Iinclude
PIC_FLAGS = -fPIC
AR = ar
ARFLAGS = rcs

SRC_DIR = src
OBJ_DIR = obj
BIN_DIR = bin
LIB_DIR = lib
MAN_DIR = man/man3
INC_DIR = include

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

# ---- Installation locations (Feature 5) ----
PREFIX     ?= /usr/local
INSTALL_BIN = $(PREFIX)/bin
INSTALL_LIB = $(PREFIX)/lib
INSTALL_INC = $(PREFIX)/include/myutils
INSTALL_MAN = $(PREFIX)/share/man/man3

MAN_PAGES = $(MAN_DIR)/mycat.3 $(MAN_DIR)/myfile_stats.3 $(MAN_DIR)/mygrep.3 \
            $(MAN_DIR)/mystrlen.3 $(MAN_DIR)/mystrrev.3 $(MAN_DIR)/mystrcmp.3 \
            $(MAN_DIR)/mywordcount.3

.PHONY: all clean static dynamic multifile install uninstall

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
	$(CC) $(CFLAGS) $(DRIVER_SRC) $(STATIC_LIB) -o $@

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

# ---- Feature 5: Installation ----
install: dynamic static
	@echo "Installing libmyutils to $(PREFIX) ..."
	install -d $(INSTALL_BIN) $(INSTALL_LIB) $(INSTALL_INC) $(INSTALL_MAN)
	install -m 755 $(DYNAMIC_BIN) $(INSTALL_BIN)/client
	install -m 755 $(DYNAMIC_LIB) $(INSTALL_LIB)/
	install -m 644 $(STATIC_LIB) $(INSTALL_LIB)/
	install -m 644 $(INC_DIR)/*.h $(INSTALL_INC)/
	install -m 644 $(MAN_PAGES) $(INSTALL_MAN)/
	ldconfig
	@echo "Installed. Run 'client' or 'man mycat' to verify."

uninstall:
	@echo "Removing libmyutils from $(PREFIX) ..."
	rm -f $(INSTALL_BIN)/client
	rm -f $(INSTALL_LIB)/libmyutils.a $(INSTALL_LIB)/libmyutils.so
	rm -rf $(INSTALL_INC)
	rm -f $(addprefix $(INSTALL_MAN)/,$(notdir $(MAN_PAGES)))
	ldconfig
	@echo "Uninstalled."

clean:
	rm -rf $(OBJ_DIR)/*.o $(BIN_DIR)/* $(LIB_DIR)/*
