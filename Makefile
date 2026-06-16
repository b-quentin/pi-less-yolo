IMAGE := picapsule
UNAME_S := $(shell uname -s)

.PHONY: build build/macos build/linux test

ifeq ($(UNAME_S),Darwin)
build: build/macos
else
build: build/linux
endif

build/macos:
	docker buildx build --platform linux/arm64 -t $(IMAGE) --load .

build/linux:
	docker buildx build --platform linux/amd64 -t $(IMAGE) --load .

test:
	bash tests/scripts_pi_test.sh
	bash tests/docker_entrypoint_test.sh
