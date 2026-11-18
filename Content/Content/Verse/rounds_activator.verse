
using { /Fortnite.com/Devices }
using { /Verse.org/Simulation }
using { /UnrealEngine.com/Temporary/Diagnostics }
using {/UnrealEngine.com/Temporary/UI}
using { /Fortnite.com/Game }
using { /Fortnite.com/Playspaces }
using { /Verse.org/SceneGraph }
using { /Fortnite.com/Devices }

rounds_activator := class(creative_device):

    @editable AmountOfSpawnsPerRound : []int = array{}
    
    ActiveRound : int = 0
    
    var NpcSpawners:[]npc_spawner_device = array{}

    OnBegin<override>()<suspends>:void=
        if:
            SimEntity := GetSimulationEntity[]
        then:
            set NpcSpawners = for:
                NpcSpawnerTagged : SimEntity.FindCreativeObjectsWithTag(NpcSpawnerTag)
                Spawner := npc_spawner_device[NpcSpawnerTagged]
            do:
                Spawner