# <img src="./sticker.svg" width="30%" align="right" /> KWayMerges.jl

[![Latest Release](https://img.shields.io/github/release/BioJulia/KWayMerges.jl.svg)](https://github.com/BioJulia/KWayMerges.jl/releases/latest)
[![MIT license](https://img.shields.io/badge/license-MIT-green.svg)](https://github.com/BioJulia/KWayMerges.jl/blob/master/LICENSE)
[![](https://codecov.io/gh/BioJulia/KWayMerges.jl/branch/master/graph/badge.svg)](https://codecov.io/gh/BioJulia/KWayMerges.jl)

Implementation of k-way merge.

This package exports the function `kway_merge`.
It constructs a `KWayMerger` - a stateful, lazy iterator of the elements in an iterator of iterators.
The elements of the inner iterators will be yielded in order, as specified by the optional ordering (default: `Forward`).
Therefore, if the inner iterators are sorted by the order, the yielded elements of the `KWayMerger` is also guaranteed to be sorted.

The primary purpose of `kway_merge` is to efficiently merge N sorted iterables into one sorted stream.

The iterator yields `@NamedTuple{from_iter::Int, value::T}`, where the value field has the next element of one of the iterators, and the from_iter field contains the 1-based index of the iterator that yielded the value:

```julia
julia> it = kway_merge([[2, 3], [1, 4]]);

julia> first(it)
(from_iter = 2, value = 1)

julia> println(map(Tuple, it))
[(1, 2), (1, 3), (2, 4)]
```

The function `peek` can be used to check the next element without advancing the iterator:

```julia
julia> it = kway_merge([1]);

julia> peek(it)
(from_iter = 1, value = 1)

julia> first(it)
(from_iter = 1, value = 1)

julia> peek(it) === nothing
true
```

## Documentation
This package's public functionality are the `kway_merge` function, the (unexported) `KWayMerger` type, and its `Base.peek` method.
See their docstrings for more details.

## Performance
When merging I iterables:
* A `KWayMerger` allocates O(I) space upon construction 
* Producing each element takes O(log(I)) time

Therefore, merging I sorted iterables with N total elements using `kway_merge` takes O(N * log(I)) time.
This is similar to the O(N * log(N)) time taken for comparison-based sorts.
That's no co-incidence: One can take a list with N elements, separate it into N 1-element lists, then merge them with a kway-merge. That is a variant of merge sort.

However, compared to a comparison-based sort like quicksort, using a kway merge has the following differences:
* Usually, we have I << N, and therefore, kway merge is usually faster.
* For large I, quicksort is faster in practice because its overhead per element is smaller.

Note that Julia uses radix sort for integers, which sorts in O(N), and therefore usually beats a k-way merge.

## Contributing
We appreciate contributions from users including reporting bugs, fixing
issues, improving performance and adding new fea oftentures.

Take a look at the [contributing files](https://github.com/BioJulia/Contributing)
detailed contributor and maintainer guidelines, and code of conduct.

## Questions?
If you have a question about contributing or using BioJulia software,
come on over and chat to us on [the Julia Slack workspace](https://julialang.org/slack/),
or you can try the [Bio category of the Julia discourse site](https://discourse.julialang.org/c/domain/bio).
