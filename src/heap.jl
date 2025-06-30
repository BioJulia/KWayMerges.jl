@inline function heapify!(f, xs::Vector)
    for i in div(length(xs), 2):-1:1
        percolate_down!(f, xs, i, xs[i])
    end
    return xs
end

@inline function percolate_down!(
        f::F,
        xs::Vector,
        i::Integer,
        x,
    ) where {F}
    len = length(xs)
    @inbounds while (l = 2i) <= len
        r = 2i + 1
        j = if r > len || f(last(@inbounds(xs[l])), last(@inbounds(xs[r])))
            l
        else
            r
        end
        if f(last(@inbounds(xs[j])), last(x))
            @inbounds xs[i] = xs[j]
            i = j
        else
            break
        end
    end
    return @inbounds xs[i] = x
end

@noinline function heappop!(f, xs::Vector)
    isempty(xs) && throw(BoundsError(xs, 1))
    x = @inbounds xs[1]
    y = @inbounds pop!(xs)
    if !isempty(xs)
        percolate_down!(f, xs, 1, y)
    end
    return x
end

@inline function heapreplace!(f, xs::Vector, x)
    @boundscheck isempty(xs) && throw(BoundsError(xs, 1))
    res = @inbounds xs[1]
    @inbounds xs[1] = x
    percolate_down!(f, xs, 1, x)
    return res
end
