CREATE TABLE airports (
    airportid bigint NOT NULL,
    city text NOT NULL,
    state text NOT NULL,
    name text NOT NULL,
    constraint airportid_key primary key (airportid)
);

CREATE TABLE flights (
    flightid bigint NOT NULL,
    originairportid bigint NOT NULL,
    destairportid bigint NOT NULL,
    carrier text NOT NULL,
    dayofmonth bigint NOT NULL,
    dayofweek bigint NOT NULL,
    departuredelay bigint NOT NULL,
    arrivaldelay bigint NOT NULL,
    constraint flightid_key primary key (flightid),
    constraint originairportid_ref foreign key (originairportid) references airports(airportid),
    constraint destairportid_ref foreign key (destairportid) references airports(airportid)
);

\copy airports from '/home/nate/acads/sem8/COL362/Assignments/assn2/DB/airports.csv' delimiter ',' csv header;
\copy flights from '/home/nate/acads/sem8/COL362/Assignments/assn2/DB/flights_final.csv' delimiter ',' csv header;

CREATE TABLE authordetails (
    authorid bigint NOT NULL,
    authorname text NOT NULL,
    city text NOT NULL,
    gender text NOT NULL,
    age bigint NOT NULL,
    constraint authorid_key primary key (authorid)
);

CREATE TABLE paperdetails (
    paperid bigint NOT NULL,
    papername text NOT NULL,
    conferencename text NOT NULL,
    score bigint NOT NULL,
    constraint paperid_key primary key (paperid)
);

CREATE TABLE authorpaperlist (
    authorid bigint NOT NULL,
    paperid bigint NOT NULL,
    constraint authorpaper_key primary key (authorid, paperid),
    constraint authorid_ref foreign key (authorid) references authordetails(authorid),
    constraint paperid_ref foreign key (paperid) references paperdetails(paperid)
);

CREATE TABLE citationlist (
    paperid1 bigint NOT NULL,
    paperid2 bigint NOT NULL,
    constraint paper_key primary key (paperid1, paperid2),
    constraint paperid1_ref foreign key (paperid1) references paperdetails(paperid),
    constraint paperid2_ref foreign key (paperid2) references paperdetails(paperid)
);

insert into authordetails
values 
(1, 's1', 'city1', 'm', 42),
(2, 's2', 'city1', 'f', 38),
(3, 's3', 'city1', 'f', 58),
(4, 's4', 'city2', 'm', 48),
(5, 's5', 'city1', 'm', 78),
(6, 's6', 'city2', 'f', 30)
;
-- copy batsman_scored from 'D:\sem8\DBMS\IPL DB\batsman_scored.csv' delimiter ',' CSV HEADER;

insert into paperdetails
values
(1,'p12','c1',100),
(2,'p13','c1',89),
(3,'p23','c1',89),
(4,'p24','c2',79),
(5,'p56','c1',99)
;

-- copy wicket_taken from 'D:\sem8\DBMS\IPL DB\wicket_taken.csv' delimiter ',' CSV HEADER;

insert into authorpaperlist
values
(1,1),
(1,2),
(2,1),
(2,3),
(2,4),
(3,2),
(3,3),
(4,4),
-- (5,5),
(6,5)
;

insert into citationlist
values
(1,2),
(2,3),
(3,5),
(5,4)
;