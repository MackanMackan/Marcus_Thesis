
using { /Fortnite.com/Devices }
using { /Verse.org/Simulation }
using { /UnrealEngine.com/Temporary/Diagnostics }
using { /UnrealEngine.com/Temporary/SpatialMath }
using { /Fortnite.com/Characters }


Gnome := class():
    SpawnGnome(Agent:agent, GnomeAsset:creative_prop_asset):void=
        if(FortCharacter := Agent.GetFortCharacter[]):
            Translation := FortCharacter.GetTransform().Translation
            Rotation := FortCharacter.GetTransform().Rotation
            AdjustedRotation := Rotation.ApplyYaw(90.0)
            SpawnProp(GnomeAsset, Translation + Rotation.GetLocalForward() * 100.0, AdjustedRotation)

gnome_spawner := class(creative_device):
    @editable InputTrigger : input_trigger_device = input_trigger_device{}
    @editable GnomeAsset : creative_prop_asset = DefaultCreativePropAsset

    NewGnome : Gnome = Gnome{}
    
    OnBegin<override>()<suspends>:void=
        InputTrigger.PressedEvent.Subscribe(GetPlayerLocation)

    GetPlayerLocation(Agent : agent):void=
        NewGnome.SpawnGnome(Agent, GnomeAsset)