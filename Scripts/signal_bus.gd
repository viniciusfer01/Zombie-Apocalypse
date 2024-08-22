extends Node

signal web_socket_connected ()

signal web_socket_connection_closed ()

signal web_socket_message_received ( message : String )

signal chat_update ( message : String )

signal matches_update ( message : String )

signal match_entry ()

signal fps_instance ( fps : bool, id : int )

signal position_update ( transform1 : Transform3D, transform2 : Transform3D, id : int )

signal weapon_toggled ( weapon_index : int, id : int )

signal spawn_enemy ()
