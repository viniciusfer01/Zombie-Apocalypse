extends Control

@onready var client = get_node ( "/root/WebSocketClient" )

var message_block = {}

func _on_texture_button_pressed ():
	var id = $VBoxContainer/HBoxContainer/LineEdit.text
	var pin = $VBoxContainer/HBoxContainer2/LineEdit.text
	var max_players = $VBoxContainer/HBoxContainer3/LineEdit.text
	message_block = {
		"type": "create_match",
		"id": id,
		"pin": pin,
		"max_players": max_players.to_int ()
	}
	if len ( id ) != 0 and len ( pin ) != 0 and len ( max_players ) != 0:
		var pre_match_scene = load ( "res://Scenes/pre_match_scene.tscn" )
		get_tree ().get_root ().get_node ( "Main" ).add_child ( pre_match_scene.instantiate () )
		get_parent ().hide ()

		client.send ( JSON.stringify ( message_block ) )

		message_block = {
		"type": "pre_match_entry",
		"id": id
		}
		client.send ( JSON.stringify ( message_block ) )

		get_tree ().get_root ().get_node ( "Main/PreMatchScene" ).match_id = id

		$".".queue_free ()

func _on_texture_button_2_pressed ():
	$".".queue_free ()
