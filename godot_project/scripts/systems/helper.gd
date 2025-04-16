extends Node
#################################################
# HELPER FUNCTIONS
#################################################

enum SignalClass { UNDEFINED, GODOT, STEAM }


func connect_signal(
	_signal: Signal, _function: Callable, _signal_class: SignalClass = SignalClass.UNDEFINED
) -> void:
	var error: int = _signal.connect(_function)
	var name_of_class: String = ""

	match _signal_class:
		SignalClass.UNDEFINED:
			name_of_class = ""
		SignalClass.GODOT:
			name_of_class = "[GODOT] "
		SignalClass.STEAM:
			name_of_class = "[STEAM] "

	if error:
		printerr(
			(
				"%sConnecting Signal %s to %s failed: %s"
				% [name_of_class, _signal.get_name(), str(_function), str(error)]
			)
		)
