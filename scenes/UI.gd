extends Control


signal player_turn_ended
signal animation_completed

const RED = Color(0.89, 0.23, 0.26, 1)

onready var Global = get_node("/root/Global")
onready var n_PlayerHealth = $PlayerHealth
onready var n_PlayerEnergy = $PlayerEnergy
onready var n_ChooseEnemy = $ChooseEnemy
onready var n_EndTurn = $EndTurn
onready var n_Tween = $Tween
onready var n_Error = $Error
onready var n_Sacrifice = $Sacrifice
onready var n_Stage = $Stage

func refresh_stage():
	n_Stage.set_text(tr("stage") + " : " + String(Global.stage))


func refresh_health():
	n_PlayerHealth.set_text(String(Global.player_health) + "/" + String(Global.player_max_health))


func animate_health():
	animate_text(n_PlayerHealth)


func refresh_energy():
	n_PlayerEnergy.set_text(String(Global.player_energy) + "/" + String(Global.player_max_energy))


func animate_energy():
	animate_text(n_PlayerEnergy)


func toggle_choose_enemy(value):
	n_ChooseEnemy.set_visible(value)


func toggle_end_turn(value):
	n_EndTurn.set_disabled(value)


func toggle_system_error(value):
	n_Error.set_visible(value)
	n_Sacrifice.set_visible(value)


func animate_text(text_node):
	n_Tween.interpolate_property(text_node, "custom_colors/font_color", RED, Color.white, 0.5, Tween.TRANS_BOUNCE, Tween.EASE_IN)
	n_Tween.interpolate_property(text_node, "custom_colors/font_color", Color.white, RED, 0.5, Tween.TRANS_BOUNCE, Tween.EASE_OUT, 0.5)
	n_Tween.start()

func _on_EndTurn_pressed():
	emit_signal("player_turn_ended")


func _on_Tween_tween_all_completed():
	emit_signal("animation_completed")
