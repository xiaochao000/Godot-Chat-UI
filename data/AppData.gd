class_name AppData
extends Resource


var my_contact: ContactData

# {phone: ContactData}
var contacts = {}
var chats_data: ChatsData
var ai_configs: Array[AIConfig] = []
var model_configs: Array[ModelConfig] = []  # 新的按模型分类的配置
