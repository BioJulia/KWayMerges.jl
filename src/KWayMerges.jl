module KWayMerges

export KWayMerger

include("heap.jl")

"""
    KWayMerger{F, T, I, S}

Stateful iterator which does a K-way merge between multiple
iterators of the same type.
This iterator will yield the elements in every contained
iterator. At each iteration, it will choose the element from
the iterator with the lowest precedence according to the order
determined by `f::F` (default: `isless`).

If all inner iterators are sorted by `f`, the yielded elements
will be in sorted order.
A `KWayMerger` is typically used to combined multiple sorted arrays
into one sorted array.

# Examples
```jldoctest
julia> arrs = [[1,4,10], [2,3], [6,8], [5,7,9]];

julia> it = KWayMerger(arrs);

julia> print(collect(it))
[1, 2, 3, 4, 5, 6, 7, 8, 9, 10]
```

# Extended help
The type parameters are:
* `F`: Type of function used to compare the elements. It defaults
  to `typeof(Base.isless)`
* `T`: Element type of iterators
* `I`: Iterator type
* `S`: Type of state of iterators

All iterators must be of the same type. `Base.eltype` is used
to determine `T` and `I`; since its default implementation
returns `Any`, these type parameters might need to be explicitly
passed to get good performance for some iterators.

`S` is derived automatically, but this must be a fixed type;
iterators that use states of multiple different types may
not be supported by `KWayMerger`.
"""
struct KWayMerger{F, T, I, S}
    f::F
    iterators::Memory{I}
    states::Memory{S}
    heap::Vector{Tuple{T, Int}}
end

ord(x::KWayMerger) = ord(x.f)
ord(f) = (i, j) -> f(first(i), first(j))

collect_to_memory(x) = collect_to_memory(Base.IteratorSize(typeof(x)), x)

function collect_to_memory(::Union{Base.HasShape, Base.HasLength}, x)
    mem = Memory{eltype(x)}(undef, length(x))
    i = 0
    for it in x
        i += 1
        mem[i] = it
    end
    i == length(mem) || error("Implementation error: More elements than reported")
    return mem
end

function collect_to_memory(::Base.SizeUnknown, x)
    T = eltype(typeof(x))
    v = collect(T, x)
    return copy!(Memory{T}(undef, length(v)), v)
end

function KWayMerger{F, T, I}(f::F, iterators) where {F, T, I}
    iters = collect_to_memory(iterators)
    states = nothing
    things = Tuple{T, Int}[]
    for i in eachindex(iters)
        it = iterate(iters[i])
        isnothing(it) && continue
        (thing::T, state) = it
        if isnothing(states)
            states = Memory{typeof(state)}(undef, length(iters))
        end
        push!(things, (thing, i))
        states[i] = state
    end
    heapify!(ord(f), things)
    states = if isnothing(states)
        Memory{Union{}}(undef, length(iters))
    else
        states
    end
    return KWayMerger{F, T, I, eltype(states)}(f, iters, states, things)
end

function KWayMerger{T, I}(iterators) where {T, I}
    return KWayMerger{typeof(isless), T, I}(isless, iterators)
end

KWayMerger(iterators) = KWayMerger(isless, iterators)

function KWayMerger(f::F, iterators) where {F}
    I = eltype(typeof(iterators))
    T = eltype(I)
    return KWayMerger{F, T, I}(f, iterators)
end

# We could technically know this, but KWayMerger is stateful, and
# Julia's iterator length works badly with stateful iterators.
Base.IteratorSize(::Type{<:KWayMerger}) = Base.SizeUnknown()
Base.eltype(::Type{<:KWayMerger{F, T}}) where {F, T} = T

function Base.iterate(x::KWayMerger, ::Nothing = nothing)
    isempty(x.heap) && return nothing
    (item, i) = @inbounds x.heap[1]
    iterator = @inbounds x.iterators[i]
    state = @inbounds x.states[i]
    it = iterate(iterator, state)
    if it === nothing
        @inbounds heappop!(ord(x.f), x.heap)
    else
        (new_item, new_state) = it
        @inbounds x.states[i] = new_state
        @inbounds heapreplace!(ord(x.f), x.heap, (new_item, i))
    end
    return (item, nothing)
end

Base.isempty(x::KWayMerger) = isempty(x.heap)
Base.isdone(x::KWayMerger) = isempty(x.heap)

"""
    peek(x::KWayMerger)::Union{Some, Nothing}

Get the first element of `x` without advancing the iterator, or `nothing` if the
iterator is empty.

# Examples
```jldoctest
julia> it = KWayMerger([[3, 4], [2, 7]]);

julia> peek(it)
Some(2)

julia> collect(it); # empty stateful iterator

julia> peek(it) === nothing
true
```
"""
function Base.peek(x::KWayMerger{F, T})::Union{Some{T}, Nothing} where {F, T}
    isempty(x.heap) && return nothing
    return @inbounds Some(x.heap[1][1])
end

end # module KWayMerges
