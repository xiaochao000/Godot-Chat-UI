class_name AIConfig
extends Resource

@export var id: String = ""
@export var provider_name: String = "OpenAI" # 例如: OpenAI, DeepSeek, Custom
@export var api_key: String = ""
@export var base_url: String = "" # 留空使用默认
@export var is_active: bool = true
@export var last_test_success: bool = false
@export var last_error: String = ""

func _init(p_id: String = "", p_provider: String = "OpenAI", p_key: String = "", p_url: String = ""):
	id = p_id
	provider_name = p_provider
	api_key = p_key
	base_url = p_url
