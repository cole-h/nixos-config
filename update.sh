#!/usr/bin/env bash
nix flake update \
	--update-input large \
	--update-input nix \
	--update-input home \
	--update-input passrs \
	--update-input wayland \
	--update-input alacritty \
	--update-input doom \
	--update-input nixus
