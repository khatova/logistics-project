init(object(robot,2),value(max_energy,0)).
init(object(robot,2),value(energy,0)).
init(object(order,2),value(pickingStation,2)).
init(object(robot,1),value(max_energy,0)).
init(object(robot,1),value(energy,0)).
init(object(order,1),value(pickingStation,1)).
init(object(node,9),value(at,(2,2))).
init(object(node,10),value(at,(3,2))).
init(object(node,11),value(at,(4,2))).
init(object(node,12),value(at,(5,2))).
init(object(node,8),value(at,(1,2))).
init(object(node,13),value(at,(6,2))).
init(object(node,14),value(at,(7,2))).
init(object(node,3),value(at,(3,1))).
init(object(shelf,1),value(at,(2,2))).
init(object(product,1),value(on,(1,1))).
init(object(shelf,2),value(at,(6,2))).
init(object(product,2),value(on,(2,1))).
init(object(robot,2),value(at,(3,2))).
init(object(pickingStation,1),value(at,(1,2))).
init(object(pickingStation,2),value(at,(7,2))).
init(object(order,2),value(line,(2,2))).
init(object(robot,1),value(at,(5,2))).
init(object(order,1),value(line,(1,1))).
node_conflict(2,-1).
node_conflict(1,-1).
node_conflict(2,0).
node_conflict(1,0).
node_conflict(2,1).
node_conflict(2,2).
node_conflict(1,1).
node_conflict(1,2).
position(robot(2),(3,2),0).
position(robot(1),(5,2),0).
position(robot(2),(4,2),1).
position(robot(2),(5,2),2).
position(robot(2),(6,2),3).
position(robot(1),(4,2),1).
position(robot(1),(3,2),2).
position(robot(1),(2,2),3).
position(shelf(1),(2,2),0).
position(shelf(2),(6,2),0).
