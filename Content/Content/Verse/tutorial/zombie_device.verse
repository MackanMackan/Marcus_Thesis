
using { /Fortnite.com/Devices }
using { /Verse.org/Simulation }
using { /UnrealEngine.com/Temporary/Diagnostics }
using { /UnrealEngine.com/Temporary/SpatialMath }
using { /Fortnite.com/Characters }

Zombie:=class<concrete>():

    @editable ZombieProp : creative_prop = creative_prop{}
    @editable DamageVolume : damage_volume_device = damage_volume_device{}
    @editable PropManipulator : prop_manipulator_device = prop_manipulator_device{}

    @editable RunAnim : cinematic_sequence_device = cinematic_sequence_device{}
    @editable AttackAnim : cinematic_sequence_device = cinematic_sequence_device{}

    @editable RunSpeed : float = 0.01

    var isLooping : logic = true

    InitZombie(Agent:agent):void=
        spawn:
            MoveToPlayer(Agent)

        DamageVolume.AgentEntersEvent.Subscribe(Attack)
        DamageVolume.AgentExitsEvent.Subscribe(StopAttack)
        PropManipulator.DestroyedEvent.Subscribe(BreakLoop)

    MoveToPlayer(Agent:agent)<suspends>:void=
        RunAnim.Play()
        loop:
            if (isLooping = false):
                RunAnim.Stop()
                break

            Sleep(0.1)
            if(FortCharacter := Agent.GetFortCharacter[]):
                PropLocation := ZombieProp.GetTransform().Translation
                PlayerLocation := FortCharacter.GetTransform().Translation
                if(LookDirection := (PlayerLocation - PropLocation).MakeUnitVector[]):
                    Yaw := RadiansToDegrees(ArcTan(LookDirection.Y, LookDirection.X)) -90.0
                    Pitch := 0.0
                    Roll := 0.0

                    NewRotation := MakeRotationFromYawPitchRollDegrees(Yaw, Pitch, Roll)

                    LerpLocation := Lerp(PropLocation, PlayerLocation, RunSpeed)
                    FinalLocation := vector3{X:=LerpLocation.X, Y:=LerpLocation.Y, Z:=0.0}
                    if(ZombieProp.TeleportTo[FinalLocation, NewRotation]):



    BreakLoop(Agent:agent):void=
        set isLooping = false

    Attack(Agent:agent):void=
        AttackAnim.Play()

    StopAttack(Agent:agent):void=
        AttackAnim.Stop()


zombie_device := class(creative_device):
    @editable Zombies : []Zombie = array{}
    @editable PlayerSpawner : player_spawner_device = player_spawner_device{}

    OnBegin<override>()<suspends>:void=
        PlayerSpawner.SpawnedEvent.Subscribe(BeginAttack)

    BeginAttack(Agent:agent):void=
        for(AZombie : Zombies):
            AZombie.InitZombie(Agent)