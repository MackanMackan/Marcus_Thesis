using { /Fortnite.com/AI }
using { /Fortnite.com/Animation/PlayAnimation }
using { /Fortnite.com/Characters }
using { /Fortnite.com/Game }
using { /Fortnite.com/Playspaces }
using { /Verse.org/Assets }
using { /Verse.org/SceneGraph }
using { /Verse.org/Simulation }
using { /Verse.org/SpatialMath }

# NPC behavior: chases the closest player using the navigation mesh and attacks in range.
zombie_chase_attack_player<public> := class(npc_behavior):

   # Distance (cm) at which the zombie stops and attacks.
    @editable AttackRange:float = 150.0
 
    # Damage dealt per attack.
    @editable AttackDamage:float = 10.0
 
    # Seconds between attacks.
    @editable AttackCooldown:float = 1.0
 
    # How often (seconds) the zombie re-checks which player is closest.
    @editable RetargetInterval:float = 2.0
 
    # Optional attack animation from your own skeleton.
    @editable AttackAnimation:?animation_sequence = false
 
    OnBegin<override>()<suspends>:void =
        if:
            Agent := GetAgent[]
            Character := Agent.GetFortCharacter[]
            NPCEntity := GetEntity[]
            Actions := NPCEntity.GetComponent[npc_actions_component]
        then:
            ChaseLoop(Character, Actions)
        else:
            Print("zombie_chase_behavior: could not get character or npc_actions_component")
 
    ChaseLoop(Zombie:fort_character, Actions:npc_actions_component)<suspends>:void =
        loop:
            if (not Zombie.IsActive[]):
                break
 
            if (Target := FindClosestPlayer[Zombie], TargetAgent := Target.GetAgent[]):
                NavTarget := MakeNavigationTarget(TargetAgent)
                Reached := race:
                    # Pathfind toward the moving player until within AttackRange.
                    block:
                        NavResult := Actions.NavigateTo(NavTarget, ?MovementType := movement_type.Walking, ?ReachRadius := AttackRange)
                        if (Error := NavResult.GetError[]):
                            if (Error = navigation_action_error_type.Unreachable or Error = navigation_action_error_type.Blocked):
                                Print("zombie_chase_behavior: target unreachable, check the navigation mesh")
                                Sleep(0.5)
                        logic{NavResult.GetSuccess[] = navigation_action_success_type.Reached}
                    # Periodically stop so a closer player can be picked.
                    block:
                        Sleep(RetargetInterval)
                        false
 
                if (Reached?):
                    Attack(Zombie, Target, Actions)
            else:
                # No player available yet.
                Sleep(1.0)
 
    Attack(Zombie:fort_character, Target:fort_character, Actions:npc_actions_component)<suspends>:void =
        if (IsInRange[Zombie, Target]):
            # Turn to face the player; finishes once facing them.
            if (TargetEntity := Target.GetEntity[]):
                Actions.Focus(TargetEntity, ?LockFocus := false)
            if (Anim := AttackAnimation?, Controller := Zombie.GetPlayAnimationController[]):
                Controller.PlayAndAwait(Anim)
            # Re-check range after the swing so players can dodge.
            if (IsInRange[Zombie, Target], Target.IsActive[]):
                Target.Damage(AttackDamage)
        Sleep(AttackCooldown)
 
    IsInRange(Zombie:fort_character, Target:fort_character)<transacts><decides>:void =
        ZombiePos := Zombie.GetGlobalTransform().Translation
        TargetPos := Target.GetGlobalTransform().Translation
        # Small margin because navigation stops right at the reach radius.
        DistanceForwardLeft(ZombiePos, TargetPos) <= AttackRange + 50.0
 
    # Returns the closest active player character, fails if there is none.
    FindClosestPlayer(Zombie:fort_character)<transacts><decides>:fort_character =
        NPCEntity := GetEntity[]
        Playspace := NPCEntity.GetPlayspaceForEntity[]
        From := Zombie.GetGlobalTransform().Translation
        var Best:?fort_character = false
        var BestDistance:float = Inf
        for (Player : Playspace.GetPlayers(), Character := Player.GetFortCharacter[], Character.IsActive[]):
            D := Distance(From, Character.GetGlobalTransform().Translation)
            if (D < BestDistance):
                set BestDistance = D
                set Best = option{Character}
        Best?