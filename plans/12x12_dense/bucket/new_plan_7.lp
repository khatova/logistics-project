position(robot(7),(7,11),1).
position(shelf(7),(11,7),0).
occurs(object(robot,7),action(move,(0,-1)),2).
occurs(object(robot,7),action(move,(1,0)),3).
occurs(object(robot,7),action(move,(1,0)),4).
occurs(object(robot,7),action(move,(1,0)),5).
occurs(object(robot,7),action(move,(1,0)),6).
occurs(object(robot,7),action(move,(0,-1)),7).
occurs(object(robot,7),action(move,(0,-1)),8).
occurs(object(robot,7),action(move,(0,-1)),9).
position(robot(7),(7,10),2).
position(robot(7),(8,10),3).
position(robot(7),(9,10),4).
position(robot(7),(10,10),5).
position(robot(7),(11,10),6).
position(robot(7),(11,9),7).
position(robot(7),(11,8),8).
position(robot(7),(11,7),9).
new_illegal_from(7,(7,10),(7,11),2).
new_illegal_from(7,(8,10),(7,10),3).
new_illegal_from(7,(9,10),(8,10),4).
new_illegal_from(7,(10,10),(9,10),5).
new_illegal_from(7,(11,10),(10,10),6).
new_illegal_from(7,(11,9),(11,10),7).
new_illegal_from(7,(11,8),(11,9),8).
new_illegal_from(7,(11,7),(11,8),9).
