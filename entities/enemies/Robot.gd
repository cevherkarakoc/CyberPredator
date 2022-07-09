extends Area2D

signal animation_completed

onready var Global = get_node("/root/Global")
onready var n_Sprite = $Sprite
onready var n_Health = $Health
onready var n_Dazed = $Dazed
onready var n_DazedCount = $Dazed/DazeCount
onready var n_Tween = $Tween
onready var n_HitSFX = $HitSFX
onready var n_DeathSFX = $DeathSFX
onready var n_DazeSFX = $DazeSFX

var m_type = 0
var m_crypto = 1
var m_health = 2
var m_damage_power = 1
var m_dazed = 0

# Called when the node enters the scene tree for the first time.
func _ready():
	var info = Global.bot_infos[m_type]
	
	m_health = info["health"]
	m_damage_power = info["damage"]
	m_crypto = info["crypto"]
	
	n_Sprite.set_frame(m_type)
	n_Health.text = String(m_health)
	refresh_daze()


func play():
	if m_dazed > 0:
		m_dazed -= 1
		n_Tween.interpolate_property(n_Sprite, "rotation_degrees", 0, 12, 0.2, Tween.TRANS_QUAD,Tween.EASE_OUT)
		n_Tween.interpolate_property(n_Sprite, "rotation_degrees", 12, -12, 0.4, Tween.TRANS_QUAD,Tween.EASE_OUT, 0.2)
		n_Tween.interpolate_property(n_Sprite, "rotation_degrees", -12, 0, 0.2, Tween.TRANS_QUAD,Tween.EASE_OUT, 0.6)
		n_Tween.start()
		n_DazeSFX.play()
		refresh_daze()
	else:
		n_Tween.interpolate_property(n_Sprite, "position:y", 0, 20, 0.3, Tween.TRANS_QUAD, Tween.EASE_IN)
		n_Tween.interpolate_property(n_Sprite, "position:y", 20, 0, 0.3, Tween.TRANS_QUAD, Tween.EASE_OUT, 0.3)
		n_Tween.start()
		n_HitSFX.play()
		Global.hit(m_damage_power)


func hit(damage):
	m_health -= damage
	n_Health.text = String(m_health)
	play_shock()


func daze(value):
	m_dazed += value
	play_daze()
	refresh_daze()


func play_shock():
	animate(Color.crimson)


func play_daze():
	animate(Color.coral)


func refresh_daze():
	n_DazedCount.text = String(m_dazed)
	n_Dazed.set_visible( m_dazed > 0 )
	

func animate(color):
	n_Tween.interpolate_property(n_Sprite, "modulate", Color.white, color, 0.3, Tween.TRANS_BOUNCE, Tween.EASE_IN)
	n_Tween.interpolate_property(n_Sprite, "modulate", color, Color.white, 0.3, Tween.TRANS_BOUNCE, Tween.EASE_OUT, 0.3)
	n_Tween.start()

func _on_Tween_tween_all_completed():
	if m_health <= 0:
		Global.kill_enemy(self)
		n_DeathSFX.play()
	emit_signal("animation_completed")
	
