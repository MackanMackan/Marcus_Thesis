# Copyright Epic Games, Inc. All Rights Reserved.

using { /Verse.org }
using { /Verse.org/Native }
using { /Verse.org/SceneGraph }
using { /Verse.org/Simulation }
using { /Fortnite.com/Characters }
using { /UnrealEngine.com/HealthPipeline }
using { /Fortnite.com/FortHealthPipeline }
using {/Verse.org/SceneGraph}
using {/UnrealEngine.com/Temporary/UI}
using { /Verse.org/SpatialMath }

npc_damage_component<public> := class<final_super>(component):

    @editable MaxHealth : float = 100.0
    @editable TimeToHideUI : float = 5.0
    var Health : float = 100.0
    var HealthUI : ?UI.UI_HealthBar_entity = false
    var HealthComponent : ?health_component = false
    var HealthUIRoot : ?entity = false
    var HealthUITransform : ?transform = false
    var LastInstigator : ?entity = false
    var TimeManager : ?time_manager = false
    var HitCount : int = 0

    var HasBeenDamaged : logic = false
    var HasBeenDamagedBeforeHiddenUI : logic = false
    var HasBeenHitOnce : logic = false

    OnBeginSimulation<override>():void =
        (super:)OnBeginSimulation()

        #Get TimeManager
        if:
            SimulationEntity := Entity.GetSimulationEntity[]
        then:
            TimeManagerEntities := SimulationEntity.FindDescendantEntitiesWithTag(TimeManagerTag)

                for:
                    TimeTagged : TimeManagerEntities
                    TimeComponent := time_manager[TimeTagged]
                do:
                    set TimeManager = option{TimeComponent}

        set Health = MaxHealth

        if (FoundHealthComponent := Entity.GetComponent[health_component]):
            set HealthComponent = option{FoundHealthComponent}
            FoundHealthComponent.OnDamaged.Subscribe(OnDamaged)
            FoundHealthComponent.OnDied.Subscribe(OnDeath)

            

        for (HealthUIWidget : Entity.FindDescendantEntities(UI.UI_HealthBar_entity)):
            set HealthUI = option{HealthUIWidget}
            set HealthUIWidget.Visible = false
            
        if(HealthComp := HealthComponent?, Widget := HealthUI?):
            if(Pool := HealthComp.GetHealthPool[fort_health_tag]):
                set Health = Pool.CurrentValue
                set Pool.MaxValue = MaxHealth
            
            set Widget.Health = Health
            set Widget.MaxHealth = MaxHealth

            if (Root := Widget.GetParent[]):
                set HealthUIRoot = option{Root}
                set HealthUITransform = option{Root.GetLocalTransform()}
        

    OnDamaged(HealthAdjustment:health_adjustment_result):void=
        Print("Damaged Start")
    
        if(HealthComp := HealthComponent?, Widget := HealthUI?):
            if(Pool := HealthComp.GetHealthPool[fort_health_tag]):
                set Health = Pool.CurrentValue
                Print("Damaged")

            set Widget.Health = Health
            set Widget.Visible = true
            
            set HitCount += 1
            spawn:
                TurnOffUIAfterTime(HitCount)

            if(HasBeenDamaged?):
                set HasBeenDamagedBeforeHiddenUI = true
            else:
                set HasBeenDamaged = true
            
    TurnOffUIAfterTime(HitNumber : int)<suspends>: void=
        Sleep(TimeToHideUI)
        if(HitCount = HitNumber):
            HideHealthUI()

    OnDeath():void=
        Print("Dead Zombie")
        HideHealthUI()
        # Play death animation

    HideHealthUI():void=
        if(Widget := HealthUI?):
            set Widget.Visible = false

    OnReceive<override>(SceneEvent:scene_event):logic=
        if(DamageEvent := damage_event[SceneEvent], Instigator := DamageEvent.Context.Instigator?):
            set LastInstigator = option{Instigator}
            
            if(not HasBeenHitOnce?):
                set HasBeenHitOnce = true
                spawn:
                    FaceInstigator()
        return false

    FaceInstigator()<suspends>:void=
        loop:
            if (Root := HealthUIRoot?, RootTransform := HealthUITransform?, Instigator := LastInstigator?):
                Direction := (Instigator.GetGlobalTransform().Translation - RootTransform.Translation)
                
                Yaw := RadiansToDegrees(ArcTan(Direction.Left, Direction.Forward)) + 90.0

                Root.SetLocalTransform(transform{
                    Translation := RootTransform.Translation
                    Rotation := MakeRotationDegrees(vector3{Up := 1.0}, Yaw)
                    Scale := RootTransform.Scale
                })
                Sleep(0.01)
        


            
            


