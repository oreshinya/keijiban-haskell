build:
	docker-compose build

migrate:
	docker-compose run app stack exec moo-mysql upgrade

up:
	docker-compose up
