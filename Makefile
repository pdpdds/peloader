GPPPARAMS = -m32 -fno-use-cxa-atexit -nostdlib -fno-builtin -fno-rtti -fno-exceptions -fno-leading-underscore -fno-pic -fno-pie
ASPARAMS = -f elf

objects = kmain.o
%.o: %.cpp
	g++ $(GPPPARAMS) -o $@ -c $<

%.o: %.asm
	nasm $(ASPARAMS) -o $@ $<
	
kernel.exe: $(objects)
	ld -m i386pe -entry kmain -o $@ $(objects)

install: kernel.exe
	cp $< /boot/kernel.exe
	
kernel.iso: kernel.exe
	mkdir iso
	mkdir iso/boot
	mkdir iso/boot/grub
	cp $< iso/boot/
	echo 'set timeout-0' >> iso/boot/grub/grub.cfg
	echo 'set default-0' >> iso/boot/grub/grub.cfg
	echo 'menuentry "YUZA OS"{' >> iso/boot/grub/grub.cfg
	echo '  multiboot /boot/kernel.exe' >> iso/boot/grub/grub.cfg
	echo ' boot' >> iso/boot/grub/grub.cfg
	echo '}' >> iso/boot/grub/grub.cfg
	grub-mkrescue --output=$@ iso
	rm -rf iso 
	
run: kernel.iso
	(killall VirtualBox && sleep 1) || true
	VirtualBox --startvm "YUZA OS" &

clean:
	rm -f kernel.exe
	rm -f kmain.o
	rm -rf iso
	
