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
	


QWEN_CONFIGS = \
	examples/train_lora/gommt-oneshot-qwen-0.5B.yaml \
	examples/train_lora/gommt-oneshot-qwen-1.5B.yaml \
	# examples/train_lora/gommt-oneshot-qwen-7B.yaml

train-ilsv2.1:
	config="/home/paperspace/Code/LLaMA-Factory/examples/train_lora/gommt-ilsv2.1.yaml"; \
	project_name="gommt/oneshot"; \
	echo $$project_name; \
	echo $$config; \
	CLEARML_PROJECT=$$project_name \
		CLEARML_TASK=$$(basename $$config .yaml) \
		llamafactory-cli train $$config;

train-ilsv2.2:
	config="/home/paperspace/Code/LLaMA-Factory/examples/train_lora/gommt-ilsv2.2.yaml"; \
	project_name="gommt/oneshot"; \
	echo $$project_name; \
	echo $$config; \
	CLEARML_PROJECT=$$project_name \
		CLEARML_TASK=$$(basename $$config .yaml) \
		llamafactory-cli train $$config;

# CONFIGS = \
# 	examples/train_lora/gommt-ilsv2.1.yaml \ # [INFO|2024-11-25 08:01:45] llamafactory.model.loader:157 >> trainable params: 169,148,416 || all params: 8,199,409,664 || trainable%: 2.0629
# 	examples/train_lora/gommt-oneshot-lora-r256.yaml # [INFO|2024-11-25 05:12:29] llamafactory.model.loader:157 >> trainable params: 389,021,696 || all params: 3,601,771,520 || trainable%: 10.8008

CONFIGS = \
	examples/train_lora/gommt-oneshot-qwen.yaml \
	examples/train_lora/gommt-oneshot-qwen-1.5B.yaml \
	examples/train_lora/gommt-oneshot-lora-r2.yaml \
	# examples/train_lora/gommt-oneshot-qwen-0.5B.yaml \
	# examples/train_lora/gommt-ilsv2.1.yaml

train-v1s:
	@mkdir -p logs
	@for config in $(CONFIGS); do \
		project_name="gommt/oneshot"; \
		log_file="logs/$$(basename $$config .yaml)_$$(date +'%Y%m%d_%H%M%S').log"; \
		CLEARML_PROJECT=$$project_name \
			CLEARML_TASK=$$(basename $$config .yaml) \
			llamafactory-cli train $$config 2>&1 | tee $$log_file; \
	done

ilsv2-merge:
	config="/home/paperspace/Code/LLaMA-Factory/examples/merge_lora/gommt-ilsv2-finetuned.yaml"; \
	llamafactory-cli export $$config;

train-qwens:
	@for config in $(QWEN_CONFIGS); do \
		project_name="gommt/oneshot"; \
		CLEARML_PROJECT=$$project_name \
			CLEARML_TASK=$$(basename $$config .yaml) \
			llamafactory-cli train $$config; \
	done

LLAMA_CONFIGS = \
	examples/train_lora/gommt-oneshot-lora-r128.yaml \
	# examples/train_lora/gommt-oneshot-lora-r256.yaml \
	# examples/train_lora/gommt-oneshot-lora-r64.yaml \

train-llamas:
	@for config in $(LLAMA_CONFIGS); do \
		project_name="gommt/oneshot"; \
		CLEARML_PROJECT=$$project_name \
			CLEARML_TASK=$$(basename $$config .yaml) \
			llamafactory-cli train $$config; \
	done

train-dummy-llamas:
	config="examples/train_lora/gommt-dummies.yaml"; \
	for rank in 2 4 8 16 32 64; do \
		new_config=$${config%.yaml}-r$$rank-dummy.yaml; \
		cp $$config $$new_config; \
		sed -i "s/RANK/$$rank/g" $$new_config; \
		project_name="gommt/oneshot"; \
		CLEARML_PROJECT=$$project_name \
		CLEARML_TASK=$$(basename $$new_config .yaml) \
		llamafactory-cli train $$new_config; \
	done


CONFIGS = \
	/home/paperspace/Code/LLaMA-Factory/examples/train_lora/gommt-oneshot-llama-11B-lora-r256.yaml \
	/home/paperspace/Code/LLaMA-Factory/examples/train_lora/gommt-ilsv2.1-r256.yaml \
	/home/paperspace/Code/LLaMA-Factory/examples/train_lora/gommt-minicpm.yaml \

train-202411261442:
	@mkdir -p logs
	@for config in $(CONFIGS); do \
		project_name="gommt/oneshot"; \
		log_file="logs/$$(basename $$config .yaml)_$$(date +'%Y%m%d_%H%M%S').log"; \
		CLEARML_PROJECT=$$project_name \
			CLEARML_TASK=$$(basename $$config .yaml) \
			llamafactory-cli train $$config 2>&1 | tee $$log_file; \
	done


CONFIGS = \
	/home/paperspace/Code/LLaMA-Factory/examples/train_lora/reliance-llama32.yaml \

train-reliance:
	@mkdir -p logs
	@for config in $(CONFIGS); do \
		project_name="gommt/oneshot"; \
		log_file="logs/$$(basename $$config .yaml)_$$(date +'%Y%m%d_%H%M%S').log"; \
		CLEARML_PROJECT=$$project_name \
			CLEARML_TASK=$$(basename $$config .yaml) \
			llamafactory-cli train $$config 2>&1 | tee $$log_file; \
	done




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
