# <img src="./sticker.svg" width="30%" align="right" /> KWayMergers.jl

[![Latest Release](https://img.shields.io/github/release/BioJulia/KWayMergers.jl.svg)](https://github.com/BioJulia/KWayMergers.jl/releases/latest)
[![MIT license](https://img.shields.io/badge/license-MIT-green.svg)](https://github.com/BioJulia/KWayMergers.jl/blob/master/LICENSE)
[![Documentation](https://img.shields.io/badge/docs-dev-blue.svg)](https://biojulia.github.io/KWayMergers.jl/dev)
[![](https://codecov.io/gh/BioJulia/KWayMergers.jl/branch/master/graph/badge.svg)](https://codecov.io/gh/BioJulia/KWayMergers.jl)

Implementation of k-way merge.

This package implements `kway_merge(x::AbstractVector{<:AbstractVector})`, which returns a `KWayMerger`.
This type is a lazy iterator of the elements in the inner vectors. If the inner vectors are sorted, the output of the `KWayMerger` is also guaranteed to be sorted.

The function `peek` can be used to check the next element without advancing the iterator. 

## Contributing
We appreciate contributions from users including reporting bugs, fixing
issues, improving performance and adding new features.

Take a look at the [contributing files](https://github.com/BioJulia/Contributing)
detailed contributor and maintainer guidelines, and code of conduct.

## Questions?
If you have a question about contributing or using BioJulia software,
come on over and chat to us on [the Julia Slack workspace](https://julialang.org/slack/),
or you can try the [Bio category of the Julia discourse site](https://discourse.julialang.org/c/domain/bio).
