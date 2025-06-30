# <img src="./sticker.svg" width="30%" align="right" /> KWayMerges.jl

[![Latest Release](https://img.shields.io/github/release/BioJulia/KWayMerges.jl.svg)](https://github.com/BioJulia/KWayMerges.jl/releases/latest)
[![MIT license](https://img.shields.io/badge/license-MIT-green.svg)](https://github.com/BioJulia/KWayMerges.jl/blob/master/LICENSE)
[![](https://codecov.io/gh/BioJulia/KWayMerges.jl/branch/master/graph/badge.svg)](https://codecov.io/gh/BioJulia/KWayMerges.jl)

Implementation of k-way merge.

This package implements the `KWayMerger` type.
It is a stateful, lazy iterator of the elements in an iterator of iterators.
The elements of the inner iterators will be yielded in an order given by a predicate optionally passed to `KWayMerger` (default: `isless`).
Therefore, if the inner iterators are sorted by the predicate, the output of the `KWayMerger` is also guaranteed to be sorted.

The primary purpose of `KWayMerger` is to efficiently merge N sorted iterables into one sorted stream.

The iterator yields `(i::Int, x)` tuples, where `x` is the next element of one of the iterators, and `i` is the 1-based index of the iterator that yielded `x`:

```julia
julia> it = KWayMerger([[2, 3], [1, 4]]);

julia> first(it)
(2, 1)

julia> println(collect(it))
[(1, 2), (1, 3), (2, 4)]
```

The function `peek` can be used to check the next element without advancing the iterator:

```julia
julia> it = KWayMerger([1]);

julia> peek(it)
(1, 1)

julia> first(it)
(1, 1)

julia> peek(it) === nothing
true
```

## Documentation
This package's public functionality are the `KWayMerger` type, and its `Base.peek` method.
See their docstrings for more details.

## Performance
When merging I iterables with a total length of N:
* A `KWayMerger` allocates O(I) space upon construction 
* Producing each element takes O(log(I)) time

Therefore, merging I sorted iterables with N total elements using a KWayMerger therefore takes O(N * log(I)) time.
It is generally faster than flattening the iterators and sorting, when I << N.
Note that Julia uses radix sort for integers, which sorts in O(N), and therefore usually beats a k-way merge.

## Contributing
We appreciate contributions from users including reporting bugs, fixing
issues, improving performance and adding new features.

Take a look at the [contributing files](https://github.com/BioJulia/Contributing)
detailed contributor and maintainer guidelines, and code of conduct.

## Questions?
If you have a question about contributing or using BioJulia software,
come on over and chat to us on [the Julia Slack workspace](https://julialang.org/slack/),
or you can try the [Bio category of the Julia discourse site](https://discourse.julialang.org/c/domain/bio).
