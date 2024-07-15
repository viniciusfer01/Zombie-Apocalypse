#Variável global iniciado com o Autoload
extends Node

var PORT : int = 8080
var URL : String = "ws://localhost:%s" % PORT

var ws : WebSocketPeer
var last_state = WebSocketPeer.STATE_CLOSED

#Cria um novo WebSocketPeer e tenta conexão com a URL declarada acima
func _ready ():
	ws = WebSocketPeer.new ()
	var err = ws.connect_to_url ( URL )
	if err != OK:
		return
	last_state = ws.get_ready_state ()

#Envia mensagem do tipo STRING para o servidor
func send ( message ):
	if typeof ( message) == TYPE_STRING:
		ws.send_text ( message )

#Retorna mensagens do tipo STRING recebidas do serivdor
func get_message ():
	if ws.get_available_packet_count () < 1:
		return null

	var pkt = ws.get_packet ()
	if ws.was_string_packet ():
		return pkt.get_string_from_utf8 ()

#Retorna o socket WebSocket
func get_socket ():
	return ws

#Encerra a conexão
func close ( code := 1000, reason := "" ):
	ws.close ( code, reason )
	last_state = ws.get_ready_state ()

#Verifica se há novos eventos no socket WebSocket
func poll ():
	if ws.get_ready_state () != ws.STATE_CLOSED:
		ws.poll ()

	var state = ws.get_ready_state ()
	if last_state != state:
		last_state = state
		if state == ws.STATE_OPEN:
			SignalBus.web_socket_connected.emit ()
		elif state == ws.STATE_CLOSED:
			SignalBus.web_socket_connection_closed.emit ()

	#Enquanto houver mensagem, emite o sinal de mensagem recebida
	while ws.get_ready_state () == ws.STATE_OPEN and ws.get_available_packet_count ():
		SignalBus.web_socket_message_received.emit ( get_message () )

#Loop infinito
func _process ( delta ):
	poll ()
