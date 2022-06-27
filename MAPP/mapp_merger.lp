% #include "../asprilo-encodings/input.lp".

% we need to transform between input times, progression steps with their substeps(PS), and output times.
progrstep(0..2).
substep(0..7). % what max amount of substeps will be there?

% length of alt paths
maxsteps(5).
alt_step(1..S) :- maxsteps(S).

% basic movement rules
direction((X,Y)) :- X=-1..1, Y=-1..1, |X+Y|=1.
nextto((X,Y),(X',Y'),(X+X',Y+Y')) :- position((X,Y)), direction((X',Y')), position((X+X',Y+Y')).
nextto(C1,C2) :- nextto(C1,_,C2).

% initial positions:
new_position(R,C,ps(0),ss(0)) :- position(C), position(robot(R),C,0).
% This was the first step of initial plans:
initial_step(R,0,ps(0),ss(0)) :- robot(R).

% priority of a robot equals to its ordering number (maybe we can use a better heuristic later).
priority(R,R) :- robot(R).
r1_higherthan_r2(R1,R2) :- priority(R1,P1), priority(R2,P2), P1>P2. % TODO: ordering?

% master unit = robot with the highest priority, which is not solved yet.
% (I'm still not sure if we really need it defined for the algorithm to work. The important thing is that
% in the paper it's proven that for the master robot you always can do bring_blank, so the algorithm always works)
% master(R, PS) :- robot(R), not solved(R, PS), priority(R,P), priority(R',P'), progrstep(PS),
%				#max{P' : priority(R',P')}, P' < P.

% private zone = all cels visited by a robot at one progression step.
% maybe wrong! only visited before current substep?
private_zone(R,ps(PS),ss(SS),C) :- progrstep(PS), substep(SS), new_position(R,C,ps(PS),ss(SS')), SS'<=SS.  

% A. WAIT if the robot was pushed from its initial path during the current progression step
pushed(R,ps(PS),ss(SS)) :- push(R, _, _, ps(PS), ss(SS')), substep(SS), substep(SS'), SS'<SS.
wait(R,ps(PS),ss(SS)) :- pushed(R,ps(PS),ss(SS)), #false : progr_done(ps(PS),ss(SS')), SS'<SS.

% B. WAIT if next step belongs to the private zone of a robot with higher priority
wait(R,ps(PS),ss(SS)) :- position(robot(R),C,T+1), initial_step(R,T,ps(PS),ss(SS-1)),
				private_zone(R',ps(PS),ss(SS),C), r1_higherthan_r2(R',R),
				#false : progr_done(ps(PS),ss(SS')), SS'<SS; not push(R,_,_,ps(PS),ss(SS)).
%wait(R,ps(PS),ss(SS)) :- wait_p(R,ps(PS),ss(SS)), not push(R,_,_,ps(PS),ss(SS)).

% -> transform wait() into new_position() (needed for bring blank algorithm)
new_position(R,C,ps(PS),ss(SS)) :- new_position(R,C,ps(PS),ss(SS-1)), wait(R,ps(PS),ss(SS)).

% we're staying on the same time_(T) of an initial plan if we wait at the current substep
initial_step(R,T,ps(PS),ss(SS)) :- time_(T), initial_step(R,T,ps(PS),ss(SS-1)), wait(R,ps(PS),ss(SS)).

% C. MOVE to next step if there is blank
% next cell on initial path is blank if it doesn't belong to a private zone of a robot with higher priority
next_blank(R,C,ps(PS),ss(SS)) :- progrstep(PS), substep(SS), initial_step(R,T-1,ps(PS),ss(SS-1)), position(robot(R),C,T), robot(R'),
				not new_position(R',C,ps(PS),ss(SS-1)), R' != R,
				#false : private_zone(R'',ps(PS),ss(SS),C), r1_higherthan_r2(R'',R).
% in previous line "not new_position()"" maybe is redundant
movement(R,C,ps(PS),ss(SS)) :- next_blank(R,C,ps(PS),ss(SS)), not wait(R,ps(PS),ss(SS)).
new_position(R,C,ps(PS),ss(SS)) :- movement(R,C,ps(PS),ss(SS)).
prev_position(R,C,C') :- movement(R,C,ps(PS),ss(SS)), new_position(R,C',ps(PS),ss(SS-1)).

% go to next initial step if movement() done.
initial_step(R,T,ps(PS),ss(SS)) :- time_(T), initial_step(R,T-1,ps(PS),ss(SS-1)), movement(R,_,ps(PS),ss(SS)).
% TODO: move only if goal not achieved yet (maybe it already works?)

% D. BRING BLANK
pushed_before(R,ps(PS),ss(SS)) :- push(R,_,_,ps(PS),ss(SS')), substep(SS), substep(SS'), SS'<SS.
need_blank(R,C,ps(PS),ss(SS)) :- progrstep(PS), substep(SS), initial_step(R,T,ps(PS),ss(SS-1)), position(robot(R),C,T+1),
				not wait(R,ps(PS),ss(SS)), 
				not next_blank(R,C,ps(PS),ss(SS)), not movement(R,_,ps(PS),ss(SS)), not pushed_before(R,ps(PS),ss(SS)).
% Blank here is defined as non-occupied cell on the alt path from the position at the previous time step t-1 
% to the position at the next step t+1, which doesn't belong to a private zone of any robot with higher priority

% 1) Check if such position exists (it ALWAYS exists for the robot with the highest priority, and it may exist
% for some oter robots too)

% alt_blank() fires if there's a blank on the alt path if we consider robot R tring to do his step from C2 to C3, 
% with its previous osition being C1.
private_of_higher(R,C,ps(PS),ss(SS)) :- need_blank(R,_,ps(PS),ss(SS+1)), private_zone(R',ps(PS),ss(SS),C), r1_higherthan_r2(R',R).
position_of_any(C,ps(PS),ss(SS)) :- new_position(R',C,ps(PS),ss(SS)), robot(R').
position_of_higher(R,C,ps(PS),ss(SS)) :- need_blank(R,_,ps(PS),ss(SS+1)), new_position(R',C,ps(PS),ss(SS)), r1_higherthan_r2(R',R).
alt_blank(R,C_is_blank,C1,C2,C3,ps(PS),ss(SS),AS) :- new_position(R,C2,ps(PS),ss(SS-1)), prev_position(R,C2,C1), need_blank(R,C3,ps(PS),ss(SS)), 
				alt(C1,C2,C3,C_is_blank,AS), not position_of_any(C_is_blank,ps(PS),ss(SS-1)), not private_of_higher(R,C_is_blank,ps(PS),ss(SS-1)).

shorter_alt_blank(R,C_is_blank,C1,C2,C3,ps(PS),ss(SS),AS) :- alt_blank(R,C_is_blank,C1,C2,C3,ps(PS),ss(SS),AS), 
				alt_blank(R,C',C1,C2,C3,ps(PS),ss(SS),AS'), AS'>AS.
cant_push(R,C_is_blank,C1,C2,C3,ps(PS),ss(SS)) :- alt(C1,C2,C3,C_is_blank,AS), alt(C1,C2,C3,C',AS'), AS'>AS, 
				position_of_higher(R,C',ps(PS),ss(SS-1)).
can_bring_blank(R,C_is_blank,C1,C2,C3,ps(PS),ss(SS)) :- alt_blank(R,C_is_blank,C1,C2,C3,ps(PS),ss(SS),AS), 
				not cant_push(R,C_is_blank,C1,C2,C3,ps(PS),ss(SS)), not shorter_alt_blank(R,C_is_blank,C1,C2,C3,ps(PS),ss(SS),AS). 
%				alt(C1,C2,C3,C_is_blank,AS), alt(C1,C2,C3,C',AS'), AS'>AS. 

% robots need to be pushed along the alt path from the cells positioned between blank and our next step.
% robot(R) here is the robot which needs blank on his next step, not a robot that we need to push!
% push_from_cell() fires for cells C from which robots need to be pushed along the alt path for a triplet(C1,C2,C_need_blank)
push_from_cell(R,R',C,C1,C2,C_need_blank,ps(PS),ss(SS)) :- can_bring_blank(R,C_is_blank,C1,C2,C_need_blank,ps(PS),ss(SS)),
				alt(C1,C2,C_need_blank,C_is_blank,AS), alt(C1,C2,C_need_blank,C,AS'), AS'>AS, new_position(R',C,ps(PS),ss(SS-1)).

% 2) push robots with lower priority back along the alt path (this brings blank to the first cell of the triplet)
% - need to transform pushes and waits into new_positions because it can be its new_position() if it was already pushed 
%   or position() if it waited.
push(R',C_from,C_to,ps(PS),ss(SS)) :- push_from_cell(R,R',C_from,C1,C2,C_need_blank,ps(PS),ss(SS)), alt(C1,C2,C_need_blank,C_from,AS),  
					alt(C1,C2,C_need_blank,C_to,AS-1).

% 3) finally, we brought blank and can move now
brought_blank(R,C,ps(PS),ss(SS)) :- push_from_cell(R,_,C',_,_,C,ps(PS),ss(SS)), push(R',C',_,ps(PS),ss(SS)).
new_position(R,C,ps(PS),ss(SS)) :- brought_blank(R,C,ps(PS),ss(SS)).
initial_step(R,T,ps(PS),ss(SS)) :- time_(T), initial_step(R,T-1,ps(PS),ss(SS-1)), brought_blank(R,_,ps(PS),ss(SS)).

% translate push into new_position()
new_position(R,C,ps(PS),ss(SS)) :- push(R,_,C,ps(PS),ss(SS)).
prev_position(R,C,C') :- new_position(R,C,ps(PS),ss(SS)), push(R,C',C,ps(PS),ss(SS)).

% we're staying on the same step of the initial plan if we were pushed
initial_step(R,T,ps(PS),ss(SS)) :- time_(T), initial_step(R,T,ps(PS),ss(SS-1)), push(R,_,_,ps(PS),ss(SS)).


% finish progression step if no robots can move
progr_done(ps(PS),ss(SS)) :- progrstep(PS), substep(SS), not movement(_,_,ps(PS),ss(SS)), not push(_,_,_,ps(PS),ss(SS)), SS != 0,
				#false : progr_done(ps(PS),ss(SS')), SS' < SS.

% E. REPOSITIONING 
% if no moves possible for the current substep of the current progression step, then we need to revert all pushes.
push_back(R,C_from,C_to,ps(PS),ss(SS)) :- push(R,C_to,C_from,ps(PS),ss(SS')),
				progr_done(ps(PS),ss(PD)), SS = PD + (PD - SS' - 1).

% translate push_back into re_position()
re_position(R,C,ps(PS),ss(SS)) :- push_back(R,_,C,ps(PS),ss(SS)).
prev_position(R,C,C') :- re_position(R,C,ps(PS),ss(SS)), push_back(R,C',C,ps(PS),ss(SS)).

% we're staying on the same step of the initial plan if we were pushed back
initial_step(R,T,ps(PS),ss(SS)) :- time_(T), initial_step(R,T,ps(PS),ss(SS-1)), push_back(R,_,_,ps(PS),ss(SS)).

repositioning_done(ps(PS),ss(SS-1)) :- progrstep(PS), substep(SS), not new_position(_,_,ps(PS),ss(SS)),
				not re_position(_,_,ps(PS),ss(SS)).

% translate waits, new_positions and pushes into move_
move_(R,(0,0),T) :- wait(R,_,ss(T)).
move_(R,(X,Y),T) :- new_position(R,(X1,Y1),_,ss(T-1)), new_position(R,(X2,Y2),_,ss(T)), direction((X,Y)), X1+X=X2, Y1+Y=Y2. 
move_(R,(X,Y),T) :- new_position(R,(X1,Y1),_,ss(T-1)), re_position(R,(X2,Y2),_,ss(T)), direction((X,Y)), X1+X=X2, Y1+Y=Y2. 
move_(R,(X,Y),T) :- re_position(R,(X1,Y1),_,ss(T-1)), re_position(R,(X2,Y2),_,ss(T)), direction((X,Y)), X1+X=X2, Y1+Y=Y2.

#show.
%#show progrstep/1.
%#show substep/1.
#show new_position/4.
#show position/3.
%#show private_zone/4.
#show r1_higherthan_r2/2.
#show next_blank/4.
#show need_blank/4.
#show alt_blank/8.
#show initial_step/4.
#show movement/4.
#show push_from_cell/8.
#show push/5.
#show push_back/5.
#show brought_blank/4.
#show wait/3.
%#show wait_p/3.
#show can_bring_blank/7.
%#show position_of_higher/4.
%#show cant_push/7.
#show progr_done/2.
#show re_position/4.

#show occurs(object(robot,R), action(move,D),     T) :    move_(R,D,T).


