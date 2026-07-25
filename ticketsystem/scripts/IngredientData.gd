extends Resource

class_name IngredientData

enum COOK { RAW, BAKED, FRIED, GRILLED, BOILED, STEAMED, MICROWAVED,
SMOKED, TOASTED }
enum DONENESS { RAW, BLUERARE, RARE, MEDIUMRARE, MEDIUM, MEDIUMWELL,
 WELLDONE, BURNT }
enum PREP { DICED, MINCED, SLICED, JULIENNE, BRUNOISE, RONDEL,
SCRAMBLED, MEATBALL, PATTY, SUNNYSIDEUP }

@export_group("Meta")
@export var name: String
@export var image: Image
@export var mesh: Mesh

@export_group("Cooking")
@export_subgroup("Style")
@export var cook: Array[COOK]
@export var doneness: Array[DONENESS]
@export var prep: Array[PREP]
@export_subgroup("CookLevel")
@export var doneness_intervals: Array[float]

@export_group("Specifics")
@export var bounding_box_size: Vector3 = Vector3.ONE


	
