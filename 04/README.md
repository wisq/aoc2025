# Part 1 (`a.exs`)

No real suprises here.  It's really just how efficiently can you manage a grid in your target language?  I learned a long time ago that in immutable languages like Erlang/Elixir, where array random reads and _especially_ random writes are very costly, the best strategy is a `Map` of coordinates to values.  (The nice thing is, that also implicitly covers out-of-bounds issues, since reading out of bounds just gets you "nothing there", same as if it was an empty node.)

# Part 2 (`b.exs`)

Part 2 was pretty predictable after seeing part 1, and so it's just a question of turning the removal algorithm into a function so I can call it recursively.  (The quickest way to remove nodes is just to map the "to remove" list a new partial grid of empty spots, and `Map.merge` that into the old grid.)  Just repeat until you have any pass where you can't remove anything.

I kinda got lucky in that my chosen way of doing it (functional whole-grid updates) is also exactly what the example has you doing.  I'm not, for example, just using a single mutable 2D array as my grid, and updating nodes as I remove them — which would then _immediately_ influence the decision making for adjacent nodes, i.e. in the current pass rather than the next one.

Assuming your language is okay with mutable 2D arrays (i.e. most other languages), then it's not actually a problem to do it that way — you'll still get the correct answer in the end, and probably faster, plus you could have removals chain into checks on adjacent nodes and speed it up further.  But it won't match how the example does it, which might make any errors harder to identify.
