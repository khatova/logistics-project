position(robot(23),(8,2),7).
position(shelf(23),(10,3),0).
occurs(object(robot,23),action(move,(1,0)),8).
occurs(object(robot,23),action(move,(1,0)),9).
occurs(object(robot,23),action(move,(0,1)),10).
position(robot(23),(9,2),8).
position(robot(23),(10,2),9).
position(robot(23),(10,3),10).
new_illegal_from(23,(9,2),(8,2),8).
new_illegal_from(23,(10,2),(9,2),9).
new_illegal_from(23,(10,3),(10,2),10).
