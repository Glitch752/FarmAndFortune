@tool

extends PanelContainer

@export var item: ItemData:
    set(value):
        item = value
        _update()
@export var value: int = 0:
    set(v):
        value = v
        _update()

@onready var item_name = $%ItemName
@onready var item_texture = $%ItemTexture
@onready var value_label = $%ValueLabel

func _ready():
    _update()

    if not item:
        return
    if Engine.is_editor_hint():
        return

    $%SellOneButton.pressed.connect(func():
        if InventorySingleton.has_item(item.id):
            InventorySingleton.remove_item(item.id, 1)
            InventorySingleton.earn_money(value)
    )
    $%SellAllButton.pressed.connect(func():
        var quantity = InventorySingleton.items.get(item.id, 0)
        if quantity > 0:
            InventorySingleton.remove_item(item.id, quantity)
            InventorySingleton.earn_money(value * quantity)
    )

func _update():
    if not is_node_ready():
        return
    
    if item:
        item_name.text = item.name
        item_texture.texture = item.icon
    value_label.text = "$%s/ea" % value
