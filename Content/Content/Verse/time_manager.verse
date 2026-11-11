# Copyright Epic Games, Inc. All Rights Reserved.

using { /Verse.org }
using { /Fortnite.com/Devices }
using { /Verse.org/Native }
using { /Verse.org/SceneGraph }
using { /Verse.org/Simulation }
using { /Verse.org/Simulation/Tags }

time_manager<public> := class(creative_device):

    var LastUpdateTime: float = 0.0
    var DeltaTime: float = 0.0

    OnBegin<override>()<suspends>:void =
        spawn:
            UpdateLoop()

    UpdateLoop()<suspends>: void =
        loop:
            CurrentTime := GetSimulationElapsedTime()
            set DeltaTime = CurrentTime - LastUpdateTime
            set LastUpdateTime = CurrentTime

            Sleep(0.0)
    
    GetDeltaTime<public>():float=
        return DeltaTime