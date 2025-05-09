#![no_std]
#![no_main]
extern crate Kernel;
#[no_mangle]
extern "C" fn _start() -> ! {crate::Kernel::Kernel::kernel_main()}