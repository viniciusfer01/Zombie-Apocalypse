extends Node3D

var match_id : String

var fps_scene = preload ( "res://Scenes/fps_scene.tscn" )
var ally_scene = preload ( "res://Scenes/ally_scene.tscn" )

func _ready ():
	SignalBus.match_entry.connect ( _on_match_entry )
	SignalBus.position_update.connect ( _on_position_update )

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

func _on_position_update ( position_updated : Transform3D, id : int ):
	get_node ( "Ally" + str ( id ) ).transform = position_updated
