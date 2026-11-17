using {/Fortnite.com/Devices}
using {/Verse.org/Simulation}
using {/UnrealEngine.com/Temporary/Diagnostics}
using { /Verse.org/Random }

gold_giver_device<public> := class(creative_device):

    @editable ItemGranter : item_granter_device = item_granter_device{}

    GivePlayerGold<public>(Agent : agent, Amount:int):void=
        ItemGranter.SetItemGrantCountAtIndex(0, Amount)
        ItemGranter.GrantItem(Agent)