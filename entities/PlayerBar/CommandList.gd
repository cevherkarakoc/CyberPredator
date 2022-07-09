extends Polygon2D


export var y_offset = 30
export var x_offset = 40
export var item_margin = 50

var m_offset = Vector2.ZERO
var m_items = []

# Called when the node enters the scene tree for the first time.
func _ready():
	m_offset = Vector2(position.x + x_offset, position.y + y_offset)


func add_item(item, no_rearrange = false): 
	m_items.push_back(item)
	if !no_rearrange:
		rearrange()


func remove_item(index):
	m_items.remove(index)
	rearrange()


func clear():
	m_items = []


func rearrange():
	for i in m_items.size():
		var item = m_items[i]
		var new_position = Vector2(m_offset.x + item_margin * i, m_offset.y)
		item.move(self, i, new_position)
		

func get_size():
	return m_items.size()


func get_items():
	return m_items
