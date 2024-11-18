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

MLFLOW_TRACKING_URI ?= http://184.105.4.49:8071/mlflow
MLFLOW_ENABLE_SYSTEM_METRICS_LOGGING = true

train-nano:
	MLFLOW_TRACKING_URI=$(MLFLOW_TRACKING_URI) MLFLOW_ENABLE_SYSTEM_METRICS_LOGGING=$(MLFLOW_ENABLE_SYSTEM_METRICS_LOGGING) llamafactory-cli train examples/train_lora/gommt-nano.yaml

train-micro:
	MLFLOW_TRACKING_URI=$(MLFLOW_TRACKING_URI) MLFLOW_ENABLE_SYSTEM_METRICS_LOGGING=$(MLFLOW_ENABLE_SYSTEM_METRICS_LOGGING) llamafactory-cli train examples/train_lora/gommt-micro.yaml

train-full:
	MLFLOW_TRACKING_URI=$(MLFLOW_TRACKING_URI) MLFLOW_ENABLE_SYSTEM_METRICS_LOGGING=$(MLFLOW_ENABLE_SYSTEM_METRICS_LOGGING) llamafactory-cli train examples/train_lora/gommt-full.yaml
	
train-zeroshot:
	MLFLOW_TRACKING_URI=$(MLFLOW_TRACKING_URI) MLFLOW_ENABLE_SYSTEM_METRICS_LOGGING=$(MLFLOW_ENABLE_SYSTEM_METRICS_LOGGING) llamafactory-cli train examples/train_lora/gommt-zeroshot.yaml

train-oneshot:
	# MLFLOW_TRACKING_URI=$(MLFLOW_TRACKING_URI) MLFLOW_ENABLE_SYSTEM_METRICS_LOGGING=$(MLFLOW_ENABLE_SYSTEM_METRICS_LOGGING) 
	CLEARML_PROJECT=gommt/llama3.2-oneshot-full llamafactory-cli train examples/train_lora/gommt-oneshot.yaml

train-twoshot:
	MLFLOW_TRACKING_URI=$(MLFLOW_TRACKING_URI) MLFLOW_ENABLE_SYSTEM_METRICS_LOGGING=$(MLFLOW_ENABLE_SYSTEM_METRICS_LOGGING) llamafactory-cli train examples/train_lora/gommt-twoshot.yaml


train-qwens:
	# MLFLOW_TRACKING_URI=$(MLFLOW_TRACKING_URI) MLFLOW_ENABLE_SYSTEM_METRICS_LOGGING=$(MLFLOW_ENABLE_SYSTEM_METRICS_LOGGING) llamafactory-cli train examples/train_lora/gommt-oneshot-qwen-0.5B.yaml
	MLFLOW_TRACKING_URI=$(MLFLOW_TRACKING_URI) MLFLOW_ENABLE_SYSTEM_METRICS_LOGGING=$(MLFLOW_ENABLE_SYSTEM_METRICS_LOGGING) llamafactory-cli train examples/train_lora/gommt-oneshot-qwen-1.5B.yaml
	# MLFLOW_TRACKING_URI=$(MLFLOW_TRACKING_URI) MLFLOW_ENABLE_SYSTEM_METRICS_LOGGING=$(MLFLOW_ENABLE_SYSTEM_METRICS_LOGGING) llamafactory-cli train examples/train_lora/gommt-oneshot-qwen-7B.yaml

prepare-training-data:
	@echo "Preparing fewshot training data for: $(app_id)"
	python scripts/prepare_training_data.py \
	--app_id=$(app_id) --num_shots=$(num_shots) \
	--output_path=$(output_path) validation_size=$(validation_size) \
	--test_size=$(test_size) --seed=$(seed)

predict:
	...

evaluate:
	...

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

chat:
	llamafactory-cli api /home/paperspace/Code/LLaMA-Factory/examples/train_lora/gommt-chat.yaml
