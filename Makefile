all: build
	docker-compose build

build:
	docker-compose build

start:
	docker-compose up hugo

ru:
	docker-compose run --rm hugo hugo
	docker-compose run --rm s3-website-ru s3_website push

en:
	docker-compose run --rm hugo hugo
	docker-compose run --rm s3-website-en s3_website push
