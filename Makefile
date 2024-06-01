build:
	docker compose build --no-cache
start:
	docker compose up -d
logs:
	docker logs scratch
restart:
	make build && make start
rootfs:
	./src/scripts/create-root-fs.sh
remount:
	./src/scripts/remount.sh