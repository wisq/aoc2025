# Part 1 (`a.exs`)

For part 1, I kept a set of unique beam columns between rows.  At each row, I took a list of columns that a) were splitters, and b) had existing beams.  I counted that list and added it to the tally, then for each split, I deleted the beam at that column and added beams on adjacent columns.

# Part 2 (`b.exs`)

For part 2, I just changed the set of beam columns, into a map of number of beams by column.  Splitting N beams at column C just zeroed out the number of beams for C, then added N beams to C-1 and C+1.  The final tally is just a sum of the map values.
