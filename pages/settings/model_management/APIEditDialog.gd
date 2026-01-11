extends Panel

signal saved

var current_api: APIEndpoint

@onready var _name_input = %NameInput
@onready var _api_key_input = %APIKeyInput
@onready var _base_url_input = %BaseURLInput
@onready var _save_btn = %SaveBtn
@onready var _cancel_btn = %CancelBtn

func _ready():
	_save_btn.pressed.connect(_on_save)
	_cancel_btn.pressed.connect(_on_cancel)
	visible = false

func open(api: APIEndpoint):
	current_api = api
	_name_input.text = api.name
	_api_key_input.text = api.api_key
	_base_url_input.text = api.base_url
	visible = true

func _on_save():
	if current_api:
		current_api.name = _name_input.text
		current_api.api_key = _api_key_input.text
		current_api.base_url = _base_url_input.text
	visible = false
	saved.emit()

func _on_cancel():
	visible = false
