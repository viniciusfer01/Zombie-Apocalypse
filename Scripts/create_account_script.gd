#Cena para criação da conta
extends Control

#Referência do nó WebSocket e dos nós da cena
@onready var client = get_node ( "/root/WebSocketClient" )
@onready var username_line_edit = $VBoxContainer2/HBoxContainer/UsernameLineEdit
@onready var password_line_edit = $VBoxContainer2/HBoxContainer3/PasswordLineEdit
@onready var email_line_edit = $VBoxContainer2/HBoxContainer4/EmailLineEdit

var message_block = {}

func _on_show_password_button_toggled ( toggled_on ):
	#Botão para mostrar/esconder a senha
	if toggled_on == true:
		$VBoxContainer2/HBoxContainer3/PasswordLineEdit.set_secret ( false )
	else:
		$VBoxContainer2/HBoxContainer3/PasswordLineEdit.set_secret ( true )

func _on_create_account_button_pressed ():
	#Ao clicar no botão de criar conta, envia os dados ao servidor para verificação e criação de conta
	message_block = {
		"type": "create_account",
		"email": email_line_edit.text,
		"username": username_line_edit.text,
		"password": password_line_edit.text
	}

	if len ( username_line_edit.text ) != 0 and len ( password_line_edit.text ) != 0 and len ( email_line_edit.text ):
		client.send ( JSON.stringify ( message_block ) )

	username_line_edit.text = ""
	password_line_edit.text = ""
	email_line_edit.text = ""

#Back button
func _on_create_account_button_2_pressed():
	$".".queue_free ()
