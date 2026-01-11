extends Control

signal back_pressed

@onready var _list = %APIList
@onready var _add_btn = %AddBtn
@onready var _back_btn = %BackBtn

@onready var _dialog = %APIEditDialog

var api_config_item_scene = preload("res://pages/settings/ai_management/APIConfigItem.tscn")

func _ready():
	_back_btn.pressed.connect(func(): back_pressed.emit())
	_add_btn.pressed.connect(_on_add_pressed)
	_dialog.save_pressed.connect(func(_config): 
		refresh_list()
		Store.save_settings()
	)
	refresh_list()

func refresh_list():
	for child in _list.get_children():
		child.queue_free()
	
	for config in Store.app_data.ai_configs:
		var item = api_config_item_scene.instantiate()
		_list.add_child(item)
		item.setup(config)
		item.edit_requested.connect(_on_edit_requested.bind(config))
		item.delete_requested.connect(_on_delete_requested.bind(config))
		item.test_requested.connect(_on_test_requested.bind(config))

func _on_add_pressed():
	var new_config = AIConfig.new(str(Time.get_unix_time_from_system()), "Custom", "", "")
	Store.app_data.ai_configs.append(new_config)
	Store.save_settings()
	_dialog.open(new_config)

func _on_edit_requested(config: AIConfig):
	_dialog.open(config)

func _on_delete_requested(config: AIConfig):
	Store.app_data.ai_configs.erase(config)
	refresh_list()
	Store.save_settings()

func _on_test_requested(config: AIConfig):
	print("测试连接: ", config.provider_name)
	
	# 创建临时的 HTTP 请求节点
	var http = HTTPRequest.new()
	add_child(http)
	
	var url = config.base_url
	if url == "":
		if config.provider_name.to_lower().contains("deepseek"):
			url = "https://api.deepseek.com/v1"
		else:
			url = "https://api.openai.com/v1"
			
	# 尝试访问 /models 端点，通常不需要消耗 tokens 且能验证 auth
	if not url.ends_with("/models"):
		if url.ends_with("/"):
			url += "models"
		else:
			url += "/models"
			
	var headers = ["Authorization: Bearer " + config.api_key]
	var error = http.request(url, headers, HTTPClient.METHOD_GET)
	
	if error != OK:
		print("HTTP 请求创建失败: ", error)
		config.last_test_success = false
		refresh_list()
		http.queue_free()
		return
		
	print("发送测试请求到: ", url)
	var result = await http.request_completed
	http.queue_free()
	
	var response_code = result[1]
	var body = result[3].get_string_from_utf8()
	print("测试响应状态: ", response_code)
	
	var success = response_code == 200
	config.last_test_success = success
	
	if success:
		print("连接成功！")
	else:
		print("连接失败。状态码: ", response_code)
		print("响应: ", body)
	
	refresh_list()
	Store.save_settings()
