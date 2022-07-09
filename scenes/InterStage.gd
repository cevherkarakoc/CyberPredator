extends Control

const HEALTH_PRICE = 1
const ENERGY_PRICE = 2
var error_price = 5

onready var Global = get_node("/root/Global")

onready var n_CryptoCount = $CryptoCount
onready var n_CommandLeft = $CommandLeft
onready var n_CommandMid = $CommandMid
onready var n_CommandRight = $CommandRight
onready var n_PriceLeft = $PriceLeft
onready var n_PriceMid = $PriceMid
onready var n_PriceRight = $PriceRight
onready var n_Health = $Health
onready var n_Energy = $Energy
onready var n_Error = $Error
onready var n_RemoveError = $RemoveError
onready var n_NextStageSFX = $NextStageSFX
onready var n_SelectSFX = $SelectSFX
onready var n_NoEnergySFX = $NoEnergySFX

onready var n_MaxHealthLabel = $MaxHealth/Label
onready var n_MaxEnergyLabel = $MaxEnergy/Label
onready var n_RemoveErrorLabel = $RemoveError/Label
# Called when the node enters the scene tree for the first time.
func _ready():
	n_NextStageSFX.play()
	var rng = RandomNumberGenerator.new()
	
	spend(0)
	refresh_ui()
	
	rng.randomize()
	n_CommandLeft.set_type_and_info(rng.randi_range(1, 6))
	n_CommandMid.set_type_and_info(rng.randi_range(1, 6))
	n_CommandRight.set_type_and_info(rng.randi_range(1, 6))
	
	n_PriceLeft.set_text("( " +  String(n_CommandLeft.get_info()["crypto"]) + " )")
	n_PriceMid.set_text("( " +  String(n_CommandMid.get_info()["crypto"]) + " )")
	n_PriceRight.set_text("( " +  String(n_CommandRight.get_info()["crypto"]) + " )")
	
	n_MaxHealthLabel.set_text( tr("inc") + "\n" + tr("max_h") + "\n( " + String(HEALTH_PRICE)  + " )")
	n_MaxEnergyLabel.set_text( tr("inc") + "\n" + tr("max_e") + "\n( " + String(ENERGY_PRICE)  + " )")
	calc_error_price()



func calc_error_price():
	var count = Global.player_deck.count(Global.ERROR)
	if count <= 1:
		error_price = 10
	elif count == 2:
		error_price = 5
	else:
		error_price = 3
	n_RemoveErrorLabel.set_text( tr("remove") + "\n" + tr("an_error") + "\n( " + String(error_price)  + " )")
	
func spend(value):
	Global.crypto -= value
	n_CryptoCount.set_text("Crypto : " + String(Global.crypto))
	if value > 0:
		n_SelectSFX.play()
	

func buy_chip(event, node):
	var info = node.get_info()
	if event.is_action_pressed("left_mouse"):
		if !node.m_sold and Global.crypto >= info["crypto"]:
			spend(info["crypto"])
			node.m_sold = true
			node.set_modulate(Color(0.3,0.3,0.3))
			Global.player_deck.push_back(node.get_type())
		else:
			n_NoEnergySFX.play()


func refresh_ui():
	var error_count = Global.player_deck.count(Global.ERROR)
	n_Health.set_text(String(Global.player_health) + "/" + String(Global.player_max_health))
	n_Energy.set_text(String(Global.player_energy) + "/" + String(Global.player_max_energy))
	n_Error.set_text(String(error_count))
	
	if error_count <= 0:
		n_RemoveError.set_modulate(Color(0.3,0.3,0.3))
	n_RemoveError.set_disabled(error_count <= 0)
	calc_error_price()


func _on_CommandLeft_input_event(_viewport, event, _shape_idx):
	buy_chip(event, n_CommandLeft)


func _on_CommandMid_input_event(_viewport, event, _shape_idx):
	buy_chip(event, n_CommandMid)


func _on_CommandRight_input_event(_viewport, event, _shape_idx):
	buy_chip(event, n_CommandRight)


func _on_MaxHealth_pressed():
	if Global.crypto >= HEALTH_PRICE:
		spend(HEALTH_PRICE)
		Global.player_max_health += 1
		refresh_ui()
	else:
		n_NoEnergySFX.play()

func _on_MaxEnergy_pressed():
	if Global.crypto >= ENERGY_PRICE:
		spend(ENERGY_PRICE)
		Global.player_max_energy += 1
		refresh_ui()
	else:
		n_NoEnergySFX.play()


func _on_RemoveError_pressed():
	if Global.crypto >= error_price and Global.player_deck.count(Global.ERROR) > 0:
		spend(error_price)
		Global.player_deck.erase(Global.ERROR)
		refresh_ui()
	else:
		n_NoEnergySFX.play()


func _on_Continue_pressed():
	Global.next_stage()
