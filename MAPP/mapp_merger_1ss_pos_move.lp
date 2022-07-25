% basic movement rules
direction((X,Y)) :- X=-1..1, Y=-1..1, |X+Y|=1.
move_(R,(X,Y),T) :- pos(R,(X1,Y1),ps(PS),ss(SS-1)), pos(R,(X2,Y2),ps(PS),ss(SS)),SS>0,
				direction((X,Y)), X1+X=X2, Y1+Y=Y2, NN = #count{N,PS-1 : total_num_steps(N,PS-1)}, T=NN+SS.


#show.
#show occurs(object(robot,R), action(move,D),     T) :    move_(R,D,T).




