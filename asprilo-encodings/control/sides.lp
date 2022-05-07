#include "../input.lp".

% Determine left/right x-coordinates
side(X, left) :- SX = #max{ X' : position((X',_)) },  X<=(SX+1)/2, position((X,_)).
side(X, right) :- SX = #max{ X' : position((X',_)) }, X> (SX+1)/2, position((X,_)).

% Group robots into left/rigth side wrt their initial position
roboside(R, left) :- position(R,(X,_),0), side(X,left).
roboside(R, right) :- position(R,(X,_),0), side(X,right).

% Forbid robots to occupy a position on the other side
:- roboside(R, left), position(R,(X,_),T), time(T), side(X,right).
:- roboside(R, right), position(R,(X,_),T), time(T), side(X,left).