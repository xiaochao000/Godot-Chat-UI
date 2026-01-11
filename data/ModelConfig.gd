class_name ModelConfig
extends Resource

@export var model_name: String = ""  # 如 "DeepSeek-V3"
@export var display_name: String = ""  # 显示名称
@export var api_model_name: String = ""  # API调用时使用的模型名，如 "deepseek-chat"
@export var api_endpoints: Array[APIEndpoint] = []
@export var selected_api_index: int = -1  # -1 表示未选择

@export var default_base_url: String = ""  # 模型的默认 Base URL

func _init(p_name: String = "", p_display: String = "", p_api_model: String = "", p_url: String = ""):
	model_name = p_name
	display_name = p_display if p_display != "" else p_name
	api_model_name = p_api_model
	default_base_url = p_url

func get_selected_api() -> APIEndpoint:
	if selected_api_index >= 0 and selected_api_index < api_endpoints.size():
		return api_endpoints[selected_api_index]
	return null

func get_best_available_api() -> APIEndpoint:
	# 优先返回选中的API
	var selected = get_selected_api()
	if selected != null and selected.is_available():
		return selected
	
	# 如果选中的不可用，找第一个可用的
	for i in range(api_endpoints.size()):
		var api = api_endpoints[i]
		if api.is_available():
			return api
	
	# 如果没有可用的，返回选中的（即使不可用）或第一个
	if selected != null:
		return selected
	elif api_endpoints.size() > 0:
		return api_endpoints[0]
	return null

func get_overall_status() -> int:
	if api_endpoints.is_empty():
		return 0  # UNAVAILABLE
	
	var has_available = false
	var has_busy = false
	
	for i in range(api_endpoints.size()):
		var api = api_endpoints[i]
		if api.is_available():
			has_available = true
		elif api.is_busy():
			has_busy = true
	
	if has_available:
		return 2  # AVAILABLE
	elif has_busy:
		return 1  # BUSY
	else:
		return 0  # UNAVAILABLE

func get_status_color() -> Color:
	var overall_status = get_overall_status()
	match overall_status:
		2:  # AVAILABLE
			return Color(0.2, 0.8, 0.3, 1.0)
		1:  # BUSY
			return Color(0.9, 0.7, 0.2, 1.0)
		_:  # UNAVAILABLE
			return Color(0.8, 0.2, 0.2, 1.0)
