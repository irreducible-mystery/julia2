% Witness for V4: SWI-Prolog's Well-Founded Semantics verdict on the
% truth-teller ("this sentence is true") vs the liar.
:- table tt/0.
tt :- tt.
:- table liar/0.
liar :- tnot(liar).
main :-
    ( call_delays(tt, D1) -> format("truth-teller: ~w (delays: ~w)~n", [true, D1])
    ; format("truth-teller: false~n") ),
    ( call_delays(liar, D2) -> format("liar: ~w (delays: ~w)~n", [true, D2])
    ; format("liar: false~n") ),
    halt.
:- initialization(main).
