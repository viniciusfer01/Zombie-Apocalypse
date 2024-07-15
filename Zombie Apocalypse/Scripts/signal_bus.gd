extends Node

signal web_socket_connected ()

signal web_socket_connection_closed ()

signal web_socket_message_received ( message : String )

signal chat_update ( message : String )

signal matches_update ( message : String )

signal match_entry ( fps : bool, id : int )

signal position_update ( transform : Transform3D, id : int )
