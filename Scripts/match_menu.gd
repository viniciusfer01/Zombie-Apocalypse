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
		client.send ( JSON.stringify ( message_block ) )
		$".".queue_free ()

func _on_texture_button_2_pressed ():
	$".".queue_free ()
