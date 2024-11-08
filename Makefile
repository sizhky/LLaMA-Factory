.PHONY: build commit quality style test

check_dirs := scripts src tests setup.py

build:
	pip install build && python -m build

commit:
	pre-commit install
	pre-commit run --all-files

quality:
	ruff check $(check_dirs)
	ruff format --check $(check_dirs)

style:
	ruff check $(check_dirs) --fix
	ruff format $(check_dirs)

test:
	CUDA_VISIBLE_DEVICES= WANDB_DISABLED=true pytest -vv tests/

train-micro:
	MLFLOW_TRACKING_URI=http://127.0.0.1:3333 MLFLOW_ENABLE_SYSTEM_METRICS_LOGGING=true llamafactory-cli train examples/train_lora/gommt-micro.yaml

train-nano:
	MLFLOW_TRACKING_URI=http://127.0.0.1:3333 MLFLOW_ENABLE_SYSTEM_METRICS_LOGGING=true llamafactory-cli train examples/train_lora/gommt-nano.yaml

train-full:
	MLFLOW_TRACKING_URI=http://127.0.0.1:3333 MLFLOW_ENABLE_SYSTEM_METRICS_LOGGING=true llamafactory-cli train examples/train_lora/gommt-full.yaml

LANGFUSE_PORT ?= 3535

setup-langfuse:
	@if [ -z "$(LANGFUSE_PORT)" ]; then \
		echo "Error: LANGFUSE_PORT is not set. Use --LANGFUSE_port to specify the LANGFUSE_port."; \
		exit 1; \
	fi
	docker run --name langfuse \
		-e DATABASE_URL=postgresql://langfuse-pg \
		-e NEXTAUTH_URL=http://localhost:3434 \
		-e NEXTAUTH_SECRET=mysecret \
		-e SALT=mysalt \
		-e ENCRYPTION_KEY=lskdjfmlsdkfjiowerwomeklskdfmsldkfjsofsldmfsldfkm \
		-p $(LANGFUSE_PORT):3535 \
		-a STDOUT \
		langfuse/langfuse

