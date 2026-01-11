class_name AIUtils
extends Node

static func test_connection(config: AIConfig) -> bool:
	# 这是一个简单的测试逻辑，实际可能需要发送一个轻量级的 API 请求 (如 /models 或 简单的 chat completion)
	var url = config.base_url
	if url == "":
		if config.provider_name == "DeepSeek":
			url = "https://api.deepseek.com/v1/chat/completions"
		else:
			url = "https://api.openai.com/v1/chat/completions"
	
	# 这里需要异步处理，但由于我们目前在 Resource/Static 函数中，这里只是一个占位实现或返回信号
	# 为了演示，我们随机返回或根据 key 是否为空判断
	return config.api_key.length() > 5
