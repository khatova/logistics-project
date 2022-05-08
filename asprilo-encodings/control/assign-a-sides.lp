#include "../input.lp".

% Aux predicates to represent products that are ordered and shelved, resp.
ordered(order(O),product(A),N) :- init(object(order,O),   value(line,(A,N))).
shelved(shelf(S),product(A),N) :- init(object(product,A), value(on,  (S,N))).

% Guess assignments
{ assign(R,S,P) } :- isRobot(R), isShelf(S), isStation(P).

% For each station and product, the assignment must allow for the fulfillment of the sum of
% requested quantities by all orders
orderedAtStation(A, M, P) :- isProduct(A), isStation(P), M = #sum { N, O : ordered(O,A,N), target(O,P) }.
:- orderedAtStation(A, M, P), #sum { N,S : assign(_,S,P), shelved(S,A,N) } < M.

% Do not assign more than one robot per shelf
:- isShelf(S), #count{ R : assign(R,S,_) } > 1.                 % Too strong?? :- assign(R,S,P), %assign(R',S,P), R<R'.

% Determine left/right x-coordinates
side(X, left) :- SX = #max{ X' : position((X',_)) },  X<=(SX+1)/2, position((X,_)).
side(X, right) :- SX = #max{ X' : position((X',_)) }, X> (SX+1)/2, position((X,_)).

% Group robots, shelve and picking stations into left & right wrt their initial x-coordinates
objside(robot, R, left) :- robot(R), position(R,(X,_),0), side(X,left).
objside(robot, R, right) :- robot(R), position(R,(X,_),0), side(X,right).

objside(shelf, S, left) :- shelf(S), position(S,(X,_),0), side(X,left).
objside(shelf, S, right) :- shelf(S), position(S,(X,_),0), side(X,right).

objside(station, P, left) :- station(P), position(P,(X,_),0), side(X,left).
objside(station, P, right) :- station(P), position(P,(X,_),0), side(X,right).


% Restrict movement of left/rigth robots to the respective half of the grid
sameside(R,S,P) :- objside(robot, R, right), objside(shelf, S, right), objside(station, P, right).
sameside(R,S,P) :- objside(robot, R, left), objside(shelf, S, left), objside(station, P, left).

:- assign(R,S,P), not objside(robot, R, right).

%:- objside(robot, R, left), position(R,(X,_),T), time(T), side(X,right).
%:- objside(robot, R, right), position(R,(X,_),T), time(T), side(X,left).



% Use all robots
:- isRobot(R), not assign(R,_,_).

#show assign/3.
#show init/2.


