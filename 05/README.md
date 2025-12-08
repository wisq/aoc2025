# Part 1 (`a.exs`)

Part 1 felt way too easy, like it should've been our day 1 puzzle instead of the safe-cracking thing.  It's just a parsing problem, and while I chose to do it all in a single, non-modal, line-by-line `reduce` block (for funsies), the data size is such that I could've just as easily read the whole file and split by double newline and handled each block separately.

# Part 2 (`b.exs`)

Part 2 was a bit trickier, but I decided from the get-go that the easiest way would be to just ensure that I had a list of _fully disjoint_ ranges at all times.  As such, any time a new range overlapped with any existing ranges, I merged all those ranges into one single larger range.  Then it was just a question of adding up the range sizes.

In both cases, I had the advantage of Elixir's native Range type, and the `Range.disjoint?` and `Range.size` functions, but I could have just as easily represented them as `{min, max}` tuples and written my own function equivalents.

A colleague suggested that I could have make this faster by sorting the ranges by their starting value (ascending), and only checking if a new range overlapped with the last range I added (rather than checking all of them).  And that's true, but it also means I can't do pure line-by-line parsing — and for the sizes we're working with, it's not really needed anyway.

