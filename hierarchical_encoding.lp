% --------------------------------------------------------------------------------
% REPRESENTATION

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

position(  robot(R),(X,Y),lasttime) :- init(object(robot,R),          value(at,(X,Y))).
position(  shelf(S),(X,Y),0) :- init(object(shelf,S),          value(at,(X,Y))).

highway(            C    )   :- init(object(highway,_),        value(at,C)).
%#const horizon=1.
time(lasttime+1..horizon).

direction((0,0)).
direction((X,Y)) :- X=-1..1, Y=-1..1, |X+Y|=1.
nextto((X,Y),(X',Y'),(X+X',Y+Y')) :- position((X,Y)), direction((X',Y')), position((X+X',Y+Y')).

{ move(R,D,T) : direction(D) } 1 :- isRobot(R), time(T).

% - move/3 ----------------------------------------------------------------------
position(R,C,T) :- move(R,D,T), position(R,C',T-1),     nextto(C',D,C).
                :- move(R,D,T), position(R,C ,T-1), not nextto(C ,D,_).

% - inertia ---------------------------------------------------------------------
%position(R,C,T) :- position(R,C,T-1), not move(R,_,T), isRobot(R), time(T).

% - edge collision --------------------------------------------------------------
moveto(C',C,T) :- nextto(C',D,C), position(R,C',T-1), move(R,D,T).
 :- moveto(C',C,T), moveto(C,C',T), C < C'.

% - vertex collision ------------------------------------------------------------
 %:- { position(R,C,T) : isRobot(R) }  > 1, position(C), time(T).

% - auxiliaries -----------------------------------------------------------------
 :- { position(R,C,T) } != 1, isRobot(R), time(T).    % REDUNDANT but PERFORMANT?

% - illegal collision ------------------------------------------------------------
 is_illegal(R,C,T) :- position(R,C,T), illegal(_,C,T), isRobot(R), time(T).
 :- is_illegal(R,C,T).
 is_illegal_from(R,C,V,T) :- position(R,C,T), illegal_from(_,V,C,T), position(R,V,T-1), isRobot(R).
 :- is_illegal_from(R,C,V,T).

 new_illegal_from(R,(X',Y'),(X,Y),T) :- position(robot(R),(X',Y'),T), position(robot(R),(X,Y),T-1).

processed(A,R,T) :- ordered(O,A), shelved(S,A), isRobot(R), position(S,C,0),
                  position(R,C,T).

 :- processed(A,R,T), move(R,_,T'), T' > T.
 :- processed(A,R,T), not move(R,_,T'), T' < T, time(T), time(T').

processed(A)   :- processed(A,R,T).

:- ordered(O,A), not processed(A).

%output
#show.
%#show init/2.
#show position/3.
%#show new_position/3.
#show is_illegal/3.
#show is_illegal_from/4.
#show new_illegal_from/4.
%#show cost/1.
%#show move/3.
#show occurs(object(robot,R), action(move,D),     T) :    move(robot(R),D,T).
