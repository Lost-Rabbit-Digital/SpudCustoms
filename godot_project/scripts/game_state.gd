# Compatibility stub for save file migration
# Old save files reference res://scripts/game_state.gd but the class
# was moved to res://scripts/core/game_state.gd
#
# This stub ensures existing player saves load correctly.
# DO NOT DELETE - Required for backward compatibility with v1.1.x saves.

extends "res://scripts/core/game_state.gd"
