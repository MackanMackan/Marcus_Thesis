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

    var HasBeenDamaged : logic = false
    var HasBeenDamagedBeforeHiddenUI : logic = false
    var HasBeenHitOnce : logic = false

    OnBeginSimulation<override>():void =
        (super:)OnBeginSimulation()
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
                set Pool.CurrentValue = Health
                set Pool.MaxValue = MaxHealth
            
            set Widget.Health = Health
            set Widget.MaxHealth = MaxHealth

            if (Root := Widget.GetParent[]):
                set HealthUIRoot = option{Root}
                set HealthUITransform = option{Root.GetLocalTransform()}
        

    OnDamaged(HealthAdjustment:health_adjustment_result):void=
        if(HealthComp := HealthComponent?, Widget := HealthUI?):
            if(Pool := HealthComp.GetHealthPool[fort_health_tag]):
                set Pool.CurrentValue = Health

            set Widget.Health = Health
            set Widget.Visible = true
            
            spawn:
                TurnOffUIAfterTime(TimeToHideUI)

            if(HasBeenDamaged?):
                set HasBeenDamagedBeforeHiddenUI = true
            else:
                set HasBeenDamaged = true
            
    TurnOffUIAfterTime(Time:float)<suspends>: void=
        Sleep(Time)
        if(HasBeenDamagedBeforeHiddenUI?):
            return

        HideHealthUI()
        set HasBeenDamaged = false
        set HasBeenDamagedBeforeHiddenUI = false

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
        


            
            


