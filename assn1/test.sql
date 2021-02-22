--3--
-- select player_name, catches from
-- (
-- select fielders, count(*) as catches
-- from wicket_taken, match 
-- where fielders is not null -- there must be a fielder 
--     and kind_out = 1 -- it has to be caught out
--     and wicket_taken.match_id = match.match_id -- join to get match date
--     and extract (year from match_date) = 2012 -- ensure that it is 2012
-- group by fielders -- group by player id
-- order by count(*) -- number of catches
-- ) temp, player
-- where temp.fielders = player.player_id -- to get player name
-- order by catches desc, player_name
-- limit 1
-- ;

--4--
-- select season_year, player_name, num_matches from
-- (
-- select season_id, s1.purple_cap, count(*) as num_matches
-- from season as s1, player_match
-- where s1.purple_cap = player_match.player_id 
--     and player_match.match_id in (select match_id from match where match.season_id = s1.season_id) -- take player's matches from matches that happened in that season
-- group by s1.purple_cap, season_id
-- ) temp, player, season
-- where player.player_id = temp.purple_cap
--     and temp.season_id = season.season_id
-- order by season_year

--6--
select season_year, team_name, rank from
(
select season_year, team_name, num, row_number() over (order by num desc, team_name) as rank from
(
select season_id, team_id, count(*) as num from
(
select distinct team_id, season.season_id, player_match.player_id
from season, match, player_match, player, batting_style, country
where season.season_id = match.season_id
    and match.match_id = player_match.match_id
    and player.player_id = player_match.player_id
    and batting_style.batting_id = player.batting_hand
    and batting_style.batting_hand = 'Left-hand bat'
    and player.country_id = country.country_id
    and country_name <> 'India'
) temp
group by team_id, season_id
) temp2, season, team
where temp2.team_id = team.team_id
and temp2.season_id = season.season_id
) temp3
where rank <= 5
order by season_year, team_name

--7--
-- select team_name from
-- (
-- select match_winner, count(*) wins from
-- season, match 
-- where season_year = 2009
--     and season.season_id = match.season_id
--     and match_winner is not null
-- group by match_winner
-- ) temp, team
-- where team.team_id = match_winner
-- order by wins desc, team_name

--8--
-- select team_name, player_name, runs from
-- (
-- select team_id, player_name, sum(runs_scored) as runs, row_number() over (partition by team_id order by sum(runs_scored) desc, player_name) as rank from
-- season, match, ball_by_ball bb, batsman_scored bs, player_match, player
-- where season.season_year = 2010
--     and season.season_id = match.season_id
--     and bb.match_id = match.match_id
--     and bb.match_id = bs.match_id and bb.over_id = bs.over_id and bb.ball_id = bs.ball_id and bb.innings_no = bs.innings_no
--     and bb.striker = player_match.player_id and bb.match_id = player_match.match_id
--     and player.player_id = striker
-- group by team_id, player_name
-- ) temp, team
-- where rank = 1
--     and team.team_id = temp.team_id
-- order by team_name

--5--
-- select distinct player_name from
-- (
-- select bb.match_id, striker, sum(runs_scored) runs
-- from ball_by_ball bb, batsman_scored bs, match
-- where bb.innings_no not in (3,4) -- no superovers etc.
--     and bb.match_id = bs.match_id and bb.over_id = bs.over_id and bb.ball_id = bs.ball_id and bb.innings_no = bs.innings_no -- inner join bb and bs
--     and match.match_winner is not null and match.win_id not in (3,4) and match.outcome_id not in (2,3) -- filter matches s.t there is clear loser in match
--     and match.match_id = bb.match_id -- inner join match and bb
--     and team_batting <> match_winner -- striker's team is loser in this match
-- group by bb.match_id, striker
-- ) temp, player
-- where runs>50 and player.player_id = striker
-- order by player_name

--9--
-- select t1.team_name, t2.team_name as opponent_team_name, number_of_sixes from
-- (
-- select team_batting, team_bowling, count(*) as number_of_sixes
-- from season, match, ball_by_ball bb, batsman_scored bs
-- where season_year = 2008
--     and season.season_id = match.season_id --combine season and match (one-many)
--     and match.match_id = bb.match_id -- combine match and bb (one-many)
--     and bb.innings_no not in (3,4) --remove superovers, etc.
--     and bb.match_id = bs.match_id and bb.over_id = bs.over_id and bb.ball_id = bs.ball_id and bb.innings_no = bs.innings_no -- inner join bb and bs
--     and bs.runs_scored = 6 -- only sixes
-- group by bb.match_id, bb.innings_no, team_batting, team_bowling
-- ) temp, team t1, team t2
-- where t1.team_id = team_batting
--     and t2.team_id = team_bowling
-- order by number_of_sixes desc, t1.team_name, t2.team_name
-- limit 3;

--2--
-- select player_name as Player_name, num_matches from
-- (

-- select man_of_the_match, count(*) num_matches from
-- match, player_match
-- where match_winner is not null and win_id not in (3,4) and outcome_id not in (2,3)-- discard no_result and ties and matches with no winner
--     and man_of_the_match = player_match.player_id and player_match.match_id = match.match_id -- get me team_id of man of the match
--     and team_id <> match_winner -- his team has to be losing
-- group by man_of_the_match

-- ) temp, player -- only remaining thing is to get player name
-- where man_of_the_match = player.player_id -- get me man_of_the_match's name
-- order by num_matches desc, Player_name
-- limit 3
-- ;

--10--





















