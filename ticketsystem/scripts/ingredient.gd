extends Resource

class_name ingredient

enum COOK { BAKED, FRIED, GRILLED, BOILED, STEAMED, MICROWAVED,
SMOKED }
enum DONENESS { BLUERARE, RARE, MEDIUMRARE, MEDIUM, MEDIUMWELL,
 WELLDONE }
enum PREP { DICED, MINCED, CHOPPED, JULIENNE, BRUNOISE, RONDEL,
SCRAMBLED, MEATBALL, PATTY, SUNNYSIDEUP }

@export var name: String
@export var image: Image

@export var cook: Array[COOK]
@export var doneness: Array[DONENESS]
@export var prep: Array[PREP]
