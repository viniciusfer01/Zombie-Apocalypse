#Cena de login
extends Control

#Referência do nó WebSocket e dos nós da cena
@onready var client = get_node ( "/root/WebSocketClient" )

@onready var username_line_edit = $VBoxContainer2/HBoxContainer/UsernameLineEdit
@onready var password_line_edit = $VBoxContainer2/HBoxContainer2/PasswordLineEdit
@onready var login_button = $VBoxContainer2/LoginButton
@onready var create_account_button = $VBoxContainer2/CreateAccountButton

var message_block = {}

func _on_show_password_button_toggled ( toggled_on ):
	#Botão para mostrar/esconder a senha
	if toggled_on == true:
		$VBoxContainer2/HBoxContainer2/PasswordLineEdit.set_secret ( false )
	else:
		$VBoxContainer2/HBoxContainer2/PasswordLineEdit.set_secret ( true )

func _on_login_button_pressed ():
	#Ao clicar no botão de login, envia os dados de login ao servidor para autenticação de login
	message_block = {
		"type": "login",
		"username": username_line_edit.text,
		"password": password_line_edit.text
	}

	#if len ( username_line_edit.text ) != 0 and len ( password_line_edit.text ) != 0:
	client.send ( JSON.stringify ( message_block ) )

	username_line_edit.text = ""
	password_line_edit.text = ""

func _on_create_account_button_pressed ():
	#Instancia e adiciona a cena de criação de conta à cena de login ao clicar no botão de criar conta
	var create_account_scene = load ( "res://Scenes/create_account_scene.tscn" )
	add_child ( create_account_scene.instantiate () )
