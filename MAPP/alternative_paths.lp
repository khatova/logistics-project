#include "../asprilo-encodings/input.lp".
% for a warehouse, max length of alternative path is 5.
maxsteps(5).

direction((X,Y)) :- X=-1..1, Y=-1..1, |X+Y|=1.
nextto((X,Y),(X',Y'),(X+X',Y+Y')) :- position((X,Y)), direction((X',Y')), position((X+X',Y+Y')).
nextto(C1,C2) :- nextto(C1,_,C2).

% triplet is three connected cells
triplet(C1,C2,C3) :- nextto(C1,C2), nextto(C2,C3), C1 != C3.
					%not position(shelf(_),C1,0), not position(shelf(_),C2,0).

alt_step(0..S) :- maxsteps(S).
at(C1,C2,C3,C1,0) :- triplet(C1,C2,C3).

1 {at(C1,C2,C3,C,S) : alt_step(S)} 1 :- at(C1,C2,C3,C',S-1), nextto(C',C), C!=C1, C!=C2, C'!=C3, S>0,
				#false : at(C1,C2,C3,C'',S), C''!=C.
%1 {at(C1,C2,C3,C,S) : alt_step(S)} 1 :- at(C1,C2,C3,C',S-1), nextto(C',C), C!=C1, C!=C2, C'!=C3.
				%#false : at(C1,C2,C3,C'',S), C''!=C.


%{at(C1,C2,C3,C,S)} :- at(C1,C2,C3,C',S-1), nextto(C',C), alt_step(S), alt_step(S'),
%					 C!=C1, C!=C2, C'!=C3, %not position(shelf(_),C,0),
%					 #false : at(C1,C2,C3,C'',S), C''!=C;
%					 #false : at(C1,C2,C3,C,S'), S'<S.%, at(C1,C2,C3,C,S'), S!=S', C!=C1, C!=C2.
% for the 1st step of alt path
%{at(C1,C2,C3,C,S)} :- at(C1,C2,C3,C',S-1), nextto(C',C), alt_step(S),
%					 C!=C1, C!=C2, C'!=C3, %not position(shelf(_),C,0),
%					 #false : at(C1,C2,C3,C,S'), S'=0;
%					 #false : at(C1,C2,C3,C'',S), C''!=C.%, at(C1,C2,C3,C,S'), S!=S', C!=C1, C!=C2.

%:- at(C1,C2,C3,C,_), position(shelf(_),C,0), C!=C3.
% alt path must end at the last cell of the triplet
%:- at(C1,C2,C3,C,S), at(C1,C2,C3,C,S'), S'!=S.
%:- triplet(C1,C2,C3), not at(C1,C2,C3,C3,_).
%:- at(C1,C2,C3,C,S), at(C1,C2,C3,C'',S), C''!=C
paths_length(S) :- at(_,_,_,_,S).

alt(C1,C2,C3,C,S) :- at(C1,C2,C3,C,S).

#minimize { S : paths_length(S) }.

#show.
#show alt/5.