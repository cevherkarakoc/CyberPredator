extends Control

const RED = Color(0.95, 0.27, 0.27, 1)

onready var Global = get_node("/root/Global")
onready var n_Tween = $Tween
onready var n_Title = $Title
onready var n_GameOver = $GameOver
onready var n_GameOverSFX = $GameOverSFX 

# Called when the node enters the scene tree for the first time.
func _ready():
	n_Tween.interpolate_property(n_Title, "custom_colors/font_outline_modulate", RED, Color.coral, 1.5, Tween.TRANS_QUAD, Tween.EASE_IN_OUT)
	n_Tween.interpolate_property(n_Title, "custom_colors/font_outline_modulate", Color.coral, RED, 1.5, Tween.TRANS_QUAD, Tween.EASE_IN_OUT, 1.5)
	n_Tween.start()
	
	n_GameOver.set_visible(Global.game_over)
	if Global.game_over:
		n_GameOverSFX.play()


func _on_Start_pressed():
	Global.player_deck = []
	for chip in Global.initial_deck:
		Global.player_deck.push_back(chip)
	Global.start()



func _on_English_pressed():
	TranslationServer.set_locale("en")


func _on_Turkish_pressed():
	TranslationServer.set_locale("tr")
