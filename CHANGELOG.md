# Changelog
All notable changes to this project will be documented in this file.
Take care to mention breaking changes and critical bug fixes. 

This project adheres to [Semantic Versioning](http://semver.org/spec/v2.0.0.html).

## UNRELEASED
* Add content here that have been merged, but not made it to a release yet.

## [0.2.0]
### Breaking changes
* The public constructor for the `KWayMerger` is now the new `kway_merge` function.
  `KWayMerger` is public, but unexported.
* Instead of the `F` parameter (and argument to its constructor), `kway_merge`
  uses the same ordering API as Base's sorting functions.
* `KWayMerger{T}` now iterates `@NamedTuple{from_iter::Int, value::T}`, to reduce
  the risk of users conflating the two elements of the tuple.


## [0.1.0]
* Initial release
