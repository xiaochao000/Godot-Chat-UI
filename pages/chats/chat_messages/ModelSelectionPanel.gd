extends Control

signal model_selected(model_name: String)

@onready var _grid = %ModelGrid
@onready var _desc_label = %ModelDescription
@onready var _panel_bg = $Panel
@onready var _confirm_btn = $MarginContainer/VBoxContainer/ConfirmBtn # 路径修正

var selected_model = ""

func _ready():
	set_as_top_level(true)
	# 点击背景关闭
	var close_func = func(event):
		if event is InputEventMouseButton and event.pressed:
			visible = false
	
	gui_input.connect(close_func)
	_panel_bg.gui_input.connect(close_func)
	_confirm_btn.pressed.connect(func():
		print("关闭按钮被点击")
		visible = false
	)

func refresh():
	for child in _grid.get_children():
		child.queue_free()
	
	var models = Store.app_data.model_configs
	if models.is_empty():
		_desc_label.text = "暂无可用模型，请联系管理员。"
		return

	for model in models:
		var btn = Button.new()
		btn.text = model.display_name
		btn.custom_minimum_size = Vector2(250, 100)
		btn.add_theme_font_size_override("font_size", 28)
		
		# 创建按钮样式
		var style = StyleBoxFlat.new()
		style.corner_radius_top_left = 8
		style.corner_radius_top_right = 8
		style.corner_radius_bottom_right = 8
		style.corner_radius_bottom_left = 8
		
		# 根据选中状态和模型状态设置颜色
		if model.model_name == selected_model:
			# 选中状态：使用更亮的绿色
			style.bg_color = Color(0.2, 0.7, 0.3, 1.0)
		else:
			# 未选中：根据模型状态显示颜色
			var status_color = model.get_status_color()
			# 降低透明度，使其更柔和
			style.bg_color = Color(status_color.r * 0.3, status_color.g * 0.3, status_color.b * 0.3, 1.0)
		
		# 添加状态指示器（右上角圆点）
		btn.add_theme_stylebox_override("normal", style)
		btn.add_theme_stylebox_override("hover", style)
		
		_grid.add_child(btn)
		btn.pressed.connect(_on_model_selected.bind(model.model_name))

func _on_model_selected(model_name: String):
	selected_model = model_name
	print("选择了模型: ", model_name)
	_desc_label.text = "当前选择: " + model_name + "\n各方面表现优秀，适用于角色扮演。"
	
	# 更新按钮样式
	for btn in _grid.get_children():
		if btn is Button:
			if btn.text == selected_model:
				var style = StyleBoxFlat.new()
				style.bg_color = Color(0.2, 0.6, 0.3, 1.0)
				style.corner_radius_top_left = 8
				style.corner_radius_top_right = 8
				style.corner_radius_bottom_right = 8
				style.corner_radius_bottom_left = 8
				btn.add_theme_stylebox_override("normal", style)
				btn.add_theme_stylebox_override("hover", style)
			else:
				btn.remove_theme_stylebox_override("normal")
				btn.remove_theme_stylebox_override("hover")
	
	# 立即发射信号并关闭面板
	print("发射 model_selected 信号，模型: ", model_name)
	model_selected.emit(model_name)
	
	# 延迟关闭，让用户看到选中效果
	await get_tree().create_timer(0.3).timeout
	visible = false
	print("=== 模型选择完成，面板已关闭 ===")
