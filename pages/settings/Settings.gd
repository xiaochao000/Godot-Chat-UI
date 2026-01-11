extends Control

@onready var _ai_management_btn = %AIManagementBtn
@onready var list = %ItemsContainer

@onready var _ai_management = %AIManagement

func _ready():
	_ai_management_btn.pressed.connect(_on_ai_management_pressed)
	_ai_management.back_pressed.connect(func(): _ai_management.visible = false)

func _on_ai_management_pressed():
	_ai_management.visible = true
	_ai_management.refresh_list()
