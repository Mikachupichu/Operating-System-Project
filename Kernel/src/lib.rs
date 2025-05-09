#![no_std]
pub mod Kernel {
    use core::panic::PanicInfo;
    #[no_mangle]
    pub extern "C" fn kernel_main() -> ! {
        let color_byte = 0x0A;
        let vga_buffer = 0xb8000 as *mut u8;
        let message = b"Rust Kernel Loaded!";
        let mut offset = 0;
        for &byte in message {
            unsafe {
                *vga_buffer.add(offset * 2) = byte;
                *vga_buffer.add(offset * 2 + 1) = color_byte;
            }
            offset += 1;
        }
        loop {}
    }
    #[panic_handler]
    fn panic(info: &PanicInfo) -> ! {
        let _ = info.message();
        loop {}
    }
}