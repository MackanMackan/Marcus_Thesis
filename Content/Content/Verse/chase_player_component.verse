# Copyright Epic Games, Inc. All Rights Reserved.

using { /Verse.org }
using { /Verse.org/Native }
using { /Verse.org/Simulation }
using { /Verse.org/SpatialMath }
using { /Verse.org/SceneGraph }
using { /Fortnite.com/Characters }
using { /Fortnite.com/Game }
using { /Fortnite.com/Playspaces }
using {/invaliddomain/Marcus_Thesis/Content/Verse/Math}


# A Verse-authored component that can be added to entities
chase_player_component<public> := class<final_super>(component):

    # Movement speed in cm per second.
    @editable
    ChaseSpeed:float = 400.0
 
    # Players farther away than this (cm) are ignored.
    @editable
    DetectionRange:float = 5000.0
 
    # Stop moving when this close (cm) to the player.
    @editable
    StopDistance:float = 150.0
 
    # true: stay at the entity's own height (ground chaser). false: fly straight at the player.
    @editable
    KeepHeight:logic = true
 
    # true: turn the entity to face the player while chasing.
    @editable
    FacePlayer:logic = true

    MathExtention : math_extention = math_extention{}
 
    OnSimulate<override>()<suspends>:void =
        var LastTime:float = GetSimulationElapsedTime()
        loop:
            Sleep(0.0)  # run once per frame
            Now := GetSimulationElapsedTime()
            DeltaTime := Now - LastTime
            set LastTime = Now
 
            if (TargetPosition := FindNearestPlayerPosition[]):
                MoveToward(TargetPosition, DeltaTime)
 
    # Returns the position of the nearest active player within DetectionRange. Fails if none.
    FindNearestPlayerPosition()<transacts><decides>:vector3 =
        MyPosition := Entity.GetGlobalTransform().Translation
        Playspace := Entity.GetPlayspaceForEntity[]
        var Nearest:?vector3 = false
        var NearestDistance:float = DetectionRange
        for:
            Player : Playspace.GetPlayers()
            Character := Player.GetFortCharacter[]
            Character.IsActive[]
        do:
            PlayerPosition := Character.GetGlobalTransform().Translation
            PlayerDistance := Distance(PlayerPosition, MyPosition)
            if (PlayerDistance < NearestDistance):
                set NearestDistance = PlayerDistance
                set Nearest = option{PlayerPosition}
        Nearest?
 
    # Moves the entity one frame's worth of distance toward TargetPosition.
    MoveToward(TargetPosition:vector3, DeltaTime:float):void =
        Current := Entity.GetGlobalTransform()
        MyPosition := Current.Translation
 
        Goal := if (KeepHeight?):
            vector3{Forward := TargetPosition.Forward, Left := TargetPosition.Left, Up := MyPosition.Up}
        else:
            TargetPosition
 
        ToGoal := Goal - MyPosition
        DistanceToGoal := ToGoal.Length()
        if (DistanceToGoal <= StopDistance):
            return
 
        # Don't overshoot: move at most up to StopDistance away from the goal.
        StepLength := Min(ChaseSpeed * DeltaTime, DistanceToGoal - StopDistance)
        NewPosition := MyPosition + ToGoal * (StepLength / DistanceToGoal)
 
        # Yaw-only rotation so the entity faces the player without tilting.
        var NewRotation:rotation = Current.Rotation
        FlatDirection := vector3{Forward := ToGoal.Forward, Left := ToGoal.Left, Up := 0.0}
        if (FacePlayer?, not FlatDirection.IsAlmostZero[0.01]):
            set NewRotation = MathExtention.GetRotateYTowards(TowardsPosition := Goal, RootPosition := MyPosition)

 
        Entity.SetGlobalTransform(transform:
            Translation := NewPosition
            Rotation := NewRotation
            Scale := Current.Scale
        )

