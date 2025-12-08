# Part 1 (`a.exs`)

I had the basic concept down pretty quickly for part 1, but I ran into issues with circuit merging.  I gave each node an ID based on its line number, then determined the N closest boxes to connect — 10 for the example data, 1000 for the real data — and then reduced that to just a list of `{id1, id2}` tuples to join.

My thinking was that I could just use a map of `box_id => circuit_id`, where `circuit_id` was just the ID of the first box in the circuit.  Then, when joining `id1` and `id2` into a circuit, I could just look if either one of those IDs was already in that map (i.e. already in a circuit).  If so, I assigned them both to that circuit ID.  If not, I assigned them both to a new circuit with ID `id1`.

Problem was, this got me the right answer for the example, but the wrong answer for the real data.  And worse, if I changed the order I did the joins, I got a different answer!  I eventually realised that I was running into situations where both `id1` and `id2` were in _different existing_ circuits that needed to be merged.  (In hindsight, it should have been obvious that this would happen, but apparently I thought that sorting the "to join" pairs ahead of time would somehow avoid this.)

I tried doing a `reduce` that kept a map of circuit contents by ID (so I knew what boxes might need merging) **and** a mapping of box IDs to circuit IDs (so I could quickly look up what circuit a box was already in, if any).  But this got messy fast, especially when it came time to do merges, which would now need to change the circuit ID of every relevant box.  So I decided to see if this was just premature optimisation, and tried just keeping a single list of circuits (albeit as a `Map` so I could easily update it).

The final circuit structure thus ended up being a Map of some arbitrary key — again, I just used the `id1` of the join that first created the circuit — to a `MapSet` containing the entire contents of a circuit.  Joining two boxes would just involve runnng through the entire map looking for circuits containing either of the boxes.  If I found nothing, I built a new circuit.  If I found just one entry, it meant one of them was in a circuit (or they were already both in the same one), and I could just put both IDs into that circuit.  And if I found two, then I just needed to `MapSet.union` the two circuits into a single entry.

# Part 2 (`b.exs`)

Part 2 was pretty easy given my solver for part 1.  I just needed to ditch the limit on how many joins we did, stop as soon as any circuit contained all boxes, and report the coordinates of the join that caused that to happen.

This meant my `reduce` became a `reduce_while`, in which I would take the first circuit in my circuit list, and see if it had N entries, where N is the total number of boxes.  (It's not enough to just check if we have a single circuit, since that might happen multiple times without actually containing all boxes.)

If we find one giant circuit, then we're done.  We can `:halt` out of the `reduce_while`, returning the box IDs that caused the final merge.  Turn those IDs back into box coordinates, multiply their X values, and we're done.
