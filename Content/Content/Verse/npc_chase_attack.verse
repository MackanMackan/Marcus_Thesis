# Copyright Epic Games, Inc. All Rights Reserved.

using { /Verse.org }
using { /Verse.org/Native }
using { /Verse.org/SceneGraph }
using { /Verse.org/Simulation }
using { /Fortnite.com/AI }
using { /Fortnite.com/Characters }
using { /Fortnite.com/Game }
using { /Fortnite.com/Devices }
using { /Fortnite.com/Playspaces }

npc_chase_attack<public> := class<final_super>(component):

    @editable ReachSphere : float = 20.0
    var Player : ?agent = false
    var NpcActionComponent : ?npc_actions_component = false

  
    OnBeginSimulation<override>():void =
        (super:)OnBeginSimulation()

        # Get first player
        Players := creative_device{}.GetPlayspace().GetPlayers()
        set Player = option{Players[0]}

        if (Component := Entity.GetComponent[npc_actions_component]):
            set NpcActionComponent = option{Component}

    OnSimulate<override>()<suspends>:void =

        loop:
            if:
                PlayerTarget := Player?
                Agent := agent[PlayerTarget]
                Npc := NpcActionComponent?
            then:
                NavTarget := MakeNavigationTarget(Agent)
                Npc.NavigateTo(Target := NavTarget, ?MovementType := movement_type.Running, ?ReachRadius := ReachSphere)

            Sleep(0.0)

                


