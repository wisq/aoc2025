# Part 1 (`a.exs`)

This uses a dirt simple `Enum.reduce`.  Only fancy bit here is that `Integer.mod/2` makes things a lot cleaner than trying to do `div` and then correct for negatives.

# Part 2 (`b.exs`)

Here's where things gets trickier — I initially tried to have a unified function that just constrained it to the `0..99` range and counted the number of times that it escaped that range, either upwards or downwards.  But that got overly complex because I would need to track starting state to make sure that a leftwards movement _starting at_ zero didn't count as "crossing zero" just because it was negative.  So I decided instead to split them into left and right functions and special-case the "left from zero" case.

The one part I'm not totally happy with (i.e. convinced it's the most graceful approach) is how `constrain_left` recursively calls itself in the deep-negative case.  Effectively it just always gets `p` into the range of -99 to 0, and then hands it off to either the "-99 to -1" case or the zero case as needed.  I could easily constrain `p` to a positive range if I used `Integer.mod`, but then I'm faced with the issue of counting how many times that happens, of adding an extra count if it exactly hits zero, etc.  Seemed easier to just use recursion.

It's also entirely possible to rely *only* on recursion, ditching all uses of `div` and `rem` for just "recursively call yourself with `p` that is 100 closer to the `0..99` range and `z + 1` as the zero count".  And the performance is fine, it's a valid approach for the number of digits we're given, and only starts to get slow if your data demands spins in the range of tens of billions.
