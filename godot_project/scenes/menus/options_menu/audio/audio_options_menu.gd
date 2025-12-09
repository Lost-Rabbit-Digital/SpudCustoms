extends AudioOptionsMenu
## Custom audio options menu that renames "SFX" to "Sound Effects" for display


## Override the display name for SFX bus
const BUS_DISPLAY_NAMES: Dictionary = {
	"SFX": "Sound Effects"
}


func _add_audio_control(bus_name: String, bus_value: float, bus_iter: int):
	# Use custom display name if available
	var display_name: String = BUS_DISPLAY_NAMES.get(bus_name, bus_name)

	if (
		audio_control_scene == null
		or bus_name in hide_busses
		or bus_name.begins_with(AppSettings.SYSTEM_BUS_NAME_PREFIX)
	):
		return
	var audio_control = audio_control_scene.instantiate()
	%AudioControlContainer.call_deferred("add_child", audio_control)
	if audio_control is OptionControl:
		audio_control.option_section = OptionControl.OptionSections.AUDIO
		audio_control.option_name = display_name
		audio_control.value = bus_value
		audio_control.connect("setting_changed", _on_bus_changed.bind(bus_iter))
