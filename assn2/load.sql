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
    constraint flightid_key primary key (flightid)
);

\copy airports from '/home/nate/acads/sem8/COL362/Assignments/assn2/DB/airports.csv' delimiter ',' csv header;
\copy flights from '/home/nate/acads/sem8/COL362/Assignments/assn2/DB/flights_reduced.csv' delimiter ',' csv header;