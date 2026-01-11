extends PanelContainer

signal manage_apis_requested

var model_config: ModelConfig

@onready var _name_label = %NameLabel
@onready var _status_indicator = %StatusIndicator
@onready var _api_count_label = %APICountLabel
@onready var _manage_btn = %ManageBtn

func _ready():
	_manage_btn.pressed.connect(func(): manage_apis_requested.emit())

func setup(config: ModelConfig):
	model_config = config
	_name_label.text = config.display_name
	
	# 设置状态指示器颜色
	var status_color = config.get_status_color()
	_status_indicator.modulate = status_color
	
	# 显示API数量
	var api_count = config.api_endpoints.size()
	var selected_index = config.selected_api_index
	
	if api_count == 0:
		_api_count_label.text = "未配置API"
	elif selected_index >= 0 and selected_index < api_count:
		var selected_api = config.api_endpoints[selected_index]
		_api_count_label.text = "%d个API | 当前: %s" % [api_count, selected_api.name]
	else:
		_api_count_label.text = "%d个API | 未选择" % api_count
