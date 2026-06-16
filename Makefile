IMAGE := picapsule

.PHONY: build test
build:
	docker build -t $(IMAGE) .

test:
	bash tests/scripts_pi_test.sh
