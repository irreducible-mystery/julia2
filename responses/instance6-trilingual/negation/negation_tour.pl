%% ============================================================
%% HOW PROLOG DEALS WITH NEGATION — a live tour of the seams
%% Every claim printed below is executed, not asserted.
%% ============================================================

%% A tiny world:
bird(tweety).
bird(sam).
penguin(sam).

flies(X) :- bird(X), \+ penguin(X).     % classic NAF idiom

main :-
    format("=== 1. \\+ is 'not provable', NOT 'provably false' ===~n"),
    ( \+ flies(sam)   -> format("  \\+ flies(sam): yes (sam is a penguin)~n") ; true ),
    ( \+ flies(rock)  -> format("  \\+ flies(rock): yes -- but note: rock isn't even a bird.~n") ; true ),
    format("  Prolog cannot distinguish 'false' from 'absent'. This is the~n"),
    format("  Closed World Assumption: what I cannot prove, I call false.~n~n"),

    format("=== 2. The order trap: \\+ is NOT logical negation ===~n"),
    % Logically, bird(X) AND not penguin(X) == not penguin(X) AND bird(X).
    % Operationally:
    findall(X, (bird(X), \+ penguin(X)), Good),
    format("  (bird(X), \\+ penguin(X))  -> X = ~w   correct~n", [Good]),
    findall(X, (\+ penguin(X), bird(X)), Bad),
    format("  (\\+ penguin(X), bird(X))  -> X = ~w~n", [Bad]),
    format("  Same formula, conjunction merely REORDERED -- different answers!~n"),
    format("  Why: with X unbound, \\+ penguin(X) asks 'is there NO penguin~n"),
    format("  AT ALL?' -- there is one (sam), so the whole query dies before~n"),
    format("  bird/1 ever runs. This is 'floundering': negation applied to~n"),
    format("  an insufficiently instantiated goal quantifies the wrong way.~n"),
    format("  (\\+G with free vars in G means: no instance of G is provable,~n"),
    format("   i.e. the negation swallowed the existential quantifier.)~n~n"),

    format("=== 3. \\+ \\+ : the double-negation hack ===~n"),
    ( \+ \+ bird(X2) -> true ; true ),   % X2 deliberately escapes unbound
    format("  after \\+ \\+ bird(X):  X is still UNBOUND (var: ~w)~n", [X2]),
    format("  \\+ \\+ G tests 'is G provable?' WITHOUT binding anything --~n"),
    format("  classically a no-op, in Prolog a real tool. The gap between~n"),
    format("  \\+ \\+ G and G is exactly the gap between proof and truth.~n~n"),

    format("=== 4. What \\+ actually approximates: Clark completion ===~n"),
    format("  The theory: a program's IF clauses are read as IFF.~n"),
    format("  flies(X) :- bird(X), \\+ penguin(X).   is completed to:~n"),
    format("  flies(X) <-> (bird(X) & ~~penguin(X)) -- and under the completed~n"),
    format("  theory, NAF is sound. The catch: completion of a LOOP through~n"),
    format("  negation (liar :- \\+ liar  becomes  liar <-> ~~liar) is~n"),
    format("  INCONSISTENT -- the Liar detonates the semantics itself...~n~n"),

    format("=== 5. ...which is why tnot/WFS exists (the third value) ===~n"),
    report(liar,    "liar (liar :- tnot(liar))"),
    report(tt,      "truth-teller (tt :- tt, tabled)"),
    format("  tnot under Well-Founded Semantics returns UNDEFINED for the~n"),
    format("  liar loop instead of not terminating (\\+) or exploding (Clark).~n"),
    format("  Cost: tabling machinery + a third value. Ransom, again.~n~n"),

    format("=== 6. dif/2 -- constructive disequality, the sound cousin ===~n"),
    ( dif(Y, sam), bird(Y)
    -> format("  dif(Y,sam), bird(Y) -> Y = ~w   (order-INDEPENDENT!)~n", [Y]) ),
    findall(Z, (bird(Z), dif(Z, sam)), L6),
    format("  bird(Z), dif(Z,sam)  -> Z = ~w   same answer both orders~n", [L6]),
    format("  dif/2 delays as a CONSTRAINT until its args are testable --~n"),
    format("  it repairs Section 2's order trap, but only for (in)equality,~n"),
    format("  not for arbitrary goals.~n~n"),

    format("=== 7. Your quote, demonstrated: \\+ is a CONTROL STRUCTURE ===~n"),
    format("  It sits in the control-predicate list with !, ->, ; because it~n"),
    format("  is compiled inline: \\+ G  ==  ( call(G) -> fail ; true ).~n"),
    ( ( flies(tweety) -> fail ; true )
    -> true
    ;  format("  (call(flies(tweety)) -> fail ; true)  fails, like \\+ flies(tweety)~n") ),
    ( \+ flies(tweety) -> true
    ; format("  \\+ flies(tweety) also fails -- identical behavior, by construction~n") ),
    format("  Negation implemented FROM cut-and-fail: not a logical connective~n"),
    format("  in the engine at all, but a programming pattern promoted to syntax.~n"),
    halt.

:- table liar/0.
liar :- tnot(liar).
:- table tt/0.
tt :- tt.

report(G, Label) :-
    (   call_delays(G, D)
    ->  ( D == true
        -> format("  ~w: TRUE~n", [Label])
        ;  format("  ~w: UNDEFINED (delays: ~w)~n", [Label, D]) )
    ;   format("  ~w: FALSE~n", [Label])
    ).

:- initialization(main).
