class_name MainMenu
extends Control


const UID: String = "uid://dwyv653jb45xi"


func _on_play_button_pressed():
	get_tree().change_scene_to_file("uid://dhwj74og5vhbq")


func _on_quit_button_pressed():
	get_tree().quit()


func _on_settings_button_pressed() -> void:
	get_tree().change_scene_to_file("uid://8d64atjpd8kh")
