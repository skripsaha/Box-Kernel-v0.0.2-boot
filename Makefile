# BoxOS Makefile - исправленная версия

ASM = nasm
CC = gcc
LD = ld
OBJCOPY = objcopy
QEMU = qemu-system-x86_64

ASMFLAGS = -f bin
ASMFLAGS_ELF = -f elf64
CFLAGS = -m64 -ffreestanding -nostdlib -fno-builtin -fno-stack-protector -mno-red-zone -mno-mmx -mno-sse -mno-sse2 -fno-pie -fno-pic -mcmodel=large
LDFLAGS = -T src/kernel/linker.ld -nostdlib -z max-page-size=0x1000 --oformat=binary

SRCDIR = src
BUILDDIR = build
BOOTDIR = $(SRCDIR)/boot
KERNELDIR = $(SRCDIR)/kernel

STAGE1_SRC = $(BOOTDIR)/stage1/stage1.asm
STAGE2_SRC = $(BOOTDIR)/stage2/stage2.asm
KERNEL_ENTRY_SRC = $(KERNELDIR)/kernel_entry.asm
KERNEL_SRC = $(KERNELDIR)/kernel.c

STAGE1_BIN = $(BUILDDIR)/stage1.bin
STAGE2_BIN = $(BUILDDIR)/stage2.bin
KERNEL_ENTRY_OBJ = $(BUILDDIR)/kernel_entry.o
KERNEL_OBJ = $(BUILDDIR)/kernel.o
KERNEL_BIN = $(BUILDDIR)/kernel.bin
IMAGE = $(BUILDDIR)/boxos.img

.PHONY: all clean run debug info check-deps

all: check-deps $(IMAGE)

check-deps:
	@echo "Checking dependencies..."
	@which $(ASM) > /dev/null || (echo "ERROR: nasm not found. Install with: sudo apt install nasm" && exit 1)
	@which $(CC) > /dev/null || (echo "ERROR: gcc not found. Install with: sudo apt install gcc" && exit 1)
	@which $(LD) > /dev/null || (echo "ERROR: ld not found. Install with: sudo apt install binutils" && exit 1)
	@which $(QEMU) > /dev/null || (echo "ERROR: qemu not found. Install with: sudo apt install qemu-system-x86" && exit 1)
	@echo "All dependencies found!"

$(BUILDDIR):
	mkdir -p $(BUILDDIR)

$(STAGE1_BIN): $(STAGE1_SRC) | $(BUILDDIR)
	@echo "Building Stage1..."
	$(ASM) $(ASMFLAGS) $< -o $@
	@echo "Stage1 size: $$(stat -c%s $@) bytes"

$(STAGE2_BIN): $(STAGE2_SRC) | $(BUILDDIR)
	@echo "Building Stage2..."
	$(ASM) $(ASMFLAGS) $< -o $@
	@echo "Stage2 size: $$(stat -c%s $@) bytes"

$(KERNEL_ENTRY_OBJ): $(KERNEL_ENTRY_SRC) | $(BUILDDIR)
	@echo "Building kernel entry..."
	$(ASM) $(ASMFLAGS_ELF) $< -o $@

$(KERNEL_OBJ): $(KERNEL_SRC) | $(BUILDDIR)
	@echo "Building kernel..."
	$(CC) $(CFLAGS) -c $< -o $@

$(KERNEL_BIN): $(KERNEL_ENTRY_OBJ) $(KERNEL_OBJ)
	@echo "Linking kernel..."
	$(LD) $(LDFLAGS) $^ -o $@
	@echo "Kernel size: $$(stat -c%s $@) bytes"

$(IMAGE): $(STAGE1_BIN) $(STAGE2_BIN) $(KERNEL_BIN)
	@echo "Creating disk image..."
	
	# Создание образа диска (10MB для больших ядер)
	dd if=/dev/zero of=$@ bs=512 count=20480 2>/dev/null
	
	# Запись Stage1 (MBR)
	dd if=$(STAGE1_BIN) of=$@ bs=512 count=1 conv=notrunc 2>/dev/null
	
	# Запись Stage2 (сектора 2-10)  
	dd if=$(STAGE2_BIN) of=$@ bs=512 seek=1 conv=notrunc 2>/dev/null
	
	# Запись ядра (сектора 11+)
	dd if=$(KERNEL_BIN) of=$@ bs=512 seek=10 conv=notrunc 2>/dev/null
	
	@echo "Disk image created: $(IMAGE)"
	@echo "Image size: $$(stat -c%s $@) bytes"

run: $(IMAGE)
	@echo "Starting BoxOS in QEMU..."
	$(QEMU) -drive format=raw,file=$(IMAGE) -m 512M -serial stdio -no-reboot -no-shutdown
# $(QEMU) -drive format=raw,file=$(IMAGE) -m 512M -serial stdio -no-reboot -no-shutdown

debug: $(IMAGE)
	@echo "Starting BoxOS in QEMU with debugger..."
	$(QEMU) -drive format=raw,file=$(IMAGE) -m 512M -serial stdio -s -S


clean:
	@echo "Cleaning build directory..."
	rm -rf $(BUILDDIR)/*
	@echo "Clean complete!"

install-deps:
	@echo "Installing dependencies..."
	sudo apt update
	sudo apt install -y nasm gcc binutils qemu-system-x86 make
	@echo "Dependencies installed!"

info:
	@echo "BoxOS Build System"
	@echo "=================="
	@echo "Targets:"
	@echo "  all         - Build complete OS image"
	@echo "  run         - Build and run in QEMU"
	@echo "  debug       - Build and run in QEMU with GDB server"
	@echo "  clean       - Clean build directory"
	@echo "  install-deps- Install required dependencies"
	@echo "  check-deps  - Check if dependencies are installed"
	@echo "  info        - Show this information"
	@echo ""
	@echo "Files:"
	@echo "  $(IMAGE) - Bootable disk image"
	@echo "  $(STAGE1_BIN) - Stage1 bootloader (512 bytes)"
	@echo "  $(STAGE2_BIN) - Stage2 bootloader"
	@echo "  $(KERNEL_BIN) - Kernel binary"