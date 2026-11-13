using { /Verse.org/SpatialMath }
using { /Verse.org }
using { /Verse.org/Native }
using { /Verse.org/SceneGraph }
using { /Verse.org/Simulation }
using { /Fortnite.com/Characters }

math_extention<public>:= class():

    GetRotateYTowards<public>(TowardsPosition:vector3, RootPosition:vector3, OffsetDegrees:float):rotation=
        Direction := (TowardsPosition - RootPosition)
                
        Yaw := RadiansToDegrees(ArcTan(Direction.Left, Direction.Forward)) + OffsetDegrees
        return MakeRotationDegrees(vector3{Up := 1.0}, Yaw)


    GetRotateYTowards<public>(TowardsPosition:vector3, RootPosition:vector3):rotation=
        return GetRotateYTowards(TowardsPosition, RootPosition, 90.0)

    Normalize<public>(Vector: vector3): vector3 =
        var Result: vector3 = Vector
        length: float = Sqrt(Vector.Forward * Vector.Forward + Vector.Left * Vector.Left + Vector.Up * Vector.Up) 
        
        if(length >= 0.0):
            set Result.Forward /= length
            set Result.Left /= length
            set Result.Up /= length
        
        return Result