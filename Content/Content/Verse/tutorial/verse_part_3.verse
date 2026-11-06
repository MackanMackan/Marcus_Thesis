
using { /Fortnite.com/Devices }
using { /Verse.org/Simulation }
using { /UnrealEngine.com/Temporary/Diagnostics }

character := class():
    var HP : int = 100
    var Damage<private> : int = 10

    TakeDamage(): void=
        set HP -= 10

Knight := class(character):
    var HP<override> : int = 120
    TakeDamage<override>(): void=
        set HP -=5

verse_part_3 := class(creative_device):

    OnBegin<override>()<suspends>:void=
        block: