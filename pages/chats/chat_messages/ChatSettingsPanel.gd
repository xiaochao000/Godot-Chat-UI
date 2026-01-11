extends Control

@onready var _panel_bg = $Panel
@onready var _clear_btn = %ClearHistoryBtn

var data: ChatMessageData

func _ready():
	set_as_top_level(true)
	# 点击背景关闭
	var close_func = func(event):
		if event is InputEventMouseButton and event.pressed:
			visible = false
	
	gui_input.connect(close_func)
	_panel_bg.gui_input.connect(close_func)
	
	_clear_btn.pressed.connect(_on_clear_pressed)

func setup(p_data: ChatMessageData):
	data = p_data

func _on_clear_pressed():
	if data:
		data.clear_messages()
		print("聊天记录已清空")
	visible = false
