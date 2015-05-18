
extends PopupPanel

var Settings
var remapping
var volume = 1.0
var muted = false
var music_player = null

func _ready():
	music_player = get_parent().get_node("MusicPlayer")
	Settings = get_node("/root/Heimdallr").Settings
	var music_on = Settings.get_value(Settings.SECTION_SOUND, Settings.SOUND_MUSIC_ENABLE)
	var music_vol = Settings.get_value(Settings.SECTION_SOUND, Settings.SOUND_MUSIC_VOL)
	get_node("MusicCheck").set_pressed(music_on)
	get_node("MusicSlider").set_value(music_vol)
	_on_MusicCheck_toggled(music_on)
	_on_MusicSlider_value_changed(music_vol)
	var sfx_on = Settings.get_value(Settings.SECTION_SOUND, Settings.SOUND_FX_ENABLE)
	var sfx_vol = Settings.get_value(Settings.SECTION_SOUND, Settings.SOUND_FX_VOL)
	get_node("SFXCheck").set_pressed(sfx_on)
	get_node("SFXSlider").set_value(sfx_vol)
	_on_SFXCheck_toggled(sfx_on)
	_on_SFXSlider_value_changed(music_vol)
	set_bindings()

func set_bindings():
	for action in Settings.get_section_keys(Settings.SECTION_BINDING):
		InputMap.erase_action(action)
		InputMap.add_action(action)
		var ev = Settings.get_value(Settings.SECTION_BINDING, action)
		get_node("P"+action[1]+"Controls/"+action).set_text(ev[0].to_upper())
		ev.remove(0)
		ev.remove(1)
		for keycode in ev:
			var evnt = InputEvent()
			evnt.type = InputEvent.KEY
			evnt.scancode = keycode
			InputMap.action_add_event(action, evnt)
		

func _on_Return_pressed():
	get_parent().toggle_menu()
	get_parent().toggle_settings()

func remap_action(event):
	remapping = get_parent().remapping
	print(remapping)
	if event.scancode != KEY_ESCAPE:
		var txt
		InputMap.erase_action(remapping)
		InputMap.add_action(remapping)
		InputMap.action_add_event(remapping, event)
		if event.scancode == KEY_TAB:
			txt = "tab"
		elif event.scancode == KEY_RETURN:
			txt = "\u21B5"
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
		Settings.set_value(Settings.SECTION_BINDING, remapping, [txt.to_upper(), event.scancode])
		Settings.save()
		print(remapping)
		get_node("P"+remapping[1]+"Controls/"+remapping).set_text(txt.to_upper())
	get_parent().is_remapping = false
	get_parent().remapping = null

func _on_rebind_pressed(button):
	get_parent().is_remapping = true
	get_parent().remapping = button

func _on_MusicCheck_toggled( pressed ):
	Settings.set_value(Settings.SECTION_SOUND, Settings.SOUND_MUSIC_ENABLE, pressed)
	Settings.save()
	if music_player == null:
		return
	if !pressed:
		music_player.get_node("StreamPlayer").set_paused( true )
		get_node("MusicSlider").set_ignore_mouse( true )
		music_player.isFadingOut = false
		music_player.isFadingIn = false
		music_player.label.set_opacity(0)
		music_player.hide()
	else:
		music_player.get_node("StreamPlayer").set_paused( false )
		get_node("MusicSlider").set_ignore_mouse( false )
		music_player.label.set_opacity(1.0)
		music_player.get_node("ShowTimer").start()
		music_player.show()
	music_player.isPlaying = pressed

func _on_MusicSlider_value_changed( value ):
	Settings.set_value(Settings.SECTION_SOUND, Settings.SOUND_MUSIC_VOL, value)
	Settings.save()
	if music_player == null:
		return
	music_player.get_node("StreamPlayer").set_volume( value )

func _on_SFXCheck_toggled( pressed ):
	muted = !pressed
	Settings.set_value(Settings.SECTION_SOUND, Settings.SOUND_FX_ENABLE, pressed)
	Settings.save()
	for node in get_tree().get_nodes_in_group("sfx"):
		node.set_default_volume(volume * int(pressed))
	get_node("SFXSlider").set_ignore_mouse(muted)
	pass # replace with function body


func _on_SFXSlider_value_changed( value ):
	volume = value
	Settings.set_value(Settings.SECTION_SOUND, Settings.SOUND_FX_VOL, value)
	Settings.save()
	for node in get_tree().get_nodes_in_group("sfx"):
		node.set_default_volume(value)
	pass # replace with function body


func _on_TutorialSwitch_toggled( pressed ):
	Settings.set_value(Settings.SECTION_TUTORIAL, Settings.TUTORIAL_SEEN, !pressed)
	Settings.save()
	pass # replace with function body
