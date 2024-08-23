#Cena principal que controla a exibição das cenas e gerencia mensagens recebidas do servidor
extends Node

#Referência do nó WebSocketClient
@onready var client = get_node ( "/root/WebSocketClient" )

func _ready ():
	#Conexão dos sinais
	SignalBus.web_socket_connected.connect ( _on_web_socket_connected )
	SignalBus.web_socket_connection_closed.connect ( _on_web_socket_connection_closed )
	SignalBus.web_socket_message_received.connect ( _on_web_socket_message_received )

func _on_web_socket_connected ():
	#Instancia a cena de login e adiciona à cena principal
	var login_scene = load ( "res://Scenes/login_scene.tscn" )
	add_child ( login_scene.instantiate () )

func _on_web_socket_connection_closed ():
	get_tree ().quit ()

func _on_web_socket_message_received ( message ):
	var parsed_message = JSON.parse_string ( message )

	if parsed_message.type == "login":
		#Deleta a cena de login e instancia e adiciona a cena de lobby à cena principal
		$LoginScene.queue_free ()
		var lobby_scene = load ( "res://Scenes/lobby_scene.tscn" )
		add_child ( lobby_scene.instantiate () )
	elif parsed_message.type == "create_account":
		#Deleta a cena de criação de conta, que é filha da cena de login
		$LoginScene/CreateAccountScene.queue_free ()
		$LoginScene.show ()
	elif parsed_message.type == "chat":
		SignalBus.chat_update.emit ( parsed_message.chat_message )
	elif parsed_message.type == "create_match":
		SignalBus.matches_update.emit ( parsed_message.id )
	elif parsed_message.type == "match_entry":
		SignalBus.match_entry.emit ()
	elif parsed_message.type == "fps":
		SignalBus.fps_instance.emit ( parsed_message.fps, parsed_message.id )
	elif parsed_message.type == "position_update":
		SignalBus.position_update.emit ( str_to_var ( parsed_message.transform ), str_to_var ( parsed_message.head_transform ),  parsed_message.id )
	elif parsed_message.type == "weapon_toggled":
		SignalBus.weapon_toggled.emit ( parsed_message.weapon_index, parsed_message.id )
	else:
		SignalBus.spawn_enemy.emit ()
