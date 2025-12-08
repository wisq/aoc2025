
# Part 1 (`a.exs`)

My initial part 1 version worked, but was accidentally overengineered.  I would drop the last digit (since you can't **start** a 2-digit number with the last digit), sort the rest by high digits + early indices first (because a 9 that comes earlier is better than a 9 that comes later), and then use the highest digit that comes after that as the second digit.  (So far so good.)

Then, I would use `reduce_while` to iterate through that sorted list of digits, looking for the highest number and stopping when the number started going down.

What I didn't realise was that I would 100% guaranteed always find the highest 2-digit number on my first pass, so my `reduce_while` was pointless.  So the version here is much simpler as a result.  (The original version is available in the git history.)

# Part 2 (`b.exs`)

Part 2 was way easier than I thought.  Just repeat the same pattern, but recursively.  To find the highest `n` digit joltage in `batteries`:

- drop the last `n-1` digits from `batteries` — you obviously can't start your 12-digit number with any of the last 11 digits
- of those, find the highest digit (main condition) with the earliest index (tiebreaker) — that's your first digit, guaranteed
- now just repeat this procedure recursively, with `batteries` being all the digits after your chosen digit (including the ones you dropped), and `n` being `n - 1`
