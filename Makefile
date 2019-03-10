include .env

.PHONY: up down stop prune ps shell drush logs build clean site-install build build-fe build-fe build-fe-install
.PHONY: build-fe-generate

default: up

APP_ROOT ?= /var/www/html
DRUPAL_ROOT ?= $(APP_ROOT)/docroot
DRUPAL_SITE_DIR ?= $(DRUPAL_ROOT)/sites/default
SMG_THEME ?= $(DRUPAL_ROOT)/themes/smg

up:
	@echo "Starting up containers for $(PROJECT_NAME)..."
	docker-compose pull
	docker-compose up -d --remove-orphans

down: stop

stop:
	@echo "Stopping containers for $(PROJECT_NAME)..."
	@docker-compose stop

prune:
	@echo "Removing containers for $(PROJECT_NAME)..."
	@docker-compose down -v

ps:
	@docker ps --filter name='$(PROJECT_NAME)*'

shell:
	docker exec -ti -e COLUMNS=$(shell tput cols) -e LINES=$(shell tput lines) $(shell docker ps --filter name='$(PROJECT_NAME)_php' --format "{{ .ID }}") sh

shell-node:
	docker exec -ti -e COLUMNS=$(shell tput cols) -e LINES=$(shell tput lines) $(shell docker ps --filter name='$(PROJECT_NAME)_node' --format "{{ .ID }}") sh

drush:
	docker exec $(shell docker ps --filter name='$(PROJECT_NAME)_php' --format "{{ .ID }}") drush -r $(DRUPAL_ROOT) $(filter-out $@,$(MAKECMDGOALS))

logs:
	@docker-compose logs -f $(filter-out $@,$(MAKECMDGOALS))

build: build-fe build-be

build-fe: build-fe-install build-fe-generate

build-fe-install:
	@docker-compose exec node npm install

build-fe-generate:
	@docker-compose exec node npx gulp

build-be:
	@docker-compose exec php composer install

# It feels a little silly using docker to kill files (and weird to use the php
# container to kill node_modules - but it works for now).
clean:
	@docker-compose exec php bash -c "composer clearcache; \
		rm -rf 	$(APP_ROOT)/vendor \
				$(DRUPAL_ROOT)/core \
				$(DRUPAL_ROOT)/profiles \
				$(DRUPAL_ROOT)/modules/contrib \
				$(DRUPAL_ROOT)/themes/contrib \
				$(DRUPAL_ROOT)/themes/contrib \
				$(SMG_THEME)/node_modules"

site-install:
	@docker-compose exec php bash -c "chmod +w $(DRUPAL_ROOT)/sites/default $(DRUPAL_ROOT)/sites/default/settings.php"
	@time docker-compose exec php \
		drush site-install --verbose --account-pass=admin --yes \
			config_installer config_installer_sync_configure_form.sync_directory=$(APP_ROOT)/config

# https://stackoverflow.com/a/6273809/1826109
%:
	@:
