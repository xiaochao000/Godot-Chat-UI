class_name ChatMessageData
extends Resource

signal message_added(msg_data: MessageData)

var contact: ContactData

var messages: Array[MessageData]

@export var selected_model: String = "":
	set(value):
		selected_model = value
		emit_changed()


func add_message(msg_data: MessageData):
	messages.append(msg_data)
	message_added.emit(msg_data)

func clear_messages():
	messages.clear()
	emit_changed()
