//===========================================================================//
// GodotSteam - godotsteam.h
//===========================================================================//
//
// Copyright (c) 2015-Current | GP Garcia and Contributors
//
// View all contributors at https://godotsteam.com/contribute/contributors/
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in all
// copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.
//
//===========================================================================//

#include "godotsteam_project_settings.h"


void SteamProjectSettings::register_settings() {
	GLOBAL_DEF(PropertyInfo(Variant::INT, "steam/initialization/app_id"), 0);
	GLOBAL_DEF(PropertyInfo(Variant::BOOL, "steam/initialization/initialize_on_startup"), false);
	GLOBAL_DEF(PropertyInfo(Variant::BOOL, "steam/initialization/embed_callbacks"), false);
}


int SteamProjectSettings::get_app_id() {
	return GLOBAL_GET("steam/initialization/app_id");
}


bool SteamProjectSettings::get_auto_init() {
	return GLOBAL_GET("steam/initialization/initialize_on_startup");
}


bool SteamProjectSettings::get_embed_callbacks() {
	return GLOBAL_GET("steam/initialization/embed_callbacks");
}