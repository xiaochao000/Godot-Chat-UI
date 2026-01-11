extends Control

signal save_pressed(config: AIConfig)
signal cancel_pressed

@onready var _provider_input = %ProviderInput
@onready var _key_input = %KeyInput
@onready var _url_input = %URLInput
@onready var _save_btn = %SaveBtn
@onready var _cancel_btn = %CancelBtn

var current_config: AIConfig

func _ready():
	_save_btn.pressed.connect(_on_save_pressed)
	_cancel_btn.pressed.connect(func(): cancel_pressed.emit())

func open(config: AIConfig):
	current_config = config
	_provider_input.text = config.provider_name
	_key_input.text = config.api_key
	_url_input.text = config.base_url
	visible = true

func _on_save_pressed():
	current_config.provider_name = _provider_input.text
	current_config.api_key = _key_input.text
	current_config.base_url = _url_input.text
	save_pressed.emit(current_config)
	visible = false
