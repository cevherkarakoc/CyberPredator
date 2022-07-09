extends Area2D

onready var Global = get_node("/root/Global")

onready var n_Tween = $Tween
onready var n_Sprite = $AnimatedSprite
onready var n_Panel = $Panel
onready var n_Label = $Panel/Label

var m_sold = false
var m_list = null
var m_index = -1
var m_type = -1;
var m_will_dead = false

func _ready():
	set_infos()


func set_infos():
	n_Sprite.set_frame(m_type)
	var info = Global.chip_infos[m_type];
	var text = tr(info["title"])
	if info.has("damage"):
		text += "\n" + tr("damage") + ": " + String(info["damage"])
	if info.has("area_damage"):
		text += "\n" + tr("area_damage") + ": " + String(info["area_damage"])
	if info.has("daze"):
		text += "\n" + tr("daze") + ": " + String(info["daze"]) + " " + tr("turn")
	if info.has("heal"):
		text += "\n" + tr("heal") + ": " + String(info["heal"])
	text += "\n" + tr("cost") + ": " + String(info["cost"])
	n_Label.set_text(text)


func make_error():
	m_type = Global.ERROR
	set_infos()


func move(list, index, new_position):
	var duration = 0.6
	if m_list == list:
		duration = 0.3
	
	m_list = list
	m_index = index
	
	n_Tween.interpolate_property(self, "position", position, new_position, duration, Tween.TRANS_QUAD, Tween.EASE_OUT)
	n_Tween.start()


func move_up():
	n_Tween.interpolate_property(self, "position", position, position - Vector2(0, 55), 0.3, Tween.TRANS_QUAD, Tween.EASE_OUT)
	n_Tween.start()
		


func get_cost():
	return Global.chip_infos[m_type]["cost"]


func get_info():
	return Global.chip_infos[m_type]

func get_type():
	return m_type

func set_type(type):
	m_type = type


func set_type_and_info(type):
	m_type = type
	set_infos()

func mark_dead():
	m_will_dead = true


func remove_self_from_list():
	m_list.remove_item(m_index)


func get_list():
	return m_list


func _on_Command_mouse_entered():
	n_Panel.set_visible(true)


func _on_Command_mouse_exited():
	n_Panel.set_visible(false)


func _on_Tween_tween_all_completed():
	if m_will_dead:
		queue_free()
