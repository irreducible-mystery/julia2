\ ============================================================
\ FORTH'S NEGATIONS SEAM-FOR-SEAM -- negation as BIT SURGERY
\ Forth has THREE nots and no truth: invert (bitwise), 0= (test),
\ negate (arithmetic). Each has a seam where "not" leaks machine.
\ ============================================================

decimal

.( === 1. Forth has THREE negations, none of them logical === ) cr
.(   invert -1 -> ) -1 invert . cr
.(   invert 0  -> ) 0 invert . cr
.(   0= 0      -> ) 0 0= . cr
.(   0= 5      -> ) 5 0= . cr
.(   negate 7  -> ) 7 negate . cr
.(   invert flips 64 bits; 0= tests; negate is two's complement. ) cr
.(   'not' was REMOVED from ANS Forth: the committee could not agree ) cr
.(   whether it meant invert or 0=. The seam was so real they ) cr
.(   deleted the word rather than pick a side. ) cr cr

.( === 2. The well-formedness seam: invert on a non-flag === ) cr
.(   5 invert -> ) 5 invert . cr
.(   5 is 'true' by convention [nonzero], but invert 5 = -6: ALSO ) cr
.(   nonzero, ALSO true! Bitwise not of a truthy value stays truthy. ) cr
.(   THE LIAR DISSOLVES: x = invert x has no solution in bits, but ) cr
.(   x = [x 0=] has none either, while 'truthy x = invert x' is ) cr
.(   SATISFIED by every value except 0 and -1. On flags-by-convention ) cr
.(   the liar is not even a constraint. Sloppy truth cannot detonate. ) cr cr

.( === 3. The involution seam: which nots undo themselves? === ) cr
.(   5 invert invert -> ) 5 invert invert . cr
.(   5 0= 0=         -> ) 5 0= 0= . cr
.(   invert invert = identity, ALWAYS -- bit algebra, like BQN's 1-x. ) cr
.(   0= 0= is NOT identity: 5 -> 0 -> -1. It NORMALIZES: collapses ) cr
.(   truthy to canonical -1. Exactly Prolog's \+ \+ : a proof-test ) cr
.(   composed with itself loses information [which nonzero it was] ) cr
.(   and returns the CANONICAL witness. Forth's 0= 0= is \+ \+ in bits. ) cr cr

.( === 4. De Morgan seam: holds for bits, breaks for flags === ) cr
.(   bitwise: 12 10 and invert -> ) 12 10 and invert .
.( = ) 12 invert 10 invert or . .( ...bit-perfect ) cr
.(   flags:   5 3 and 0=       -> ) 5 3 and 0= .
.( vs ) 5 0= 3 0= or . cr
.(   5 and 3 = 1 [nonzero=true] so NOT[5 and 3] = false: correct ONLY ) cr
.(   because 5,3 share bit 0. Try 5 2: ) cr
.(     5 2 and 0=  -> ) 5 2 and 0= .
.(  [5 AND 2 = 0: 'false'!] ) cr
.(     but both 5,2 are truthy: logical AND should be TRUE, not-AND false. ) cr
.(   SEAM: bitwise and on flags is not logical conjunction unless flags ) cr
.(   are canonical [-1/0]. Two truthy values can bitwise-and to 0. ) cr
.(   Same lesson as BQN sec 3: export logic to another algebra and the ) cr
.(   laws hold only on the well-formed subdomain -- Forth does not even ) cr
.(   warn you; the machine has no notion of 'malformed flag'. ) cr cr

.( === 5. negate's seam: the value with no negation === ) cr
.(   most-negative int: ) -9223372036854775808 . cr
.(   its negate:        ) -9223372036854775808 negate . cr
.(   negate maps INT_MIN to ITSELF: two's complement has one more ) cr
.(   negative than positive. A fixed point of negation -- the Liar's ) cr
.(   x = not x -- EXISTS IN THE HARDWARE, at the edge of the number ) cr
.(   circle. BQN put the liar's fixed point at 1/2 by algebra; the ) cr
.(   machine puts one at -2^63 by wraparound. Every negation that is ) cr
.(   total on a finite domain MUST have a fixed point or a defect: ) cr
.(   pigeonhole. Truth-negation avoids it only by being partial. ) cr

bye
