BOOTLOADER = Bootloader.asm
BOOTLOADER_BIN = Bootloader.bin
KERNEL_DIR = Kernel
KERNEL_ELF = $(KERNEL_DIR)/target/i686-unknown-linux-gnu/release/Kernel
KERNEL_BIN = $(KERNEL_DIR)/Kernel.bin
DISK_IMG = disk.img
.PHONY: all clean
all: $(DISK_IMG)
$(BOOTLOADER_BIN): $(BOOTLOADER)
	nasm $< -f bin -o $@
$(KERNEL_BIN): $(KERNEL_DIR)/Cargo.toml
	cd $(KERNEL_DIR) && cargo build --target i686-unknown-linux-gnu --release
	/opt/homebrew/opt/llvm/bin/llvm-objcopy -O binary $(KERNEL_ELF) $(KERNEL_BIN)
$(DISK_IMG): $(BOOTLOADER_BIN) $(KERNEL_BIN)
	dd if=/dev/zero of=$(DISK_IMG) bs=512 count=4096
	dd if=$(BOOTLOADER_BIN) of=$(DISK_IMG) conv=notrunc
	dd if=$(KERNEL_BIN) of=$(DISK_IMG) seek=1 conv=notrunc
clean:
	rm -f $(BOOTLOADER_BIN) $(DISK_IMG) $(KERNEL_BIN)
	cd $(KERNEL_DIR) && cargo clean