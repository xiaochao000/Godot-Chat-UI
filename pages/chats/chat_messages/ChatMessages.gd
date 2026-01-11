class_name ChatsMessages
extends VBoxContainer

signal back_pressed()

@onready var _contact_avatar = %ContactAvatar
@onready var _contact_name = %ContactName
@onready var _contact_subtitle = %ContactSubtitle
@onready var _model_btn = %ModelBtn
@onready var _more_menu_btn = %MoreMenuBtn
@onready var _model_panel = %ModelSelectionPanel
@onready var _chat_settings_panel = %ChatSettingsPanel
@onready var _messages_scroll_container = %MessagesScrollContainer
@onready var _messages = %Messages
@onready var _scroll_down_helper = %ScrollDownHelper
@onready var _back_btn = %BackBtn

@onready var MessageScene = preload("res://pages/chats/chat_messages/message/Message.tscn")


var data: ChatMessageData:
	set(p_data):
		data = p_data
		if not data.changed.is_connected(_build_ui): data.changed.connect(_build_ui)
		if not data.message_added.is_connected(_on_message_added): data.message_added.connect(_on_message_added)
		_build_ui()


func _ready() -> void:
	Store.chats_list_item_selected.connect(_on_chats_list_item_selected)
	_model_btn.pressed.connect(_on_model_btn_pressed)
	_more_menu_btn.pressed.connect(_on_more_menu_pressed)
	_back_btn.pressed.connect(_on_back_pressed)
	_model_panel.model_selected.connect(_on_model_selected)


func _on_model_btn_pressed():
	print("=== 打开模型选择面板 ===")
	print("data.selected_model = ", data.selected_model)
	_model_panel.selected_model = data.selected_model
	print("已设置 _model_panel.selected_model = ", _model_panel.selected_model)
	_model_panel.visible = true
	_model_panel.refresh()
	print("=== 模型面板已打开 ===")

func _on_more_menu_pressed():
	_chat_settings_panel.setup(data)
	_chat_settings_panel.visible = true

func _on_model_selected(model_name: String):
	print("=== _on_model_selected 被调用 ===")
	print("接收到的模型名: ", model_name)
	print("data 对象是否为空: ", data == null)
	
	if data == null:
		print("错误：data 对象为 null，无法保存模型选择")
		return
	
	_model_btn.text = model_name
	data.selected_model = model_name
	
	print("已设置 data.selected_model = ", model_name)
	print("验证读取 data.selected_model = ", data.selected_model)
	print("=== _on_model_selected 完成 ===")

func _on_back_pressed():
	back_pressed.emit()


func _on_chats_list_item_selected(chat_list_item: ChatsListItem):
	var contact: ContactData = chat_list_item.data

	var chat_message_data: ChatMessageData = Store.app_data.chats_data.chats[contact.phone]
	data = chat_message_data
	Store.current_chat_message_data = chat_message_data


func _build_ui():
	_contact_avatar.texture = data.contact.avatar
	_contact_name.text = data.contact.name
	_contact_subtitle.text = "点击查看联系人信息"
	
	if data.selected_model != "":
		_model_btn.text = data.selected_model
	else:
		_model_btn.text = "选择模型"

	for child in _messages.get_children():
		child.queue_free()

	for i in range(len(data.messages)):
		var msg_data: MessageData = data.messages[i]
		_instance_message(msg_data)
	_scroll_to_bottom()


func _on_message_added(msg_data: MessageData):
	_instance_message(msg_data)
	_scroll_to_bottom()
	
	# 如果是用户发送的消息，触发 AI 回复
	if msg_data.sent_by_me:
		print("检测到用户消息，准备触发 AI 回复")
		call_deferred("_trigger_ai_reply", msg_data.message)

func _trigger_ai_reply(user_msg: String):
	print("_trigger_ai_reply 被调用，用户消息: ", user_msg)
	print("当前选中模型: ", data.selected_model)
	
	if data.selected_model == "":
		print("未选择模型，跳过 AI 回复")
		return
	
	print("AI 正在思考... 使用模型: ", data.selected_model)
	
	# 查找对应的模型配置
	var model_config: ModelConfig = null
	for m in Store.app_data.model_configs:
		if m.model_name == data.selected_model:
			model_config = m
			break
	
	if model_config == null:
		print("错误：找不到模型配置: ", data.selected_model)
		_add_error_message("模型 " + data.selected_model + " 不存在")
		return
	
	# 获取最佳可用的 API
	var api = model_config.get_best_available_api()
	
	if api == null:
		print("错误：模型 ", data.selected_model, " 没有配置 API")
		_add_error_message("请先为模型 " + data.selected_model + " 配置 API")
		return
	
	# 发送 API 请求
	var reply = await _call_ai_api(model_config, api, user_msg)
	
	if reply != "":
		var reply_msg = MessageData.new(reply)
		reply_msg.sent_by_me = false
		reply_msg.delivered_at = Time.get_unix_time_from_system()
		print("准备添加 AI 回复消息: ", reply)
		data.add_message(reply_msg)
		print("AI 回复消息已添加")
	else:
		_add_error_message("AI 回复失败，请检查网络和 API 配置")

func _add_error_message(error_text: String):
	var error_msg = MessageData.new(error_text)
	error_msg.sent_by_me = false
	error_msg.delivered_at = Time.get_unix_time_from_system()
	data.add_message(error_msg)

func _call_ai_api(model_config: ModelConfig, api: APIEndpoint, user_message: String) -> String:
	var http = HTTPRequest.new()
	add_child(http)
	
	# 构建 API URL
	var url = api.base_url
	if url == "":
		url = "https://api.openai.com/v1/chat/completions"
	elif not url.contains("/chat/completions"):
		url = url.trim_suffix("/") + "/chat/completions"
	
	# 使用模型配置中的 API 模型名
	var model_name = model_config.api_model_name
	
	# 构建请求体
	var request_body = {
		"model": model_name,
		"messages": [
			{
				"role": "system",
				"content": "你是" + data.contact.name + "，请用友好、自然的方式回复。"
			},
			{
				"role": "user",
				"content": user_message
			}
		],
		"temperature": 0.7
	}
	
	var headers = [
		"Content-Type: application/json",
		"Authorization: Bearer " + api.api_key
	]
	
	print("发送 API 请求到: ", url)
	print("使用模型: ", model_name)
	print("API 名称: ", api.name)
	
	var error = http.request(url, headers, HTTPClient.METHOD_POST, JSON.stringify(request_body))
	
	if error != OK:
		print("HTTP 请求创建失败: ", error)
		http.queue_free()
		return ""
	
	var result = await http.request_completed
	http.queue_free()
	
	var response_code = result[1]
	var body = result[3]
	
	print("API 响应状态码: ", response_code)
	
	if response_code != 200:
		print("API 请求失败，状态码: ", response_code)
		print("响应体: ", body.get_string_from_utf8())
		return ""
	
	var json = JSON.new()
	var parse_result = json.parse(body.get_string_from_utf8())
	
	if parse_result != OK:
		print("JSON 解析失败")
		return ""
	
	var response_data = json.data
	
	if response_data.has("choices") and response_data.choices.size() > 0:
		var reply_content = response_data.choices[0].message.content
		print("AI 回复: ", reply_content)
		return reply_content
	else:
		print("响应格式错误")
		return ""


func _instance_message(msg_data: MessageData):
	var message = MessageScene.instantiate()
	_messages.add_child(message)
	message.data = msg_data


func _scroll_to_bottom():
	await get_tree().process_frame
	await get_tree().process_frame
	_messages_scroll_container.ensure_control_visible(_scroll_down_helper)
