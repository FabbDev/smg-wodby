include .env

.PHONY: up down stop prune ps shell drush logs

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

drush:
	docker exec $(shell docker ps --filter name='$(PROJECT_NAME)_php' --format "{{ .ID }}") drush -r $(DRUPAL_ROOT) $(filter-out $@,$(MAKECMDGOALS))

logs:
	@docker-compose logs -f $(filter-out $@,$(MAKECMDGOALS))

build:
	@docker-compose exec php composer install

site-install:
#	@docker-compose exec --user www-data php drush -y si --account-pass=admin --config-dir=../config numiko_media
	@docker-compose exec php bash -c "chmod +w $(DRUPAL_ROOT)/sites/default $(DRUPAL_ROOT)/sites/default/settings.php"
	@time docker-compose exec php drush site-install --verbose config_installer config_installer_sync_configure_form.sync_directory=$(APP_ROOT)/config --yes

# https://stackoverflow.com/a/6273809/1826109
%:
	@:
