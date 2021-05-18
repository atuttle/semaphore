test: .server-running
	box testbox run

watch: .server-running
	box testbox watch

clean:
	box server forget semaphoreTests

down:
	box server stop directory="tests" serverConfigFile="tests/server.json"
	rm -f .server-running

.server-running:
	box server start directory="tests" serverConfigFile="tests/server.json"
	touch .server-running

up: .server-running

start: up

stop: down
