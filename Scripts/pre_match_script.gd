extends Control

@onready var client = get_node ( "/root/WebSocketClient" )

var message_block = {}

var match_id : String

func _ready ():
	SignalBus.match_entry.connect ( _on_match_entry )

func _on_texture_button_pressed ():
	message_block = {
		"type": "match_entry",
		"id": match_id
	}
	client.send ( JSON.stringify ( message_block ) )

func _on_match_entry () -> void:
	var match_scene = load ( "res://Scenes/match_scene.tscn" )
	get_tree ().get_root ().get_node ( "Main" ).add_child ( match_scene.instantiate () )
	get_tree ().get_root ().get_node ( "Main/MatchScene" ).match_id = match_id

	message_block = {
		"type": "fps",
		"id": match_id
	}
	client.send ( JSON.stringify ( message_block ) )

	get_tree ().get_root ().get_node ( "Main/LobbyScene" ).queue_free ()
	get_tree ().get_root ().get_node ( "Main/PreMatchScene" ).queue_free ()
