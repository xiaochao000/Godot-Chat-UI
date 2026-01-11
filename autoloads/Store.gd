extends Node


signal side_menu_btn_pressed(menu_name: String)
signal chats_list_item_selected(chats_list_item: ChatsListItem)


var app_data: AppData
var current_chat_message_data: ChatMessageData

func _ready() -> void:
	app_data = Seed.seed_app_data()
	load_settings()

func save_settings():
	var storage = AIStorage.new()
	storage.ai_configs = app_data.ai_configs
	storage.model_configs = app_data.model_configs
	
	var error = ResourceSaver.save(storage, "user://ai_settings.tres")
	if error != OK:
		print("Failed to save settings: ", error)

func load_settings():
	if FileAccess.file_exists("user://ai_settings.tres"):
		var storage = ResourceLoader.load("user://ai_settings.tres")
		if storage is AIStorage:
			# Only update if we have valid data, but keep defaults if empty might be desired?
			# Actually, if we loaded "empty" list, it means user deleted everything.
			# So we should trust the loaded data.
			# However, if structure changes, we might want to merge.
			# For now, distinct override is safest for persistence.
			app_data.ai_configs = storage.ai_configs
			app_data.model_configs = storage.model_configs
			print("Settings loaded successfully")

