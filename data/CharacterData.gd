class_name CharacterData
extends Resource

@export var id: String = ""
@export var name: String = "Unknown"
@export var avatar: Texture2D
@export var model_path: String = "" # Path to .glb or .tscn
@export var system_prompt: String = ""
@export var selected_model: String = "" # AI Model ID
@export var created_at: float = 0.0

func _init():
	id = str(ResourceUID.create_id())
	created_at = Time.get_unix_time_from_system()
