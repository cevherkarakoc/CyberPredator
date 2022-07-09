extends Node2D

signal sacrifice_selected
signal errors_checked

enum {PLAYER, CHOOSE, COMMANDS, ANIMATION, ENEMY, ERROR_SPREAD}

var Command = preload("res://entities/Command/Command.tscn")
var Robot = preload("res://entities/enemies/Robot.tscn")

onready var Global = get_node("/root/Global")
onready var n_PlayerHand = $PlayerHand
onready var n_PlayerCommands = $PlayerCommands
onready var n_UI = $UI
onready var n_Deck = $Deck
onready var n_Discard = $Discard
onready var n_DeckCont = $Deck/ChipBase/DeckCount
onready var n_EnemySpawnPoint = $EnemySpawnPoint
onready var n_ShockSFX = $ShockSFX
onready var n_DazeSFX = $DazeSFX
onready var n_FixSFX = $FixSFX
onready var n_MoveSFX = $MoveSFX
onready var n_NoEnergySFX = $NoEnergySFX
onready var n_NextStageSFX = $NextStageSFX
onready var n_ShuffleSFX = $ShuffleSFX
onready var n_ErrorDrawSFX = $ErrorDrawSFX

var m_drawed_chip_types = []
var m_draw_deck = []
var m_discards = []
var m_enemies = []
var m_run_commands_yield = null
var m_phase = PLAYER
var m_selected_enemy = null

# Called when the node enters the scene tree for the first time.
func _ready():
	n_NextStageSFX.play()
	create_deck()
	draw_to_five()
	n_UI.refresh_energy()
	n_UI.refresh_health()
	n_UI.refresh_stage()
	
	Global.enemies = []
	var padding = 80
	
	n_EnemySpawnPoint.set_position( Vector2(360 - (Global.enemy_list.size() * 40) , n_EnemySpawnPoint.position.y) )
	for i in Global.enemy_list.size():
		var enemy_type = Global.enemy_list[i]
		var enemy = Robot.instance()
			
		enemy.set_position(n_EnemySpawnPoint.get_position() + Vector2(padding * i, 0))
		enemy.m_type = enemy_type
		add_child(enemy)
		enemy.connect("animation_completed", self, "_on_Command_animation_completed")
		Global.enemies.push_back(enemy)


func _input(event):
	if event.is_action_pressed("left_mouse"):
		var space_state = get_world_2d().direct_space_state
		if m_phase == PLAYER:
			var result = space_state.intersect_point(event.position, 1, [], 1, false, true)
			if result.size() > 0:
				toggle_command(result[0].collider)
		elif m_phase == ERROR_SPREAD:
			var result = space_state.intersect_point(event.position, 1, [], 1, false, true)
			if result.size() > 0:
				spread_error(result[0].collider)
		elif m_phase == CHOOSE:
			var result = space_state.intersect_point(event.position, 1, [], 2, false, true)
			if result.size() > 0:
				m_selected_enemy = result[0].collider
				n_UI.toggle_choose_enemy(false)
				m_phase = COMMANDS
				m_run_commands_yield = m_run_commands_yield.resume()
			


func create_deck():
	randomize()
	for chip_type in Global.player_deck:
		m_draw_deck.push_back(chip_type)
	m_draw_deck.shuffle()

func draw_to_five():
	var size = clamp(5 - n_PlayerHand.get_size(), 0, m_draw_deck.size() + m_discards.size())
	m_drawed_chip_types = []
	for i in size:
		if m_draw_deck.empty():
			shuffle_discard()
			n_Deck.set_visible(true)
			n_DeckCont.set_text(String(m_draw_deck.size()))
			n_PlayerHand.rearrange()
			yield(get_tree().create_timer(1.0), "timeout")
		
		var chip_type = m_draw_deck.pop_front()
		var chip = Command.instance()
		chip.set_position(n_Deck.get_position())
		chip.set_type(chip_type)
		add_child(chip)
		n_PlayerHand.add_item(chip, true)
		m_drawed_chip_types.push_front(chip_type)
	
	
	n_Deck.set_visible(!m_draw_deck.empty())
	n_DeckCont.set_text(String(m_draw_deck.size()))
	n_PlayerHand.rearrange()
	if m_drawed_chip_types.size() > 0:
		n_ShuffleSFX.play()


func shuffle_discard():
	for chip in m_discards:
		m_draw_deck.push_back(chip.get_type())
		chip.mark_dead()
		chip.move(null, -1, n_Deck.get_position())
	m_discards = []
	m_draw_deck.shuffle()
	

func next_turn():
	for command in n_PlayerCommands.get_items():
		m_discards.push_back(command)
		command.move(null, -1, n_Discard.get_position())
	
	if n_PlayerCommands.get_size() > 0:
		yield(get_tree().create_timer(1.0), "timeout")
	
	n_PlayerCommands.clear()
	draw_to_five()
	
	var error_count = 0
	for chip in n_PlayerHand.get_items():
		if chip.get_type() == Global.ERROR:
			error_count += 1
	
	if error_count == 5:
		Global.over_game()
		return
	
	yield(get_tree().create_timer(0.5), "timeout")
	var error_checking = check_error(m_drawed_chip_types)
	
	if error_checking != null and error_checking.is_valid():
		yield(self, "errors_checked")
	else:
		yield(get_tree().create_timer(0.5), "timeout")
	
	m_phase = PLAYER
	Global.player_energy = 0
	n_UI.refresh_energy()
	n_UI.toggle_end_turn(false)


func check_error(chips):
	for type in chips:
		if type == Global.ERROR:
			n_UI.toggle_system_error(true)
			n_ErrorDrawSFX.play()
			m_phase = ERROR_SPREAD
			yield(self, "sacrifice_selected")
			n_UI.toggle_system_error(false)
			break
	emit_signal("errors_checked")


func toggle_command(command):
	if command.get_list() != null:
		var cost = command.get_cost()
		if command.get_list() == n_PlayerHand:
			if Global.player_energy + cost <= Global.player_max_energy:
				command.remove_self_from_list()
				n_PlayerCommands.add_item(command)
				Global.player_energy += cost
				n_MoveSFX.play()
			else:
				n_NoEnergySFX.play()
		else:
			command.remove_self_from_list()
			n_PlayerHand.add_item(command)
			Global.player_energy -= cost
			n_MoveSFX.play()
		n_UI.refresh_energy()


func spread_error(chip):
	var type = chip.get_type()
	if type != Global.ERROR and chip.get_list() == n_PlayerHand:
		m_phase = PLAYER
		chip.make_error()
		Global.player_deck.erase(type)
		Global.player_deck.push_back(Global.ERROR)
		emit_signal("sacrifice_selected")


func run_commands():
	m_phase = COMMANDS
	n_UI.toggle_end_turn(true)
	Global.enemy_play_track = []
	for enemy in Global.enemies:
		Global.enemy_play_track.push_back(enemy)
	for command in n_PlayerCommands.get_items():
		Global.enemy_hit_track = []
		command.move_up()
		var info = command.get_info()
		var animation = false
		if info.has("damage") and Global.enemies.size() > 0:
			n_UI.toggle_choose_enemy(true)
			m_phase = CHOOSE
			yield()
			
			if m_selected_enemy:
				animation = true
				n_ShockSFX.play()
				m_selected_enemy.hit( info["damage"] )
		if info.has("area_damage"):
			for enemy in Global.enemies:
				Global.enemy_hit_track.push_back(enemy)
				
			for i in Global.enemy_hit_track.size():
				var enemy = Global.enemy_hit_track.pop_front()
				if enemy != null:
					n_ShockSFX.play()
					enemy.hit(info["area_damage"])
					m_phase = ANIMATION
					yield()
		if info.has("daze") and Global.enemies.size() > 0:
			n_UI.toggle_choose_enemy(true)
			
			m_phase = CHOOSE
			yield()
			
			if m_selected_enemy:
				animation = true
				n_DazeSFX.play()
				m_selected_enemy.daze( info["daze"] )
		if info.has("heal"):
			Global.heal(info["heal"])
			animation = true
			n_FixSFX.play()
			n_UI.animate_health()
		
		if !info.has("area_damage") and animation:
			m_phase = ANIMATION
			yield()
		
		var enemy = Global.enemy_play_track.pop_front()
		if enemy:
			m_phase = ENEMY
			enemy.play()
			yield()
	
	
	for enemy in Global.enemy_play_track:
		m_phase = ENEMY
		enemy.play()
		yield()
	
	if Global.enemies.empty():
		Global.inter_stage()
	else:
		next_turn()

func _on_UI_player_turn_ended():
	m_run_commands_yield = run_commands()
	
func _on_Command_animation_completed():
	if m_run_commands_yield != null and m_run_commands_yield.is_valid():
		m_phase = COMMANDS
		m_run_commands_yield = m_run_commands_yield.resume()
