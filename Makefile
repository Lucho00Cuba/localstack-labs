# Define the color codes for output
YELLOW = \033[33m
GREEN = \033[32m
CYAN = \033[36m
RESET = \033[0m

export AWS_ACCESS_KEY_ID ?= test
export AWS_SECRET_ACCESS_KEY ?= test
export AWS_DEFAULT_REGION = us-east-1

ifneq (,$(wildcard ./.env))
    include .env
    export
endif

TARGETS := $(basename $(notdir $(wildcard scripts/*)))
TARGET := $(firstword $(MAKECMDGOALS))
TARGETS_FILES := $(wildcard scripts/*)

TF_ARGS := $(filter-out $(filter chdir=%,$(MAKEOVERRIDES)),$(MAKEOVERRIDES))

# Debugging: See the values of the variables
# $(info MAKECMDGOALS: $(MAKECMDGOALS))
# $(info MAKEOVERRIDES: $(MAKEOVERRIDES))
# $(info TF_ARGS: $(TF_ARGS))

.PHONY: help

all: help

NEEDS_CHDIR = init plan apply destroy

# Verificar que 'chdir' esté definido para ciertos comandos
ifneq ($(filter $(MAKECMDGOALS),$(NEEDS_CHDIR)),)
    ifeq ($(chdir),)
        $(error You must provide a source directory. Usage: make $(MAKECMDGOALS) chdir=path/to/source)
    endif
endif

define TERRAFORM_CMD
	terraform -chdir=$(chdir) $(1) $(TF_ARGS)
endef

## Terraform
init: ## Initialize Terraform
	$(call TERRAFORM_CMD,init)

plan: ## Plan Terraform
	$(call TERRAFORM_CMD,plan)

apply: ## Apply Terraform
	$(call TERRAFORM_CMD,apply -auto-approve)

destroy: ## Destroy Terraform
	$(call TERRAFORM_CMD,destroy -auto-approve)

### Help
help: ## Show this help.
	@echo ''
	@echo 'Usage:'
	@echo "  ${YELLOW}make${RESET} ${GREEN}<target>${RESET}"
	@echo ''
	@echo "${CYAN}Targets${RESET}"

	@# Print targets from scripts with comments
	@for target in $(TARGETS_FILES); do \
	        script_name=$$(basename $$target); \
	        description=$$(awk '/^## makefile:fmt/ {sub(/^## makefile:fmt /, ""); print $$0}' $$target); \
	        if [ -n "$$description" ]; then \
	                printf "    ${YELLOW}%-20s${GREEN}%s${RESET}\n" "$$script_name" "$$description"; \
	        fi; \
	done

	@# Print inline help from the Makefile itself
	@awk 'BEGIN {FS = ":.*?## "} { \
	        if (/^[a-zA-Z_-]+:.*?##.*$$/) { \
	                sub(/^## makefile:fmt /, ""); \
	                printf "    ${YELLOW}%-20s${GREEN}%s${RESET}\n", $$1, $$2; \
	        } \
	}' $(MAKEFILE_LIST)

### Ensure all scripts have execution permissions
ensure-permissions:
	@for script in scripts/*; do \
	    if [ ! -x $$script ]; then \
	        echo "Adding execute permissions to $$script"; \
	        chmod +x $$script; \
	    fi \
	done

%::
	@true

install: ## Install dependencies
	@which localstack || pip install localstack
	@which awslocal || pip install awscli-local
	@which terraform || (echo 'Terraform was not found';)
	@which tflocal || pip install terraform-local

$(TARGETS): ensure-permissions
	@./scripts/$@ $(ARGS)
