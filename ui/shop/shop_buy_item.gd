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

    $%Buy1Button.pressed.connect(func(): try_buy(1))
    $%Buy10Button.pressed.connect(func(): try_buy(10))

func try_buy(quantity: int) -> bool:
    if not item:
        return false
    var total_cost = value * quantity
    if InventorySingleton.has_money(total_cost):
        InventorySingleton.spend_money(total_cost)
        InventorySingleton.add_item(item.id, quantity)
        return true
    return false

func _update():
    if not is_node_ready():
        return
    
    if item:
        item_name.text = item.name
        item_texture.texture = item.icon
    value_label.text = "$%s/ea" % value
