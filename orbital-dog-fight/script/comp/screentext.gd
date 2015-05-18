
extends Node2D

var Settings = null
var tutorial_seen
var tutorial_num = 0
var tut_line1
var tut_line2

func _ready():
	Settings = get_node("/root/Heimdallr").Settings
	tutorial_seen = Settings.get_value(Settings.SECTION_TUTORIAL, Settings.TUTORIAL_SEEN)
	if tutorial_seen:
		hide()
	else:
		tutorial()



func tutorial():
	var fwd = Settings.get_value(Settings.SECTION_BINDING, Settings.BINDING_P1_FWD)[0]
	var tl = Settings.get_value(Settings.SECTION_BINDING, Settings.BINDING_P1_TL)[0]
	var tr = Settings.get_value(Settings.SECTION_BINDING, Settings.BINDING_P1_TR)[0]
	var lasers = Settings.get_value(Settings.SECTION_BINDING, Settings.BINDING_P1_LASERS)
	if lasers.size() > 2:
		lasers = lasers[0] + " or " + lasers[2]
	else:
		lasers = lasers[0]
	tut_line1 = ["Welcome to Orbital Dog-fight!", "Welcome to Orbital Dog-fight!", "Shoot the asteroid before"]
	tut_line2 = ["Go forward with " + fwd + ".\nTurn with " + tl + " and " + tr, "Press " + lasers + " to shoot", "it destroys your planet!"]
	set_screen_text(tut_line1[0], tut_line2[0])
	get_node("TutorialTimer").start()

func set_screen_text(line1, line2):
	show()
	get_node("line1").set_text(line1)
	get_node("line2").set_text(line2)

func _on_TutorialTimer_timeout():
	tutorial_num += 1
	if tutorial_num > tut_line1.size()-1:
		hide()
		get_node("TutorialTimer").stop()
		Settings.set_value(Settings.SECTION_TUTORIAL, Settings.TUTORIAL_SEEN, true)
		Settings.save()
		tutorial_seen = true
		return
	set_screen_text(tut_line1[tutorial_num], tut_line2[tutorial_num])

	get_node("TutorialTimer").start()