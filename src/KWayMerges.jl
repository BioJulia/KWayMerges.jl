module KWayMerges

export KWayMerger

include("heap.jl")

"""
    KWayMerger{T, I, F}(f::F, iterators)
    KWayMerger{T, I}(iterators)
    KWayMerger(f, iterators)
    KWayMerger(iterators)

Create a stateful iterator which does a k-way merge between multiple
iterators of the same type.

This iterator yields `(index::Int, x::T)` elements, where `x` is the next element from
one of the iterators, and `index` is the 1-based index of the iterator that yielded `x`.
The elements `x` are chosen from among the iterators such that, among all elements which
are the next element of the iterators, the element is chosen which is the smallest
according to the predicate `f::F`, which defaults to `isless`.

This implies that if all iterators are sorted by `f`, the yielded will be in sorted
order.
Hence, a `KWayMerger` is typically used to combined multiple sorted arrays
into one sorted array.

# Examples
```jldoctest
julia> arrs = [[1,6], [2], [5,7], [3,4,8]];

julia> it = KWayMerger(arrs);

julia> print(collect(it))
[(1, 1), (2, 2), (4, 3), (4, 4), (3, 5), (1, 6), (3, 7), (4, 8)]
```

# Extended help
The type parameters are:
* `F`: Type of function used to compare the elements. It defaults
  to `typeof(Base.isless)`
* `T`: Element type of iterators
* `I`: Iterator type
* `S`: Type of state of iterators

All iterators must be of the same type. For the constructors which don't pass
in `T` and `I` explicitly, `Base.eltype` is used
to determine them; since its default implementation
returns `Any`, explicitly passing them may be needed for good performance for some
iterators.

`S` is derived automatically, but this must be a fixed type;
iterators that use states of multiple different types may
not be supported by `KWayMerger`.
"""
struct KWayMerger{T, I, F, S}
    f::F
    iterators::Vector{I}
    states::Vector{S}
    heap::Vector{Tuple{Int, T}}
end

ord(x::KWayMerger) = ord(x.f)
ord(f) = (i, j) -> f(last(i), last(j))

function KWayMerger{T, I, F}(f::F, iterators) where {T, I, F}
    iters = vec(collect(iterators))
    states = nothing
    things = Tuple{Int, T}[]
    for i in eachindex(iters)
        it = iterate(iters[i])
        isnothing(it) && continue
        (thing::T, state) = it
        if isnothing(states)
            states = Vector{typeof(state)}(undef, length(iters))
        end
        push!(things, (i, thing))
        states[i] = state
    end
    heapify!(ord(f), things)
    states = if isnothing(states)
        Vector{Union{}}(undef, length(iters))
    else
        states
    end
    return KWayMerger{T, I, F, eltype(states)}(f, iters, states, things)
end

function KWayMerger{T, I}(iterators) where {T, I}
    return KWayMerger{T, I, typeof(isless)}(isless, iterators)
end

KWayMerger(iterators) = KWayMerger(isless, iterators)

function KWayMerger(f::F, iterators) where {F}
    I = eltype(typeof(iterators))
    T = eltype(I)
    return KWayMerger{T, I, F}(f, iterators)
end

# We could technically know this, but KWayMerger is stateful, and
# Julia's iterator length works badly with stateful iterators.
Base.IteratorSize(::Type{<:KWayMerger}) = Base.SizeUnknown()
Base.eltype(::Type{<:KWayMerger{T}}) where {T} = Tuple{Int, T}

function Base.iterate(x::KWayMerger, ::Nothing = nothing)
    isempty(x.heap) && return nothing
    (i, item) = @inbounds x.heap[1]
    iterator = @inbounds x.iterators[i]
    state = @inbounds x.states[i]
    it = iterate(iterator, state)
    if it === nothing
        @inbounds heappop!(ord(x.f), x.heap)
    else
        (new_item, new_state) = it
        @inbounds x.states[i] = new_state
        @inbounds heapreplace!(ord(x.f), x.heap, (i, new_item))
    end
    return ((i, item), nothing)
end

Base.isempty(x::KWayMerger) = isempty(x.heap)
Base.isdone(x::KWayMerger) = isempty(x.heap)

"""
    peek(x::KWayMerger{T})::Union{Tuple{Int, T}, Nothing}

Get the first element of `x` without advancing the iterator, or `nothing` if the
iterator is empty.

# Examples
```jldoctest
julia> it = KWayMerger([[3, 4], [2, 7]]);

julia> peek(it)
(2, 2)

julia> collect(it); # exhaust stateful iterator

julia> peek(it) === nothing
true
```
"""
function Base.peek(x::KWayMerger)
    isempty(x.heap) && return nothing
    return @inbounds x.heap[1]
end

end # module KWayMerges
