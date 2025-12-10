# Part 1 (`a.exs`)

Super easy, barely an inconvenience.  I did the same thing I did in day 8 to calculate the distances between all nodes — for any node at position N, you only need to compute squares with all the nodes at positions `N+1` and onwards.  This halves the number of checks required — although the checks themselves are cheap enough that it may or may not even matter.

Since all we need is the maximum rectangle size, there's no need to keep 123k rectangles and sort them by size.  Instead, we just use `max` to continually track the biggest possible rectangle size we've found so far.

# Part 2 (`b.exs`)

Part 1 felt so easy that I figured they had to be setting us up for a doozey of a part 2, and they did not disappoint, at least at first glance.

I was beginning to think that my choice of language was going to screw me.  The way the problem explained it, it looked like I really was going to need a fast, mutable, random-access, read-write grid structure — something I just can't possibly have in Elixir, with its immutable data structures.

I briefly considered encoding the entire grid in a single binary string — since Elixir's `binary_part` function _is_ fast random access, at least according to my understanding of the docs — and using math to be able to randomly access any given X/Y coordinates, with the added bonus that I could read potentially large horizontal chunks in a single operation.  But I realised that writes would be _horrendously_ slow.  (One of the main reasons I wanted a grid was to be able to do a flood fill on both sides of a given edge to see which part was inside and which was outside, and that would have been _way_ too many writes to be feasible.)

Plus, even if I did manage to get a working fast grid structure, the number of reads to determine if a rectangle was legit would be _insane_.  Like my final result was over _one billion points_ in size.  I can't imagine having to check millions or billions of coordinates for each and every rectangle to see if it's limited to red/green tiles.

Eventually I realised that there was a much easier way to disqualify a rectangle: If any edge were to touch the _inside_ of the rectangle (i.e. not including the rectangle's one-tile border), then it doesn't really matter which side of that edge is inside or outside — the rectangle now contains at least one outside pixel, and is thus invalid.

So I compiled the list of edges into tuples of either `{x, y1..y2}` (a vertical line on column `x`) or `{x1..x2, y}` (a horizontal line on row `y`).  A rectangle with upper left coordinate of `x1..y1` and lower right coordinate of `x2..y2` would be invalid if there was any edge within the rectangle formed by `{x1+1, y1+1}` at the top left and `{x2-1, y2-1}` at the bottom right.

The final script still only took about five seconds to run, but parallelising it with `Task.async_stream` got that down to just one second, nearly a third of which is just basic startup time anyway.

I later realised that another possible optimisation would be to check rectangle size **before** checking for intrusions, and throw any any rectangle that was smaller than the biggest known valid rectangle so far.  This reduced the runtime of the non-parallel version from 5 to 2.5 seconds, but had no discernible effect on the runtime of the parallel version.  Presumably this was because each process was tracking its biggest rectangle separately, meaning far fewer rectangles were eliminated before checking their validity.

However, this led to a minor optimisation that did actually work in the parallel case: Instead of just tracking the largest valid rectangle, each process could instead record all possible rectangles, sort them by size (descending), and then return the size of the first valid (non-intersecting) rectangle.  This eliminated far more rectangles (since each process no longer had to test multiple smaller rectangles before it got to the biggest one), which boosted performance by about 8%.

## Alternate implementations (`b2.exs`, `b2gs.exs`)

`b2.exs` switches us back to an implementation much more similar to `a.exs` — a simple `reduce` that only keeps track of the biggest size it's seen — but that still runs in parallel, using an ETS to store the current biggest known rectangle size at the end of each parallel process.  It achieves the best of both worlds, with later processes greatly benefitting from the filtering wisdom of their predecessors.

One flaw with the ETS implementation is that updates are not truly atomic.  We do make an effort to "get" (ETS `lookup`) right before we "put" (ETS `insert`) to ensure that we're not _lowering_ the ETS value, but with all the concurrent writes going on, that's pretty much guaranteed to happen at some point anyway.  However, there's enough processes reading and writing at once that it's likely that any "bad" value (lower than the current max) will get overwritten by some other process that already read and started with the "good" value, then wrote that value (or something better) back before it exited.

Due to this atomicity problem, it's also important to never use this ETS `max_size` value as the final answer, since it may or may not be correct.  (It's not a guaranteed source of truth, just a best-effort optimisation persistence tool.)

`b2gs.exs` is a cleaner and more idiomatic version that uses a `GenServer` to atomically update the "biggest size seen" counter.  Performance wise, it's pretty much exactly on par with the ETS version, which shows that the ETS atomicity problem is not a huge deal in this case.
