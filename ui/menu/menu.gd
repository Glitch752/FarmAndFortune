extends Control

enum SubmenuState {
    NONE,
    SETTINGS,
    LOAD_SAVE,
    NEW_SAVE
}
var current_submenu: SubmenuState = SubmenuState.NONE:
    set(value):
        current_submenu = value
        update_visible_submenu()

func update_visible_submenu() -> void:
    for submenu in submenu_menus.keys():
        if submenu == current_submenu:
            submenu_menus[submenu].shown = true
        else:
            submenu_menus[submenu].shown = false

@onready var submenu_buttons: Dictionary[Control, SubmenuState] = {
    $%SettingsButton: SubmenuState.SETTINGS,
    $%LoadButton: SubmenuState.LOAD_SAVE,
    $%NewButton: SubmenuState.NEW_SAVE,
    $%ExitButton: SubmenuState.NONE
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
    
    for button in submenu_buttons.keys():
        button.focus_changed.connect(_update_submenu_focus)
        button.pressed.connect(_on_submenu_button_pressed)
    
    update_visible_submenu()

func _update_submenu_focus(new_focus: Control) -> void:
    if submenu_buttons.has(new_focus):
        current_submenu = submenu_buttons[new_focus]
        return
    # Probably a submenu item; don't change anything

func _on_submenu_button_pressed() -> void:
    # Move focus to the submenu pane
    pass

func _on_exit_pressed() -> void:
    get_tree().quit()
