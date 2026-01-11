extends PanelContainer

signal edit_requested
signal delete_requested
signal test_requested

@onready var _name_label = %ProviderName
@onready var _url_label = %BaseURL
@onready var _status_icon = %StatusIcon
@onready var _test_btn = %TestBtn
@onready var _edit_btn = %EditBtn
@onready var _delete_btn = %DeleteBtn

func _ready():
	_test_btn.pressed.connect(func(): test_requested.emit())
	_edit_btn.pressed.connect(func(): edit_requested.emit())
	_delete_btn.pressed.connect(func(): delete_requested.emit())

func setup(config: AIConfig):
	_name_label.text = config.provider_name
	_url_label.text = config.base_url if config.base_url != "" else "默认地址"
	update_status(config.last_test_success)

func update_status(success: bool):
	if success:
		_status_icon.modulate = Color.GREEN
	else:
		_status_icon.modulate = Color.RED
