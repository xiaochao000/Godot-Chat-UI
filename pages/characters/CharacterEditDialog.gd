extends PanelContainer

signal saved(data: CharacterData)
signal cancelled
signal deleted(data: CharacterData)

var _data: CharacterData

@onready var _name_input = %NameInput
@onready var _prompt_input = %PromptInput
@onready var _model_label = %ModelPathLabel
@onready var _import_btn = %ImportBtn
@onready var _save_btn = %SaveBtn
@onready var _cancel_btn = %CancelBtn
@onready var _delete_btn = %DeleteBtn
@onready var _set_active_btn = %SetActiveBtn
@onready var _file_dialog = %FileDialog

var _pending_model_path = ""

func _ready():
	_save_btn.pressed.connect(_on_save_pressed)
	_cancel_btn.pressed.connect(_on_cancel_pressed)
	_import_btn.pressed.connect(_on_import_pressed)
	_delete_btn.pressed.connect(_on_delete_pressed)
	_set_active_btn.pressed.connect(_on_set_active_pressed)
	_file_dialog.file_selected.connect(_on_file_selected)

func setup(data: CharacterData):
	_data = data
	_name_input.text = data.name
	_prompt_input.text = data.system_prompt
	_pending_model_path = data.model_path
	_update_model_label()
	
	_delete_btn.visible = Store.app_data.characters.has(data)
	_set_active_btn.visible = Store.app_data.characters.has(data) and Store.app_data.current_character_id != data.id

func _on_set_active_pressed():
	Store.app_data.current_character_id = _data.id
	# We emit saved, which triggers CharacterManagement._on_character_saved
	# which triggers Store.save_settings()
	saved.emit(_data) 
	visible = false

func _on_delete_pressed():
	deleted.emit(_data)
	visible = false

func _update_model_label():
	if _pending_model_path == "":
		_model_label.text = "3D模型: 未选择 (使用默认)"
	else:
		_model_label.text = "3D模型: " + _pending_model_path.get_file()

func _on_import_pressed():
	_file_dialog.visible = true

func _on_file_selected(path: String):
	# Copy file to user://models/
	var dir = DirAccess.open("user://")
	if not dir.dir_exists("models"):
		dir.make_dir("models")
	
	var file_name = path.get_file()
	var dest_path = "user://models/" + file_name
	
	# Godot 4.2 copy logic
	dir.copy(path, dest_path)
	
	_pending_model_path = dest_path
	_update_model_label()

func _on_save_pressed():
	_data.name = _name_input.text
	_data.system_prompt = _prompt_input.text
	_data.model_path = _pending_model_path
	saved.emit(_data)
	visible = false

func _on_cancel_pressed():
	cancelled.emit()
	visible = false
