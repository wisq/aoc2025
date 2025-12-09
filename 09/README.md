# Part 1 (`a.exs`)

Super easy, barely an inconvenience.  I did the same thing I did in day 8 to calculate the distances between all nodes — for any node at position N, you only need to compute squares with all the nodes at positions `N+1` and onwards.  This halves the number of checks required — although the checks themselves are cheap enough that it may or may not even matter.

Since all we need is the maximum rectangle size, there's no need to keep 123k rectangles and sort them by size.  Instead, we just use `max` to continually track the biggest possible rectangle size we've found so far.

# Part 2 (`b.exs`)

TBD
