use std::env;
fn main() {
    let target = env::var("TARGET").unwrap();
    if target == "i686-unknown-none" {
        println!("cargo:rustc-link-arg=-melf_i386");
        println!("cargo:rustc-link-arg=-Ttext=0x00010000");
        println!("cargo:rustc-link-arg=-entry");
        println!("cargo:rustc-link-arg=_start");
        println!("cargo:rustc-link-arg=-nostdlib");
    }
}