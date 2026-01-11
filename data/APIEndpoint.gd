class_name APIEndpoint
extends Resource

enum Status {
	UNAVAILABLE = 0,  # 红色：不可用
	BUSY = 1,         # 黄色：拥堵
	AVAILABLE = 2     # 绿色：可用
}

@export var id: String = ""
@export var name: String = "默认API"
@export var api_key: String = ""
@export var base_url: String = ""
@export var status: int = 0  # 0=UNAVAILABLE, 1=BUSY, 2=AVAILABLE
@export var last_check_time: float = 0.0

func _init(p_id: String = "", p_name: String = "默认API", p_key: String = "", p_url: String = ""):
	id = p_id if p_id != "" else str(Time.get_unix_time_from_system())
	name = p_name
	api_key = p_key
	base_url = p_url

func get_status_color() -> Color:
	match status:
		2:  # AVAILABLE
			return Color(0.2, 0.8, 0.3, 1.0)  # 绿色
		1:  # BUSY
			return Color(0.9, 0.7, 0.2, 1.0)  # 黄色
		_:  # UNAVAILABLE
			return Color(0.8, 0.2, 0.2, 1.0)  # 红色

func is_available() -> bool:
	return status == 2  # Status.AVAILABLE

func is_busy() -> bool:
	return status == 1  # Status.BUSY

func is_unavailable() -> bool:
	return status == 0  # Status.UNAVAILABLE
