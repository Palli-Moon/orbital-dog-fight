
extends PopupPanel

# member variables here, example:
# var a=2
# var b="textvar"
var remapping
var volume = 1.0
var muted = false

func _ready():
	get_node("/root/Demos/Settings/Header").set_text("Wat")
	pass

func _on_Return_pressed():
	get_parent().toggle_menu()
	get_parent().toggle_settings()
	pass # replace with function body

func remap_action(event):
	remapping = get_parent().remapping
	if event.scancode != KEY_ESCAPE:
		var txt
		InputMap.erase_action(remapping)
		InputMap.add_action(remapping)
		InputMap.action_add_event(remapping, event)
		if event.scancode == KEY_TAB:
			txt = "tab"
		elif event.scancode == KEY_RETURN:
			txt = "return"
		elif event.scancode == KEY_SPACE:
			txt = "space"
		elif event.scancode == KEY_UP:
			txt = "\u2191"
		elif event.scancode == KEY_DOWN:
			txt = "\u2193"
		elif event.scancode == KEY_LEFT:
			txt = "\u2190"
		elif event.scancode == KEY_RIGHT:
			txt = "\u2192"
		else:
			txt = str(event).split("Unicode: ")[1][0]
		get_node("P"+remapping[1]+"Controls/"+remapping).set_text(txt.to_upper())
	get_parent().is_remapping = false
	get_parent().remapping = null

func _on_rebind_pressed(button):
	print(button)
	get_parent().is_remapping = true
	get_parent().remapping = button
	pass # replace with function body

func _on_MusicCheck_toggled( pressed ):
	var musicPlayer = get_parent().musicPlayer
	if musicPlayer.isPlaying:
		musicPlayer.get_node("StreamPlayer").set_paused( !pressed )
		get_node("MusicSlider").set_ignore_mouse( true )
		musicPlayer.isFadingOut = false
		musicPlayer.isFadingIn = false
		musicPlayer.label.set_opacity(0)
		musicPlayer.hide()
	else:
		musicPlayer.get_node("StreamPlayer").set_paused( !pressed )
		get_node("MusicSlider").set_ignore_mouse( false )
		musicPlayer.label.set_opacity(1.0)
		musicPlayer.get_node("ShowTimer").start()
		musicPlayer.show()
	musicPlayer.isPlaying = !musicPlayer.isPlaying
	
	pass # replace with function body

func _on_MusicSlider_value_changed( value ):
	var musicPlayer = get_parent().musicPlayer
	#print(value)
	musicPlayer.get_node("StreamPlayer").set_volume( value )
	pass # replace with function body

func _on_SFXCheck_toggled( pressed ):
	muted = !pressed
	for node in get_tree().get_nodes_in_group("sfx"):
		node.set_default_volume(volume * int(pressed))
	get_node("SFXSlider").set_ignore_mouse(muted)
	pass # replace with function body


func _on_SFXSlider_value_changed( value ):
	volume = value
	for node in get_tree().get_nodes_in_group("sfx"):
		node.set_default_volume(value)
	pass # replace with function body
