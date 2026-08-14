COMPOSE = docker compose

DEV = $(COMPOSE) \
	-p platform-dev \
	-f compose.yaml \
	-f compose.dev.yaml

TEST = $(COMPOSE) \
	-p platform-test \
	-f compose.yaml \
	-f compose.test.yaml

STAGING = $(COMPOSE) \
	-p platform-staging \
	-f compose.yaml \
	-f compose.staging.yaml

PROD = $(COMPOSE) \
	-p platform-prod \
	-f compose.yaml \
	-f compose.prod.yaml

dev:
	$(DEV) up

dev-build:
	$(DEV) build

dev-down:
	$(DEV) down

dev-remove-all:
	$(DEV) down && down -v

dev-logs:
	$(DEV) logs -f

dev-shell:
	$(DEV) exec web bash

dev-restart:
	$(DEV) restart

# -------------------------
# Django
# -------------------------

django:
	$(DEV) exec web python manage.py $(CMD)

migrate:
	$(DEV) exec web python manage.py migrate

makemigrations:
	$(DEV) exec web python manage.py makemigrations

createsuperuser:
	$(DEV) exec web python manage.py createsuperuser

shell:
	$(DEV) exec web python manage.py shell

setup:
	$(DEV) exec web python manage.py setup

# -------------------------
# Tests
# -------------------------

test:
	$(TEST) run --rm web pytest

test-cov:
	$(TEST) run --rm web pytest \
		--cov=src/apps \
		--cov-report=term-missing \
		--cov-report=html:htmlcov \
		--cov-config=.coveragerc


# Pull ollama model
pullollamamodel:
	docker exec platform_ollama ollama pull qwen3:1.7b

# -------------------------
# Utilities
# -------------------------

pip-audit:
	$(DEV) exec web pip-audit \
		-r ./requirements/development.txt