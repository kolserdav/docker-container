compose:
	docker compose build --no-cache
build:
	./src/scripts/build.sh
start:
	docker compose up -d
logs:
	docker logs scratch
restart:
	make build && make start
rootfs:
	./src/scripts/create-rootfs.sh $(RELEASE)
remount:
	./src/scripts/remount.sh
multiarch-install:
	./src/scripts/multiarch-install.sh
login:
	./src/scripts/login.sh
test:
	docker build ./tests