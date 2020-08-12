VER := 5
TAG := starlabio/docker-centos6-native-build:$(VER)

ADD_USER_TO_SUDOERS_BIN := add_user_to_sudoers/target/x86_64-unknown-linux-musl/release/add_user_to_sudoers

.PHONY: all build
all build: $(ADD_USER_TO_SUDOERS_BIN)
	docker build . --tag $(TAG)

$(ADD_USER_TO_SUDOERS_BIN): $(addprefix add_user_to_sudoers/,Cargo.lock Cargo.toml src/main.rs)
	./hooks/pre_build

.PHONY: clean
clean:
	cd add_user_to_sudoers && cargo clean

docker-shell: DOCKER_IMAGE := $(TAG)
docker-shell:
	$(DOCKER_SHELL_CMD)

include Docker.mk
