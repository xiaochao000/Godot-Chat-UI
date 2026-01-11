extends Panel

signal closed

var current_model: ModelConfig

@onready var _title_label = %TitleLabel
@onready var _api_list = %APIList
@onready var _add_btn = %AddAPIBtn
@onready var _close_btn = %CloseBtn
@onready var _edit_dialog = %EditDialog

var api_item_scene = preload("res://pages/settings/model_management/APIItem.tscn")

func _ready():
	_add_btn.pressed.connect(_on_add_api)
	_close_btn.pressed.connect(_on_close)
	visible = false

func open(model_config: ModelConfig):
	current_model = model_config
	_title_label.text = "管理 " + model_config.display_name + " 的API"
	refresh_api_list()
	visible = true

func _on_close():
	visible = false
	closed.emit()

func refresh_api_list():
	for child in _api_list.get_children():
		child.queue_free()
	
	if current_model == null:
		return
	
	for i in range(current_model.api_endpoints.size()):
		var api = current_model.api_endpoints[i]
		var item = api_item_scene.instantiate()
		_api_list.add_child(item)
		item.setup(api, i == current_model.selected_api_index)
		item.select_requested.connect(_on_select_api.bind(i))
		item.edit_requested.connect(_on_edit_api.bind(i))
		item.delete_requested.connect(_on_delete_api.bind(i))
		item.test_requested.connect(_on_test_api.bind(i))

func _on_add_api():
	var default_url = current_model.default_base_url if current_model.default_base_url != "" else ""
	var new_api = APIEndpoint.new("", "新API", "", default_url)
	current_model.api_endpoints.append(new_api)
	var new_index = current_model.api_endpoints.size() - 1
	_edit_dialog.open(new_api)
	await _edit_dialog.saved
	refresh_api_list()

func _on_select_api(index: int):
	current_model.selected_api_index = index
	print("已选择API: ", current_model.api_endpoints[index].name)
	refresh_api_list()

func _on_edit_api(index: int):
	var api = current_model.api_endpoints[index]
	_edit_dialog.open(api)
	await _edit_dialog.saved
	refresh_api_list()

func _on_delete_api(index: int):
	current_model.api_endpoints.remove_at(index)
	# 调整选中索引
	if current_model.selected_api_index >= current_model.api_endpoints.size():
		current_model.selected_api_index = current_model.api_endpoints.size() - 1
	refresh_api_list()

func _on_test_api(index: int):
	var api = current_model.api_endpoints[index]
	print("测试API: ", api.name)
	
	# 简单的测试逻辑
	var http = HTTPRequest.new()
	add_child(http)
	
	var url = api.base_url
	if url == "":
		url = "https://api.openai.com/v1/models"
	elif not url.contains("/models"):
		url = url.trim_suffix("/") + "/models"
	
	var headers = ["Authorization: Bearer " + api.api_key]
	var error = http.request(url, headers, HTTPClient.METHOD_GET)
	
	if error != OK:
		api.status = 0  # UNAVAILABLE
		http.queue_free()
		refresh_api_list()
		return
	
	var result = await http.request_completed
	http.queue_free()
	
	var response_code = result[1]
	
	if response_code == 200:
		api.status = 2  # AVAILABLE
		print("API测试成功")
	else:
		api.status = 0  # UNAVAILABLE
		print("API测试失败，状态码: ", response_code)
	
	api.last_check_time = Time.get_unix_time_from_system()
	refresh_api_list()
