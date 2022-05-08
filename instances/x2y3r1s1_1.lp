%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Grid size X: 2
%Grid size Y: 3
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
#program base.

%init
init(object(node, 1), value(at, (1, 1))).
init(object(node, 2), value(at, (2, 1))).
init(object(node, 4), value(at, (2, 2))).
init(object(node, 6), value(at, (2, 3))).
init(object(node, 3), value(at, (1, 2))).
init(object(node, 5), value(at, (1, 3))).
init(object(shelf,2), value(at,(2,1))).
init(object(robot,1), value(at,(1,3))).
init(object(robot,1), value(max_energy,0)).
init(object(robot,1), value(energy,0)).
init(object(pickingStation,2), value(at,(2,1))).
