% conflict_direction(R,D,T) :- conflict(R,T), move(R,D,T).

% if conflict ahead then maybe dash in any direction except the direction of the conflict
% {dash(R,D,T)} :- conflict(R,T+N), direction(D), not move(R,D,T), N=1..M, M=#max{T' : occurs(_,_,T')}, time(T), time_(T').
{dash(R,D,T+1)} :- conflict(R,T), direction(D), not move(R,D,T+1), time(T).

% maybe wait until no conflict anymore. try different waiting times.
{wait(R,TW,T)} :- conflict(R,T), TW=1..horizon-T.

% if dashed, then need to return back to the plan later
dash_back(R,-D,T+TW) :- dash(R,D,T), wait(R,TW,T).
dash_back(R,-D,T+1) :- dash(R,D,T), not wait(R,_,T).

% copy unchanged moves
% number of dashes for robot R before time step T
num_dashes(R,0,0) :- robot(R).
num_dashes(R,T,DN+1) :- num_dashes(R,T-1,DN), dash(R,_,T), time(T).
num_dashes(R,T,DN) :- num_dashes(R,T-1,DN), not dash(R,_,T), time(T).
%num_dashes(R,T,DN) :- DN = #count{T' : dash(R,_,T'), T' < T}, robot(R), time_(T), time_(T').
% wait time for robot R before time step T
wait_time(R,0,0) :- robot(R).
wait_time(R,T,TW+TW') :- wait_time(R,T-1,TW), wait(R,T,TW'), time(T).
wait_time(R,T,TW) :- wait_time(R,T-1,TW), not wait(R,T,_), time(T).
%wait_time(R,T,W) :- W = #sum{TW : wait(R,TW,T'), T' < T}, robot(R), time_(T), time_(T').
% if no conflict at the previous step, then copy the current step (with adjusted time step T_)
% each dash causes +2 steps
% each wait(_,TW,_) causes +TW steps
move_(R,D,T_) :- move(R,D,T), T_ = T + DN * 2 + W, num_dashes(R,T,DN), wait_time(R,T,W), not conflict(R,T-1), time(T), robot(R).


% translate dashes and waits into moves
move_(R,D,T) :- dash(R,D,T).
move_(R,D,T) :- dash_back(R,D,T).
move_(R,(0,0),T+T') :- wait(R,TW,T), T'=1..TW.


%#minimize { T : move_(_,_,T) }.