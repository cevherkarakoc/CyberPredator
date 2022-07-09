extends Control


onready var n_Tween = $Tween
onready var n_Title = $Title

# Called when the node enters the scene tree for the first time.
func _ready():
	n_Tween.interpolate_property(n_Title, "custom_colors/font_outline_modulate", Color.red, Color.orange, 1.5, Tween.TRANS_QUAD, Tween.EASE_IN_OUT)
	n_Tween.interpolate_property(n_Title, "custom_colors/font_outline_modulate", Color.orange, Color.red, 1.5, Tween.TRANS_QUAD, Tween.EASE_IN_OUT, 2)
	n_Tween.start()


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _on_Start_pressed():
	pass # Replace with function body.
