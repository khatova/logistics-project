position(robot(2),(4,3),1).
position(shelf(2),(1,4),0).
occurs(object(robot,2),action(move,(0,-1)),2).
occurs(object(robot,2),action(move,(0,-1)),3).
position(robot(2),(4,2),2).
position(robot(2),(4,1),3).
new_illegal_from(2,(4,2),(4,3),2).
new_illegal_from(2,(4,1),(4,2),3).
