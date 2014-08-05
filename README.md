SwiftCardPlayground
===================

A Swift-only playground that I made in order to help me understand how to implement efficient generators for Swift enum types.

## Motivation

Implement Swift-style rich enums with efficient generators, in the sense that the generators have constant memory footprint regardless of the size of the dimension that they cover.

## Example
A `Card` has `Rank` and `Suit`. A deck of cards is generated by `SuitGenerator` and `RankGenerator`, which each have `O(0)` complexity. 

##Implementation

Both `Rank` and `Suit` implement a `next()` method that ultimately returns `nil` when the enum is exhausted.

Both `Rank` and `Suit` expose a generator that defaults to being initialized with the first member of the sequence.

Thus, knowledge of the "first" and "last" elements of the sequence is confined within the respective enums.

It then becomes a simple matter of declaring `typealias GeneratorType = BlahGenerator` and implementing `func generate()` to return `BlahGenerator(blah: self)`.

## Testing

Testing is done in-line with raw `assert()` calls. In production code I would of course pull these out into proper test classes.

## Generalisation

This could be made more generic, and a past incarnation of me used to do that sort of thing in C++. Let's just say that I don't really fancy those sorts of high-jinks any more. Template meta-programming is something I could _really_ do without.

## Licence

MIT licence. I'm not fussed about attribution for something this trivial, so do with this code as you like.
