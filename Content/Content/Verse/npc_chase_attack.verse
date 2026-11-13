# Copyright Epic Games, Inc. All Rights Reserved.

using { /Verse.org }
using { /Verse.org/Native }
using { /Verse.org/SceneGraph }
using { /Verse.org/Simulation }
using { /Fortnite.com/Characters }
using { /Fortnite.com/Game }
using { /Fortnite.com/Devices }
using { /Fortnite.com/Playspaces }
using {/invaliddomain/Marcus_Thesis/Content/Verse/Math}
using { /Verse.org/SpatialMath }

npc_chase_attack<public> := class<final_super>(component):

    @editable ReachSphere : float = 20.0
    @editable RunSpeed : float = 1.0
    var Player : ?agent = false
    var TimeManager : time_manager = time_manager{}
    MathExtention : math_extention = math_extention{}
    var MyTransform : ?transform = false

  
    OnBeginSimulation<override>():void =
        (super:)OnBeginSimulation()
        Print("On Begin")
        # Get first player
        Players := creative_device{}.GetPlayspace().GetPlayers()
        set Player = option{Players[0]}
        Print("Getting players: {Players.Length}")

        if:
            SimulationEntity := Entity.GetSimulationEntity[]
            Print("Getting entity")
        then:
            set MyTransform = option{SimulationEntity.GetGlobalTransform()}
            Print("Got my transform")
            TimeManagerEntities := SimulationEntity.FindCreativeObjectsWithTag(TimeManagerTag)
            Print("Got my time manager entity")
                for:
                    TimeTagged : TimeManagerEntities
                    TimeComponent := time_manager[TimeTagged]
                do:
                    set TimeManager = TimeComponent
                    Print("set time manager")

    OnSimulate<override>()<suspends>:void =
        Print("ON Simulate")
        var LastTime:float = GetSimulationElapsedTime()
        

        if:
            ZombieTransform := MyTransform?
            Print("Zombe trans")
        then:
            loop:
                Sleep(0.0)
                Now := GetSimulationElapsedTime()
                DeltaTime := Now - LastTime
                set LastTime = Now

                ZombiePosition := Entity.GetGlobalTransform().Translation
                Players := creative_device{}.GetPlayspace().GetPlayers()
                if(Target := Players[0]):
                    PlayerPosition := Target.GetGlobalTransform().Translation

                    Direction := MathExtention.Normalize((PlayerPosition - ZombiePosition))
                    NewLocation := ZombiePosition + Direction * (RunSpeed * DeltaTime)
                    if(PlayerEnity := entity[Target]):
                        NewRotation := MathExtention.GetRotateYTowards(TowardsPosition := PlayerPosition, RootPosition := ZombiePosition)
                    
                        NewTransform := transform{Translation := NewLocation, Rotation := NewRotation, Scale := Entity.GetGlobalTransform().Scale}
                    
                        Entity.SetGlobalTransform(NewTransform)
                        Print("ZombiePosition {ZombiePosition}")
                        Print("Direction {Direction}")
                        Print("NewLocation {NewLocation}")
                        Print("NewRotation {NewRotation}")
                        Print("Player Position {PlayerPosition}")
                        Print("NewRotation {NewRotation}")
                        Print("DeltaTime {DeltaTime}")





                


