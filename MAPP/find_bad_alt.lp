robot(R)                     :- init(object(robot,R),          _).
shelf(S)                     :- init(object(shelf,S),          _).

    isRobot(robot(R)) :- robot(R).
    isShelf(shelf(S)) :- shelf(S).

position(           (X,Y))   :- init(object(node,_),           value(at,(X,Y))).

position(  robot(R),(X,Y),0) :- init(object(robot,R),          value(at,(X,Y))).
position(  shelf(S),(X,Y),0) :- init(object(shelf,S),          value(at,(X,Y))).

used_triplet(C1,C2,C3) :- position(robot(R),C1,T), position(robot(R),C2,T+1), position(robot(R),C3,T+2).

bad_alt(C1,C2,C3,C,S) :- used_triplet(C1,C2,C3), alt(C1,C2,C3,C,S), not position(C1).
bad_alt(C1,C2,C3,C,S) :- used_triplet(C1,C2,C3), alt(C1,C2,C3,C,S), not position(C2).
bad_alt(C1,C2,C3,C,S) :- used_triplet(C1,C2,C3), alt(C1,C2,C3,C,S), not position(C3).
bad_alt(C1,C2,C3,C,S) :- used_triplet(C1,C2,C3), alt(C1,C2,C3,C,S), not position(C).
bad_alt(C1,C2,C3,C,S) :- used_triplet(C1,C2,C3), alt(C1,C2,C3,C,S), position(shelf(_),C,0).

rebuild_alt(C1,C2,C3) :- used_triplet(C1,C2,C3), bad_alt(C1,C2,C3,_,_).
ok_alt(C1,C2,C3,C,S) :- alt(C1,C2,C3,C,S), not rebuild_alt(C1,C2,C3).

#show.
#show rebuild_alt/3.
#show ok_alt/5.