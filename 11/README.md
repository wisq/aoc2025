# Part 1 (`a.exs`)

Very simple, just have each node return a sum of the paths to out via its connected nodes.

I tried memoizing this for fun, but it was so short and simple that memoization actually just slowed it down.

# Part 2 (`b.exs`)

Here's where memoization is necessary.  Other than that, I kept it fast by just splitting that "paths to out" count into four different flavours:

- "naked" paths (no DAC or FFT)
- paths via DAC (but not FFT)
- paths via FFT (but not DAC)
- paths via both DAC and FFT

So when you hit DAC, you just promote "naked" to DAC, and promote FFT to DAC+FFT.  And when you hit FFT, you promote "naked" to FFT, and promote DAC to DAC+FFT.

Far easier than the previous part 2s, but only because I reached for memoization so quickly.  Aside from that, I suspect the other main pitfall would be trying to walk or record paths, instead of just counting them.
