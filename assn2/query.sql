--1--
WITH RECURSIVE
path(originairportid, destairportid, carrier) AS (
        
        select originairportid, destairportid, carrier
        from flights
        
        union
        
        select flights.originairportid, path.destairportid, flights.carrier
        from flights, path
        where flights.destairportid = path.originairportid
            and flights.carrier = path.carrier
)
select distinct airports.city
from path, airports
where path.originairportid = 10140
    and path.destairportid = airports.airportid
order by airports.city
;

--2--
WITH RECURSIVE
path(originairportid, destairportid, dayofweek) AS (
        
        select originairportid, destairportid, dayofweek
        from flights
        
        union

        select flights.originairportid, path.destairportid, flights.dayofweek
        from flights, path
        where flights.destairportid = path.originairportid
            and flights.dayofweek = path.dayofweek
)
select distinct airports.city
from path, airports
where path.originairportid = 10140
    and path.destairportid = airports.airportid
order by airports.city
;

--3--
select city from
(
with recursive path(originairportid, destairportid, city_path) as (

    select originairportid, destairportid, array[a1.city, a2.city] -- path of cities grows rightwards
    from flights, airports a1, airports a2
    where a1.airportid = originairportid and a2.airportid = destairportid

    union

    select path.originairportid, flights.destairportid, city_path || a1.city
    from flights, path, airports a1
    where path.destairportid = flights.originairportid
        and a1.airportid = flights.destairportid
        and (not (a1.city = ANY(city_path))) -- only simple paths
)
select originairportid, destairportid, count(*) num
from path
where originairportid = 10140
group by originairportid, destairportid
having count(*) = 1
) temp, airports where airportid = destairportid
order by city
;

--4--
select coalesce(max(length),0) length from
(
with recursive path(originairportid, destairportid, city_path) as (

    select originairportid, destairportid, array[a1.city, a2.city] -- path of cities grows rightwards
    from flights, airports a1, airports a2
    where a1.airportid = originairportid and a2.airportid = destairportid

    union

    select path.originairportid, flights.destairportid, city_path || fd.city
    from flights, path, airports po, airports pd, airports fo, airports fd
    where 
        path.originairportid = po.airportid and path.destairportid = pd.airportid and flights.originairportid = fo.airportid and flights.destairportid = fd.airportid
        and path.destairportid = flights.originairportid -- link
        and po.city <> pd.city -- cannot extend once origin = dest in path i.e [A,...,A]
        and ((not fd.city = ANY(city_path)) or fd.city = po.city) -- either ensure simple path or round trip is complete
)
select array_length(city_path, 1) - 1 length
from path, airports po, airports pd
where po.airportid = path.originairportid and pd.airportid = path.destairportid
    and po.city = pd.city
    and 'Albuquerque' = ANY(city_path)
) temp
;

--5--
select coalesce(max(length),0) length from
(
with recursive path(originairportid, destairportid, city_path) as (

    select originairportid, destairportid, array[a1.city, a2.city] -- path of cities grows rightwards
    from flights, airports a1, airports a2
    where a1.airportid = originairportid and a2.airportid = destairportid

    union

    select path.originairportid, flights.destairportid, city_path || fd.city
    from flights, path, airports po, airports pd, airports fo, airports fd
    where 
        path.originairportid = po.airportid and path.destairportid = pd.airportid and flights.originairportid = fo.airportid and flights.destairportid = fd.airportid
        and path.destairportid = flights.originairportid -- link
        and po.city <> pd.city -- cannot extend once origin = dest in path i.e [A,...,A]
        and ((not fd.city = ANY(city_path)) or fd.city = po.city) -- either ensure simple path or round trip is complete
)
select po.city, pd.city, city_path, array_length(city_path, 1) - 1 length
from path, airports po, airports pd
where po.airportid = path.originairportid and pd.airportid = path.destairportid
    and po.city = pd.city
) temp
;

--6--
with recursive path(originairportid, destairportid, city_path) as (

    select originairportid, destairportid, array[a1.city, a2.city] -- path of cities grows rightwards
    from flights, airports a1, airports a2
    where a1.airportid = originairportid and a2.airportid = destairportid
        and a1.state <> a2.state -- only interstate flights

    union

    select path.originairportid, flights.destairportid, city_path || fd.city
    from flights, path, airports po, airports fd
    where path.destairportid = flights.originairportid -- link
        and flights.destairportid = fd.airportid and path.originairportid = po.airportid
        and (not fd.city = ANY(city_path)) -- ensure simple path
        and po.city = 'Albuquerque' -- for efficiency
)
select count(*) count -- number of paths between chicago and albuquerque through interstate flights
from path, airports po, airports pd
where path.originairportid = po.airportid and path.destairportid = pd.airportid
    and po.city = 'Albuquerque' 
    and pd.city = 'Chicago'
group by po.city, pd.city
;

--7--