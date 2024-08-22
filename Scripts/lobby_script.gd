#Cena com a lista de partidas ativas e um chat global
extends Control

@onready var client = get_node ( "/root/WebSocketClient" )

var message_block = {}

func _ready ():
	SignalBus.chat_update.connect ( _on_chat_update )
	SignalBus.matches_update.connect ( _on_matches_update )

func _on_chat_update ( message ):
	$VBoxContainer/ChatRichTextLabel.add_text ( message + '\n')

func _on_matches_update ( message ):
	var new_bbcode = "[center][url=" + message + "][color=black]Id:[/color] [color=green]" + message + "[/color][/url][/center]\n"
	$VBoxContainer/MatchesRichTextLabel.append_text ( new_bbcode )

#Criar partida
func _on_texture_button_pressed ():
	var config_match_menu_scene = load ( "res://Scenes/config_match_menu_scene.tscn" )
	get_tree ().get_root ().get_node ( "Main/LobbyScene" ).add_child ( config_match_menu_scene.instantiate () )

#Envio de mensagem via chat
func _on_line_edit_text_submitted ( new_text ):
	message_block = {
		"type": "chat",
		"chat_message": new_text
	}

	if len ( new_text ) != 0:
		$VBoxContainer/LineEdit.text = ""
		$VBoxContainer/ChatRichTextLabel.add_text ( "[ You ]: " + new_text + "\n" )

		client.send ( JSON.stringify ( message_block ) )

#Entrar em uma partida
func _on_matches_rich_text_label_meta_clicked ( meta ):
	message_block = {
		"type": "pre_match_entry",
		"id": meta
	}
	client.send ( JSON.stringify ( message_block ) )

	var pre_match_scene = load ( "res://Scenes/pre_match_scene.tscn" )
	get_tree ().get_root ().get_node ( "Main" ).add_child ( pre_match_scene.instantiate () )
	hide ()

	get_tree ().get_root ().get_node ( "Main/PreMatchScene" ).match_id = meta
