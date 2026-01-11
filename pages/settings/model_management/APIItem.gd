extends PanelContainer

signal select_requested
signal edit_requested
signal delete_requested
signal test_requested

var api: APIEndpoint
var is_selected: bool = false

@onready var _name_label = %NameLabel
@onready var _status_indicator = %StatusIndicator
@onready var _select_btn = %SelectBtn
@onready var _edit_btn = %EditBtn
@onready var _delete_btn = %DeleteBtn
@onready var _test_btn = %TestBtn

func _ready():
	_select_btn.pressed.connect(func(): select_requested.emit())
	_edit_btn.pressed.connect(func(): edit_requested.emit())
	_delete_btn.pressed.connect(func(): delete_requested.emit())
	_test_btn.pressed.connect(func(): test_requested.emit())

func setup(p_api: APIEndpoint, p_is_selected: bool):
	api = p_api
	is_selected = p_is_selected
	
	_name_label.text = api.name
	_status_indicator.modulate = api.get_status_color()
	
	if is_selected:
		_select_btn.text = "✓ 已选择"
		_select_btn.disabled = true
	else:
		_select_btn.text = "选择"
		_select_btn.disabled = false
