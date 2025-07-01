module t

# TODO: The tree needs to remove Nothing's to be efficient.
# * Do not pad to power of two.
# * Every time an iterator is exhausted, re-build the tree.

struct LoserTree{T, I, S}
    # The loser tree. Index 1 is winner, rest is the loser tree.
    # Except node 1, node x' parents is 2x - 1 and 2x.
    # Padded with `nothing` to be a power-of-two long

    # TODO: The vector lengths never changes, and it would be nice if they were
    # constant propagated. So, use Memory{T} when it's supported by Julia LTS
    tree::Vector{Union{Tuple{Int, T}, Nothing}}
    iters::Vector{I}
    states::Vector{S}
end

function nextpow_2(x)
    B = 8 * sizeof(x)
    s = B - leading_zeros(x - 1)
    return one(x) << (s & (B - 1))
end

function LoserTree(it)
    iters = collect(it)
    I = eltype(iters)
    T = eltype(I)
    tree = fill!(Vector{Union{Tuple{Int, T}, Nothing}}(undef, nextpow_2(length(iters))), nothing)
    states = init_tree!(tree, iters)
    return LoserTree{T, I, eltype(states)}(tree, iters, states)
end

function init_tree!(tree::Vector{Union{Nothing, Tuple{Int, T}}}, iters::Vector)::Vector where {T}
    isempty(iters) && return Vector{Union{}}
    (val, states) = _init_tree(tree, 2, nothing, iters)
    tree[1] = val
    return if states === nothing
        Vector{Union{}}(undef, length(iters))
    else
        states
    end
end

function _init_tree(tree, i, states, iters)::Tuple{Union{Nothing, Tuple{Int, Any}}, Union{Nothing, Vector}}
    if i > length(tree)
        iter_i = i - length(tree)
        return if iter_i > length(iters)
            (nothing, states)
        else
            iter = iters[iter_i]
            itval = iterate(iter)
            if itval === nothing
                (nothing, states)
            else
                (val, state) = itval
                if states === nothing
                    states = Vector{typeof(state)}(undef, length(iters))
                end
                states[iter_i] = state
                ((iter_i, val), states)
            end
        end
    else
        (x1, states) = _init_tree(tree, 2i - 1, states, iters)
        (x2, states) = _init_tree(tree, 2i, states, iters)
        (winner, loser) = get_winner_loser(x1, x2)
        tree[i] = loser
        return (winner, states)
    end
end

function get_winner_loser(a::Union{Nothing, Tuple{Int, Any}}, b::Union{Nothing, Tuple{Int, Any}})
    return if a === nothing
        (b, a)
    elseif b === nothing
        (a, b)
    elseif last(a) < last(b)
        (a, b)
    else
        (b, a)
    end
end

@inline function bubble_up!(tree::Vector{Union{Nothing, Tuple{Int, T}}}, winner::Union{Nothing, Tuple{Int, T}}, pi::Int) where {T}
    n_iters = trailing_zeros(length(tree))
    i = 0
    @inbounds while i < n_iters
        parent = tree[pi]
        (winner, loser) = get_winner_loser(winner, parent)
        tree[pi] = loser
        pi = (pi + 1) >>> 1
        i += 1
    end
    @inbounds tree[1] = winner
    return nothing
end

Base.IteratorSize(::Type{<:LoserTree}) = Base.SizeUnknown()
Base.eltype(::Type{<:LoserTree{T}}) where {T} = Tuple{Int, T}

function Base.iterate(x::LoserTree, _state::Nothing = nothing)
    result = @inbounds x.tree[1]
    result === nothing && return result
    (i, element) = result
    state = @inbounds x.states[i]
    itval = iterate(@inbounds(x.iters[i]), state)
    new_val = if itval === nothing
        nothing
    else
        (new_element, new_state) = itval
        @inbounds x.states[i] = new_state
        (i, new_element)
    end
    pi = (i + nextpow_2(length(x.iters)) + 1) >>> 1
    bubble_up!(x.tree, new_val, pi)
    return ((i, element), nothing)
end

end # module
