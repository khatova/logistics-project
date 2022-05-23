direction((X,Y)) :- X=-1..1, Y=-1..1, |X+Y|=1.
nextto((X,Y),(X',Y'),(X+X',Y+Y')) :- position((X,Y)), direction((X',Y')), position((X+X',Y+Y')).


%:- move_(R,D,T), move_(R,D',T), D<D'. %What is that suppose to mean?

% don't leave the grid
% avoid conflicts while avoiding conflicts