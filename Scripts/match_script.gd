extends Node3D

var match_id : String

var fps_scene = preload ( "res://Scenes/fps_scene.tscn" )
var ally_scene = preload ( "res://Scenes/ally_scene.tscn" )
var enemy_scene = preload ( "res://Scenes/enemy_scene.tscn" )

@export_subgroup ( "Weapons" )
@export var weapons: Array [ Weapon ] = [
	preload ( "res://Weapons/blasterP.tres" ),
	preload ( "res://Weapons/blasterE.tres" )
]

var weapon: Weapon

func _ready ():
	SignalBus.match_entry.connect ( _on_match_entry )
	SignalBus.position_update.connect ( _on_position_update )
	SignalBus.weapon_toggled.connect ( _on_weapon_toggled )
	SignalBus.spawn_enemy.connect ( _spawn_enemy )

func _on_match_entry ( fps : bool, id : int ) -> void:
	if ( fps ):
		add_child ( fps_scene.instantiate () )
		get_node ( "FPS" ).name = "FPS" + str ( id )
		get_node ( "FPS"  + str ( id ) ).position.x = id
		get_node ( "FPS"  + str ( id ) ).position.z = id
	else:
		add_child ( ally_scene.instantiate () )
		get_node ( "Ally" ).name = "Ally" + str ( id )
		get_node ( "Ally" + str ( id ) ).position.x = id
		get_node ( "Ally" + str ( id ) ).position.z = id

		weapon = weapons [ 0 ]
		var weapon_model = weapon.model.instantiate ()
		weapon_model.position = weapon.position
		weapon_model.rotation_degrees = weapon.rotation
		get_node ( "Ally" + str ( id ) ).get_node ( "Head" ).add_child ( weapon_model )

func _on_position_update ( position_updated : Transform3D, head_update : Transform3D, id : int ):
	get_node ( "Ally" + str ( id ) ).transform = position_updated
	get_node ( "Ally" + str ( id ) ).get_node ( "Head" ).transform = head_update

func _on_weapon_toggled ( weapon_index : int, id : int ):
	weapon = weapons [ weapon_index ]

	for child in get_node ( "Ally" + str ( id ) ).get_node ( "Head" ).get_children ():
		get_node ( "Ally" + str ( id ) ).get_node ( "Head" ).remove_child ( child )

	var weapon_model = weapon.model.instantiate ()
	get_node ( "Ally" + str ( id ) ).get_node ( "Head" ).add_child ( weapon_model )

	weapon_model.position = weapon.position
	weapon_model.rotation_degrees = weapon.rotation

	#Audio.play ( "Sounds/weapon_change.ogg" )

func _spawn_enemy ():
	add_child ( enemy_scene.instantiate () )
	get_node ( "Enemy" ).position.x = randf_range ( 0, 2 )
	get_node ( "Enemy" ).position.z = randf_range ( 0, 2 )
