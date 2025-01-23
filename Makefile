build: build-tools

build-tools:
	

install:
	sudo cp scripts/* /usr/local/bin/

link-install:
	sudo ln -s "$(pwd)/scripts/"* /usr/local/bin/