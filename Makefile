
version ?= latest

build:
	docker build --tag crukcibioinformatics/shiny-base:${version} .

release: build
	docker push crukcibioinformatics/shiny-base:${version}

singularity: build
	singularity build shiny-base-${version}.sif docker-daemon://crukcibioinformatics/shiny-base:${version}

