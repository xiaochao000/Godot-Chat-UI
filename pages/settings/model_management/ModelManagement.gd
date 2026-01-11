extends Control

signal back_pressed

@onready var _model_list = %ModelList
@onready var _back_btn = %BackBtn
@onready var _api_dialog = %APIDialog

var model_item_scene = preload("res://pages/settings/model_management/ModelItem.tscn")

func _ready():
	_back_btn.pressed.connect(func(): back_pressed.emit())
	refresh_list()

func refresh_list():
	for child in _model_list.get_children():
		child.queue_free()
	
	for model_config in Store.app_data.model_configs:
		var item = model_item_scene.instantiate()
		_model_list.add_child(item)
		item.setup(model_config)
		item.manage_apis_requested.connect(_on_manage_apis.bind(model_config))

func _on_manage_apis(model_config: ModelConfig):
	_api_dialog.open(model_config)
	await _api_dialog.closed
	refresh_list()
