IMAGE := picapsule
UNAME_S := $(shell uname -s)
USER_UID := $(shell id -u)
USER_GID := $(shell gid=$$(id -g); if [ $$gid -lt 1000 ]; then echo 1000; else echo $$gid; fi)

.PHONY: build build/macos build/linux test

ifeq ($(UNAME_S),Darwin)
build: build/macos
else
build: build/linux
endif

build/macos:
	docker buildx build --platform linux/arm64 \
		--build-arg USER_UID=$(USER_UID) \
		--build-arg USER_GID=$(USER_GID) \
		-t $(IMAGE) --load .

build/linux:
	docker buildx build --platform linux/amd64 \
		--build-arg USER_UID=$(USER_UID) \
		--build-arg USER_GID=$(USER_GID) \
		-t $(IMAGE) --load .

test:
	bash tests/scripts_pi_test.sh
	bash tests/docker_entrypoint_test.sh
