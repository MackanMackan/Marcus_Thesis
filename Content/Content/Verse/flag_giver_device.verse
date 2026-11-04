
using { /Fortnite.com/Devices }
using { /Verse.org/Simulation }
using { /UnrealEngine.com/Temporary/Diagnostics }
using { /UnrealEngine.com/Temporary/SpatialMath }
using { /Fortnite.com/Characters }
using { /Verse.org/SceneGraph }

flag_giver_device := class(creative_device):

    @editable VolumeTrigger : volume_device = volume_device{}
    @editable FlagMesh : creative_prop = creative_prop{}

    var IsFlagTaken : logic = false

    OnBegin<override>()<suspends>:void=
        VolumeTrigger.AgentEntersEvent.Subscribe(AttachFlagToPlayer)

    AttachFlagToPlayer(Agent : agent):void=
        if (IsFlagTaken?):
            Print("Flag Already Taken!")
            return

        if (Player := player[Agent]):
            set IsFlagTaken = true
            spawn:
                FlagFollowPlayer(Agent)

    FlagFollowPlayer(Agent : agent)<suspends>:void=
        loop:
            if (PlayerToFollow := Agent.GetFortCharacter[]):
                AttachedPlayerTranform := PlayerToFollow.GetTransform()
                Translation := AttachedPlayerTranform.Translation
                Rotation := AttachedPlayerTranform.Rotation
                ForwardVector := Rotation.GetLocalForward()
                # Offests the flag behind the player and moves it, this does look very ugly though
                FlagMesh.MoveTo(Translation + ForwardVector * -20.0, Rotation, 0.1)
    
    CalculateForwardVector(Angles : vector3)<suspends>:vector3=
        var ForwardVector : vector3 = vector3{}
        Roll := Angles.X
        Pitch := Angles.Y
        Yaw := Angles.Z

        ForwardX := Cos(Pitch) * Sin(Yaw)
        ForwardY := -Sin(Pitch)
        ForwardZ := Cos(Pitch) * Cos(Yaw)

        set ForwardVector = vector3{X := ForwardX,Y := ForwardY,Z:= ForwardZ}

        return ForwardVector