
using { /Fortnite.com/Devices }
using { /Verse.org/Simulation }
using { /UnrealEngine.com/Temporary/Diagnostics }
using { /UnrealEngine.com/Temporary/SpatialMath }
using { /Fortnite.com/Characters }
using { /Verse.org/SceneGraph }

flag_giver_device := class(creative_device):

    @editable VolumeTrigger : volume_device = volume_device{}
    @editable FlagMesh : creative_device = creative_device{}

    var isFlagTaken : logic = false

    OnBegin<override>()<suspends>:void=
        VolumeTrigger.AgentEntersEvent.Subscribe(AttachFlagToPlayer)

    AttachFlagToPlayer(Agent : agent):void=
        if (isFlagTaken?):
            return

        if (Player := player[Agent]):
            if (FortCharacter := Agent.GetFortCharacter[]):
                set isFlagTaken = true
                spawn:
                    FlagFollowPlayer(FortCharacter)

    FlagFollowPlayer(PlayerToFollow : fort_character)<suspends>:void=
        AttachedPlayerTranform := PlayerToFollow.GetTransform()
        loop:
            Translation := AttachedPlayerTranform.Translation
            Rotation := AttachedPlayerTranform.Rotation
            
            FlagMesh.MoveTo(Translation + vector3{X := 0.0, Y := 0.0, Z := Translation.Z * 50}, Rotation, 0.0)