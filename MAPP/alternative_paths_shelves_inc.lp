%#include "../asprilo-encodings/input.lp".

robot(R)                     :- init(object(robot,R),          _).
shelf(S)                     :- init(object(shelf,S),          _).
station(P)                   :- init(object(pickingStation,P), _).
product(A)                   :- init(object(product,A),        _).

    isRobot(robot(R)) :- robot(R).
    isShelf(shelf(S)) :- shelf(S).
isStation(station(T)) :- station(T).
isProduct(product(A)) :- product(A).
    isOrder(order(O)) :- order(O).

  order(      O            ) :- init(object(order,O),          _).
ordered(order(O),product(A)) :- init(object(order,O),          value(line,(A,_))).      % IGNORING QUANTITIES
 target(order(O),station(P)) :- init(object(order,O),          value(pickingStation,P)).

shelved(shelf(S),product(A)) :- init(object(product,A),        value(on,(S,_))).        % IGNORING QUANTITIES

position(           (X,Y))   :- init(object(node,_),           value(at,(X,Y))).

position(station(P),(X,Y))   :- init(object(pickingStation,P), value(at,(X,Y))).

position(  robot(R),(X,Y),0) :- init(object(robot,R),          value(at,(X,Y))).
position(  shelf(S),(X,Y),0) :- init(object(shelf,S),          value(at,(X,Y))).

highway(            C    )   :- init(object(highway,_),        value(at,C)).



maxsteps(4).

direction((X,Y)) :- X=-1..1, Y=-1..1, |X+Y|=1.
nextto((X,Y),(X',Y'),(X+X',Y+Y')) :- position((X,Y)), direction((X',Y')), position((X+X',Y+Y')).
nextto(C1,C2) :- nextto(C1,_,C2).

% triplet is three connected cells
triplet(C1,C2,C3) :- nextto(C1,C2), nextto(C2,C3), C1 != C3, new(C1),
					not position(shelf(_),C1,0), not position(shelf(_),C2,0).
triplet(C1,C2,C3) :- nextto(C1,C2), nextto(C2,C3), C1 != C3, new(C2),
					not position(shelf(_),C1,0), not position(shelf(_),C2,0).
triplet(C1,C2,C3) :- nextto(C1,C2), nextto(C2,C3), C1 != C3, new(C3),
					not position(shelf(_),C1,0), not position(shelf(_),C2,0).
triplet(C1,C2,C3) :- nextto(C1,C2), nextto(C2,C3), not alt(C1,C2,C3,_,_),
					not position(shelf(_),C1,0), not position(shelf(_),C2,0).

alt_step(0..S) :- maxsteps(S).
at(C1,C2,C3,C1,0) :- triplet(C1,C2,C3).

1 {at(C1,C2,C3,C,S) : alt_step(S)} 1 :- at(C1,C2,C3,C',S-1), nextto(C',C), C!=C1, C!=C2, C'!=C3, S>0,
				#false : at(C1,C2,C3,C'',S), C''!=C.%; not unfinished(C1,C2,C3).

:- at(C1,C2,C3,C,S), position(shelf(_),C,0), C!=C3.
%:- triplet(C1,C2,C3), not at(C1,C2,C3,C3,_).

paths_length(S) :- at(_,_,_,_,S).
%num_unfinished(N) :- N == #count{C1,C2,C3 : unfinished(C1,C2,C3)}.

%alt(C1,C2,C3,C,S) :- at(C1,C2,C3,C,S).

%#minimize { N@1 : num_unfinished(N) }.
#minimize { S : paths_length(S) }.

#show.
#show at/5.
#show alt/5.
#show triplet/3.
#show unfinished/3.