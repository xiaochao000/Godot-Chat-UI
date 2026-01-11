class_name Chats
extends Control

# Required for tweening
@onready var list = %ChatsList

@onready var _side = $Side
@onready var _main_content = $MainContent
@onready var chat_messages = %ChatMessages
@onready var landing = %ChatsLanding


func _ready() -> void:
	Store.chats_list_item_selected.connect(_on_chats_list_item_selected)
	chat_messages.back_pressed.connect(_on_back_pressed)


func _on_chats_list_item_selected(_chats_list_item: ChatsListItem):
	_side.visible = false
	_main_content.visible = true
	landing.visible = false
	chat_messages.visible = true


func _on_back_pressed():
	_side.visible = true
	_main_content.visible = false
