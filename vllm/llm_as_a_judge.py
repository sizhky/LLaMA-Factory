from flask import Flask, request, jsonify
from vllm import LLM, SamplingParams

app = Flask(__name__)
sampling_params = SamplingParams(temperature=0, top_p=0.95)
llm = LLM(model="sizhkhy/Qwen2.5-0.5B-Instruct-GPTQ-Int4", gpu_memory_utilization=0.3)

@app.route('/generate-qwen', methods=['POST'])
def generate():
    data = request.get_json()
    prompts = data.get('prompts', [])
    outputs = llm.generate(prompts, sampling_params, max_seq_len_to_capture=4096)

    # Prepare the outputs.
    results = []

    for output in outputs:
        prompt = output.prompt
        generated_text = output.outputs[0].text
        results.append({
            'prompt': prompt,
            'generated_text': generated_text
        })
    return jsonify(results)

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=23122)