all: build run

build:
	docker build -t osdev-image .

run:
	docker run --name osdev-container -it --rm osdev-image "-c" \
	    "timeout --preserve-status 5s qemu-system-i386 -nographic -curses -kernel myos.bin"

shell:
	docker run --name osdev-container -it --rm osdev-image
