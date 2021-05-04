
version ?= latest

build:
	docker build --tag crukcibioinformatics/shiny-base:${version} .

release: build
	docker push crukcibioinformatics/shiny-base:${version}

