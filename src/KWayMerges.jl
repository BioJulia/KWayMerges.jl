module KWayMerges

export my_function, MyType

"""
    MyStruct{T <: Real}

This struct represents a point in 2D-space.

# Examples
```jldoctest
julia> x = MyType(1.0, 2.0)
MyType{Float64}(1.0, 2.0)

julia> my_function(x)
2.23606797749979
```

See also: [`my_function`](@ref)
"""
struct MyType{T <: Real}
    x::T
    y::T
end 

"""
    my_function(x::MyType) -> Real

Computes the L2 norm of `x`.
# Examples
```jldoctest
julia> x = MyType(1.0, 2.0)
MyType{Float64}(1.0, 2.0)

julia> my_function(x)
2.23606797749979
```

See also: [`MyType`](@ref)
"""
my_function(x::MyType) = sqrt(x.x^2 + x.y^2)

end # module KWayMerges
