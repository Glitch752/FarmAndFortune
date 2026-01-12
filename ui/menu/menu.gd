extends Control

enum SubmenuState {
    NONE,
    SETTINGS,
    LOAD_SAVE,
    NEW_SAVE
}
var current_submenu: SubmenuState = SubmenuState.NONE

@onready var submenu_buttons: Dictionary[Button, SubmenuState] = {
    $%SettingsButton: SubmenuState.SETTINGS,
    $%LoadSaveButton: SubmenuState.LOAD_SAVE,
    $%NewSaveButton: SubmenuState.NEW_SAVE
}

@onready var submenu_menus: Dictionary[SubmenuState, Control] = {
    SubmenuState.SETTINGS: $%SettingsSubmenu,
    SubmenuState.LOAD_SAVE: $%LoadSaveSubmenu,
    SubmenuState.NEW_SAVE: $%NewSaveSubmenu
}

func _ready() -> void:
    # If on the web, hide the exit button
    if OS.has_feature("web"):
        $ExitButton.hide()

    $%ExitButton.pressed.connect(_on_exit_pressed)
    
    for _button in submenu_buttons.keys():
        var button: Button = _button # for gdscript typing lol
        button.focus_entered.connect(_update_submenu_focus)
        button.focus_exited.connect(_update_submenu_focus)
        button.pressed.connect(_on_submenu_button_pressed)

func _update_submenu_focus() -> void:
    var focus_owner = get_viewport().gui_get_focus_owner()
    if focus_owner == null:
        current_submenu = SubmenuState.NONE
        return
    if submenu_buttons.has(focus_owner):
        current_submenu = submenu_buttons[focus_owner as Button]
        return
    # Probably a submenu item; don't change anything

func _on_submenu_button_pressed() -> void:
    # Move focus to the submenu pane
    pass

func _on_exit_pressed() -> void:
    get_tree().quit()
