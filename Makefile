
host ?= 

clean:
	@rm -f result

build: clean 
	@nix flake update
	@nixos-rebuild build --flake ".#${host}"

build-vm: build
	nixos-rebuild build-vm --flake ".#${host}"

start-vm: build-vm
	./result/bin/run-*-vm -m 8192

switch: clean
	@nixos-rebuild switch --use-remote-sudo --flake ".#${host}"

pre-update:
	@nix flake update
	@./install/vscode-extention-tool update > ./modules/env/programs/vscode/vscode-extensions.nix
#	@if $(shell git status modules/env/programs/vscode/vscode-extensions.nix --porcelain | grep -qE '^ M'); then
#		git add modules/env/programs/vscode/vscode-extensions.nix
#	fi

#	git commit -m"update"
	
update: pre-update switch
	
  
