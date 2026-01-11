extends Control

signal back_pressed

@onready var _back_btn = %BackBtn
@onready var _add_btn = %AddBtn
@onready var _grid = %GridContainer
@onready var _dialog = %CharacterEditDialog

func _ready():
	_back_btn.pressed.connect(_on_back_pressed)
	_add_btn.pressed.connect(_on_add_pressed)
	_dialog.saved.connect(_on_character_saved)
	_dialog.deleted.connect(_on_character_deleted)
	_refresh_list()

func _on_back_pressed():
	back_pressed.emit()
	visible = false

func _refresh_list():
	for c in _grid.get_children():
		c.queue_free()
	
	for char_data in Store.app_data.characters:
		var btn = Button.new()
		btn.text = char_data.name
		btn.custom_minimum_size = Vector2(0, 200)
		btn.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		btn.pressed.connect(func(): _edit_character(char_data))
		_grid.add_child(btn)

func _on_add_pressed():
	var new_char = CharacterData.new()
	_dialog.setup(new_char)
	_dialog.visible = true

func _edit_character(char_data: CharacterData):
	_dialog.setup(char_data)
	_dialog.visible = true

func _on_character_saved(data: CharacterData):
	if not Store.app_data.characters.has(data):
		Store.app_data.characters.append(data)
	
func _on_character_saved(data: CharacterData):
	if not Store.app_data.characters.has(data):
		Store.app_data.characters.append(data)
	
	Store.save_settings()
	_refresh_list()

func _on_character_deleted(data: CharacterData):
	if Store.app_data.characters.has(data):
		Store.app_data.characters.erase(data)
	
	# If we deleted current character, reset to default or first
	if Store.app_data.current_character_id == data.id:
		if not Store.app_data.characters.is_empty():
			Store.app_data.current_character_id = Store.app_data.characters[0].id
		else:
			Store.app_data.current_character_id = "" # Warning: might break things
	
	Store.save_settings()
	_refresh_list()
