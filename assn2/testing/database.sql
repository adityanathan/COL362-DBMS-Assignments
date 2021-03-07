-- create table edgetable(
-- 	x int,
-- 	y int,
-- 	primary key (x,y)
-- );

-- insert into edgetable 
-- values (1,2),(1,3),(1,6),(1,8),
-- (2,1),(2,3),(2,4),
-- (3,1),(3,2),(3,7),(3,9),
-- (4,2),(4,7),(4,5),(4,6),
-- (5,4),(5,6),
-- (6,5),(6,1),(6,4),
-- (7,3),(7,4),
-- (8,1),(8,9),(8,12),
-- (9,3),(9,8),(9,12),	
-- (10,11),
-- (11,10),
-- (12,9),(12,8);

-- delete from edgetable;

drop table authordetails;
drop table paperdetails;
drop table authorpaperlist;
drop table citationlist;



create table authordetails(
	authorid int primary key,
	city text,
	gender char,
	age int
);

insert into authordetails 
values (1,'a','m',40),(2,'b','f',40),(3,'c','m',40),(4,'a','m',40),(5,'d','f',40),(6,'a','m',40),
(7,'b','f',40),(8,'d','f',40),(9,'e','f',40),(10,'c','m',40),(11,'d','m',40),(12,'b','m',40);

-- delete from authordetails;


create table authorpaperlist (
	authorid int,
	paperid int,
	primary key(authorid,paperid)
);

insert into authorpaperlist 
values (1,100),(1,101),(1,102),
(2,100),(2,106),
(3,100),(3,108),(3,105),
(4,103),(4,104),(4,106),
(5,103),
(6,103),(6,101),
(7,104),(7,105),
(8,102),(8,107),
(9,107),(9,108),
(10,109),
(11,109),
(12,107);

-- delete from authorpaperlist;


create table citationlist (
	paperid1 int,
	paperid2 int,
	primary key(paperid1,paperid2)
);

insert into citationlist 
values (100,104),(100,101),(100,103),
(103,107),(103,101),
(107,104),
(108,100); 

-- delete from citationlist;


create table paperdetails(
	paperid int primary key,
	conferencename text
);

insert into paperdetails
values (100,'conf1'),
(101,'conf2'),
(102,'conf2'),
(103,'conf2'),
(104,'conf1'),
(105,'conf3'),
(106,'conf2'),
(107,'conf3'),
(108,'conf2'),
(109,'conf2');

