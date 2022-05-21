
version ?= latest

build:
	docker build --tag crukcibioinformatics/shiny-base:${version} .

release: build
	docker push crukcibioinformatics/shiny-base:${version}

singularity: build
	singularity build shiny-base-${version}.sif docker-daemon://crukcibioinformatics/shiny-base:${version}

shell:
	mkdir -p logs lib/bookmarks/shiny apps
	chmod -R ugo+rwx lib logs
	docker run \
		--user shiny \
		--interactive \
		--tty \
		--rm \
		--entrypoint=bash \
		--volume ${PWD}/shiny-server.conf:/etc/shiny-server/shiny-server.conf \
		--volume ${PWD}/lib:/var/lib/shiny-server \
		--volume ${PWD}/logs:/var/log/shiny-server \
		--volume ${PWD}/apps:/srv/shiny-server/apps \
		crukcibioinformatics/shiny-base:${version}

start:
	rm -rf logs
	mkdir -p logs lib/bookmarks/shiny apps
	chmod -R ugo+rwx lib logs
	docker run \
		--user shiny \
		--detach \
		--rm \
		--name shiny_server \
		--publish 8080:3838 \
		--volume ${PWD}/shiny-server.conf:/etc/shiny-server/shiny-server.conf \
		--volume ${PWD}/lib:/var/lib/shiny-server \
		--volume ${PWD}/logs:/var/log/shiny-server \
		--volume ${PWD}/apps:/srv/shiny-server/apps \
		crukcibioinformatics/shiny-base:${version}

stop:
	docker stop shiny_server

