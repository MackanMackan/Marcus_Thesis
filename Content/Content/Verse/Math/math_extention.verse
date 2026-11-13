using { /Verse.org/SpatialMath }
using { /Verse.org }
using { /Verse.org/Native }
using { /Verse.org/SceneGraph }
using { /Verse.org/Simulation }
using { /Fortnite.com/Characters }

math_extention<public>:= class():

    GetRotateYTowards<public>(FacingEntity:entity, RootTransform:transform, OffsetDegrees:float):rotation=
        Direction := (FacingEntity.GetGlobalTransform().Translation - RootTransform.Translation)
                
        Yaw := RadiansToDegrees(ArcTan(Direction.Left, Direction.Forward)) + OffsetDegrees
        return MakeRotationDegrees(vector3{Up := 1.0}, Yaw)


    GetRotateYTowards<public>(FacingEntity:entity, RootTransform:transform):rotation=
        return GetRotateYTowards(FacingEntity, RootTransform, 90.0)

    Normalize<public>(Vector: vector3): vector3 =
        var Result: vector3 = Vector
        length: float = Sqrt(Vector.Forward * Vector.Forward + Vector.Left * Vector.Left + Vector.Up * Vector.Up) 
        
        if(length >= 0.0):
            set Result.Forward /= length
            set Result.Left /= length
            set Result.Up /= length
        
        return Result