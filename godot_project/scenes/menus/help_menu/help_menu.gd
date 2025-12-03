extends Control
## Help menu with tabs explaining core game concepts and minigames.

@onready var tab_container: TabContainer = $TabContainer


func _ready() -> void:
	# Set localized tab names
	tab_container.set_tab_title(0, tr("help_tab_basics"))
	tab_container.set_tab_title(1, tr("help_tab_gameplay"))
	tab_container.set_tab_title(2, tr("help_tab_minigames"))

	# Start on the first tab
	tab_container.current_tab = 0
