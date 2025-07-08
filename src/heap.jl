@inline function heapify!(o::Ordering, xs::Vector)
    for i in div(length(xs), 2):-1:1
        percolate_down!(o, xs, i, xs[i])
    end
    return xs
end

@inline function percolate_down!(
        o::Ordering,
        xs::Vector,
        i::Integer,
        x,
    )
    len = length(xs)
    @inbounds while (l = 2i) <= len
        r = 2i + 1
        j = if r > len || lt(o, last(@inbounds(xs[l])), last(@inbounds(xs[r])))
            l
        else
            r
        end
        if lt(o, last(@inbounds(xs[j])), last(x))
            @inbounds xs[i] = xs[j]
            i = j
        else
            break
        end
    end
    return @inbounds xs[i] = x
end

@noinline function heappop!(o::Ordering, xs::Vector)
    isempty(xs) && throw(BoundsError(xs, 1))
    x = @inbounds xs[1]
    y = @inbounds pop!(xs)
    if !isempty(xs)
        percolate_down!(o, xs, 1, y)
    end
    return x
end

@inline function heapreplace!(o::Ordering, xs::Vector, x)
    @boundscheck isempty(xs) && throw(BoundsError(xs, 1))
    res = @inbounds xs[1]
    @inbounds xs[1] = x
    percolate_down!(o, xs, 1, x)
    return res
end
