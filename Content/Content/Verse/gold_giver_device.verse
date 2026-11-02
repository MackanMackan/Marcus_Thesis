using {/Fortnite.com/Devices}
using {/Verse.org/Simulation}
using {/UnrealEngine.com/Temporary/Diagnostics}
using { /Verse.org/Random }

gold_giver_device := class(creative_device):

    @editable ItemGranter : item_granter_device = item_granter_device{}
    @editable Button : button_device = button_device{}
    @editable ClampedInt : type{_X : int where _X >= 1, _X <= 10} = 1

    OnBegin<override>()<suspends>:void=
        Button.InteractedWithEvent.Subscribe(GivePlayerItem)

    GivePlayerItem(Agent : agent):void=
        ItemGranter.SetItemGrantCountAtIndex(1, GetRandomInt(0, ClampedInt))
        ItemGranter.GrantItem(Agent)