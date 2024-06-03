compose:
	docker compose build --no-cache
build:
	./src/build.sh
start:
	docker compose up -d
logs:
	docker logs scratch
restart:
	make build && make start
multiarch-install:
	./src/multiarch-install.sh
login:
	./src/login.sh
test:
	./src/tests/run.sh