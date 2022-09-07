%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% = Command-line Arguments =================================
% -x 6 -y 6 -r 10 -I --instance-dir
%
% = Instance Statistics ====================================
% Grid Size X:                      6
% Grid Size Y:                      6
% Number of Nodes:                  36
% Number of Highway Nodes:          0
% Number of Robots:                 10
% Number of Shelves:                0
% Number of Picking Stations:       0
% Number of Products:               0
% Number of Product Units in Total: 0
% Number of Orders:                 0
% Number of Orders Lines:           0
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

#program base.

% init
init(object(node,1),value(at,(1,1))).
init(object(node,2),value(at,(2,1))).
init(object(node,3),value(at,(3,1))).
init(object(node,4),value(at,(4,1))).
init(object(node,5),value(at,(5,1))).
init(object(node,6),value(at,(6,1))).
init(object(node,7),value(at,(1,2))).
init(object(node,8),value(at,(2,2))).
init(object(node,10),value(at,(4,2))).
init(object(node,11),value(at,(5,2))).
init(object(node,14),value(at,(2,3))).
init(object(node,16),value(at,(4,3))).
init(object(node,17),value(at,(5,3))).
init(object(node,18),value(at,(6,3))).
init(object(node,19),value(at,(1,4))).
init(object(node,21),value(at,(3,4))).
init(object(node,22),value(at,(4,4))).
init(object(node,23),value(at,(5,4))).
init(object(node,24),value(at,(6,4))).
init(object(node,25),value(at,(1,5))).
init(object(node,26),value(at,(2,5))).
init(object(node,27),value(at,(3,5))).
init(object(node,28),value(at,(4,5))).
init(object(node,29),value(at,(5,5))).
init(object(node,30),value(at,(6,5))).
init(object(node,31),value(at,(1,6))).
init(object(node,32),value(at,(2,6))).
init(object(node,33),value(at,(3,6))).
init(object(node,34),value(at,(4,6))).
init(object(node,36),value(at,(6,6))).
init(object(robot,1),value(at,(3,6))).
init(object(robot,2),value(at,(5,4))).
init(object(robot,3),value(at,(6,3))).
init(object(robot,4),value(at,(1,1))).
init(object(robot,5),value(at,(1,4))).
init(object(robot,6),value(at,(4,1))).
init(object(robot,7),value(at,(4,6))).
init(object(robot,8),value(at,(6,5))).
init(object(robot,9),value(at,(3,5))).
init(object(robot,10),value(at,(4,5))).
init(object(destination,1),value(at,(6,4))).
init(object(destination,2),value(at,(3,6))).
init(object(destination,3),value(at,(6,1))).
init(object(destination,4),value(at,(6,3))).
init(object(destination,5),value(at,(3,4))).
init(object(destination,6),value(at,(1,2))).
init(object(destination,7),value(at,(1,5))).
init(object(destination,8),value(at,(2,3))).
init(object(destination,9),value(at,(1,6))).
init(object(destination,10),value(at,(5,5))).
init(object(shelf,1),value(at,(6,4))).
init(object(shelf,2),value(at,(3,6))).
init(object(shelf,3),value(at,(6,1))).
init(object(shelf,4),value(at,(6,3))).
init(object(shelf,5),value(at,(3,4))).
init(object(shelf,6),value(at,(1,2))).
init(object(shelf,7),value(at,(1,5))).
init(object(shelf,8),value(at,(2,3))).
init(object(shelf,9),value(at,(1,6))).
init(object(shelf,10),value(at,(5,5))).