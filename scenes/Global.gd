extends Node

enum {ERROR, SHOCK, SHOCKWAVE, DAZE, FIX, SINEWAVE, COSWAVE}
enum {SECBOT, FASBOT, GUABOT}
var initial_deck = [ERROR, ERROR, SHOCK, SHOCK, SHOCK, FIX, FIX, DAZE, DAZE, SHOCKWAVE]
var player_deck = []
var enemy_list = []
var enemies = []
var enemy_play_track = []
var enemy_hit_track = []
var game_over = false

var stage = 1
var crypto = 0
var player_max_energy = 4
var player_energy = 0

var player_max_health = 10
var player_health = 10

var chip_infos = [
	{ "title": "system_error", "cost": 666, "crypto": 666 },
	{ "title": "shock", "damage" : 1, "cost": 1, "crypto": 1 },
	{ "title": "shockwave", "area_damage": 1, "cost": 3, "crypto": 3 },
	{ "title": "low_frequency", "daze": 2, "cost": 1, "crypto": 2 },
	{ "title": "fix", "heal": 2, "cost": 2, "crypto": 2},
	{ "title": "sinewave", "damage" : 2, "cost": 2, "crypto": 2 },
	{ "title": "coswave", "area_damage" : 2, "cost": 6, "crypto": 6 },
]

var bot_infos = [
	{ "health" : 2, "damage": 1, "crypto": 1 },
	{ "health" : 1, "damage": 3, "crypto": 1 },
	{ "health" : 4, "damage": 2, "crypto": 2 },
]

var rng = RandomNumberGenerator.new()

func kill_enemy(enemy):
	crypto += enemy.m_crypto
	enemies.erase(enemy)
	enemy_play_track.erase(enemy)
	enemy_hit_track.erase(enemy)
	enemy.set_visible(false)


func heal(value):
	var ui = get_tree().get_current_scene().n_UI;
	player_health = clamp(player_health + value, 0, player_max_health)
	ui.refresh_health()


func hit(value):
	heal(-value)
	if player_health <= 0:
		over_game()


func over_game():
	game_over = true
	yield(get_tree().create_timer(0.7), "timeout")
	get_tree().reload_current_scene()
	get_tree().change_scene("res://scenes/MenuScreen.tscn")


func spawn_enemies():
	enemy_list = []
	var enemy_count = rng.randi_range(2, min(5, stage + 1))
	for i in enemy_count:
		enemy_list.push_back(rng.randi_range(0, min(2, max(0,stage - 2) )))


func inter_stage():
	if player_deck.count(Global.ERROR) >= 3:
		crypto += 2
	stage += 1
	player_energy = 0
	get_tree().change_scene("res://scenes/InterStage.tscn")

func next_stage():
	spawn_enemies()
	get_tree().change_scene("res://scenes/GameBoard.tscn")


func start():
	stage = 1
	game_over = false
	crypto = 0
	player_max_energy = 4
	player_energy = 0
	player_max_health = 10
	player_health = 10
	rng.randomize()
	spawn_enemies()
	get_tree().change_scene("res://scenes/GameBoard.tscn")

