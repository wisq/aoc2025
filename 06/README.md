# Part 1 (`a.exs`)

There's a lot of ways to tackle part 1, but I chose to challenge myself to continue just reading line-by-line, not peeking ahead to see what the operations are.  I also decided that since the only two operations are addition and multiplication, I wouldn't actually bother to store the numbers themselves, I would just keep a running sum and product, with the final (operations) row deciding which one of those I used.

This also meant I didn't need to bother using a grid, because I could just zip each line with the tally from the line before.  Zipping a number with the tally would add that number to the sum and multiply that number into the product, while zipping an operation with the tally would pick which tally result to use.  Then you're just left with a list of numbers that you can sum.

The only tricky bit here was generating the initial list of tally tuples.  Since the `Enum.zip` functions stop as soon as _any_ enumerable ends, and I didn't know how many columns the input would be, my initial list of tallies was just an infine `Stream` of them, which could thus "expand" to handle any number of columns.

# Part 2 (`b.exs`)

For part 2, I did have to read the whole file, but I still managed to avoid any sort of grid storage or lookups.  I turned it into a 2D list of each character, transposed that, then started from the rightmost column (now the bottom entry) and worked my way left (now up), keeping a tally for the current problem, and a grand total sum for all the problems.  (Again, we still only have two operations, so I used the same "sum and product" tally concept.)

The inclusion of fully blank columns — now rows, so basically when the whitespace-trimmed "number" is just an empty string — means I can use those as the trigger condition for resetting the tally.  Obviously this would result in weird incorrect data if you somehow had multiple operations per number set, or if the operation wasn't on the leftmost column of each number set.  But if there's one thing you can count on with AoC, it's that the input will be well-formed (unless your job is specifically to fix bad input, anyway).

## Alternate implementation (`b2.exs`)

I decided to get silly and try just doing everything by streaming data off a single filehandle, without reading the whole file first.  As such:

- read the first line and use only the size of that line to calibrate our expected line length
- get the file size by seeking to EOF
- verify the file meets our length expectations (e.g. I had to add an end-of-file newline to `example.txt` to "fix" it for this)
- calculate how many lines there are, and the starting offsets for each line
- read just the last line (using our calculated offset for it)
- use a regex to break it up into precise problem areas (offset within line, size)
- for each line, read just our problem area
- choose either `Enum.sum/1` or `Enum.product/1` as our math function, based on the operation _(it's very handy that these both already exist!)_
- do the normal solution (transpose, turn into numbers, apply the math function)

It's about 28x slower(!!) than the much more normal solution in `b.exs`, but it's a fun use of range math and `:file` seeking operations, and it can theoretically scale to any file size without memory issues.  (But I suspect you would run into execution time issues _long_ before you ran into memory issues anyway.)

Also worth noting that despite the examples going right-to-left, there's absolutely no requirement to do so.  It does make it easier if you're going purely gridwise like I did in my original `b.exs`, since the operator is the very last thing you see on the very last "row" (right-to-left column), right at the exact time that you need to know what to add to the grand total.  But both of our chosen operations (add, multiply) are commutative, so if you know exactly what your current problem's bounding box is, there's no reason you need to stick to RTL order.
