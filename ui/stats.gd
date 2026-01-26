extends VBoxContainer

@onready var money_label = $%Money

func _ready():
    InventorySingleton.money_changed.connect(_update_money)
    _update_money(InventorySingleton.money)

func _update_money(new_amount: int) -> void:
    money_label.text = "$%s" % InventorySingleton.format_money(new_amount)
