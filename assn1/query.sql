--1--
select temp.match_id, player_name, team_name, num_wickets from 
(
select w.match_id, bowler, count(*) AS num_wickets
from (select * from wicket_taken where kind_out in (1,2,4,6,7,8) and innings_no not in (3,4)) w
inner join ball_by_ball using(match_id, over_id, ball_id, innings_no)
group by w.match_id, bowler
having count(*) >= 5
) temp

inner join player_match
on player_match.player_id = temp.bowler and player_match.match_id = temp.match_id
inner join player on temp.bowler = player.player_id
inner join team using(team_id)

order by num_wickets desc, player_name, team_name
;

--2--
select player_name as Player_name, num_matches from
(

select man_of_the_match, count(*) num_matches from
match, player_match
where match_winner is not null and win_id not in (3,4) and outcome_id not in (2,3)-- discard no_result and ties and matches with no winner
    and man_of_the_match = player_match.player_id and player_match.match_id = match.match_id -- get me team_id of man of the match
    and team_id <> match_winner -- his team has to be losing
group by man_of_the_match

) temp, player -- only remaining thing is to get player name
where man_of_the_match = player.player_id -- get me man_of_the_match's name
order by num_matches desc, Player_name
limit 3
;

--3--
select player_name from
(
select fielders, count(*) as catches
from wicket_taken, match 
where fielders is not null -- there must be a fielder 
    and kind_out = 1 -- it has to be caught out
    and wicket_taken.innings_no not in (3,4)
    and wicket_taken.match_id = match.match_id -- join to get match date
    and extract (year from match_date) = 2012 -- ensure that it is 2012
group by fielders -- group by player id
order by count(*) -- number of catches
) temp, player
where temp.fielders = player.player_id -- to get player name
order by catches desc, player_name
limit 1
;

--4--
select season_year, player_name, num_matches from
(
select season_id, s1.purple_cap, count(*) as num_matches
from season as s1, player_match
where s1.purple_cap = player_match.player_id 
    and player_match.match_id in (select match_id from match where match.season_id = s1.season_id) -- take player's matches from matches that happened in that season
group by s1.purple_cap, season_id
) temp, player, season
where player.player_id = temp.purple_cap
    and temp.season_id = season.season_id
order by season_year
;

--5--
select distinct player_name from
(
select bb.match_id, striker, sum(runs_scored) runs
from ball_by_ball bb, batsman_scored bs, match
where bb.innings_no not in (3,4) -- no superovers etc.
    and bb.match_id = bs.match_id and bb.over_id = bs.over_id and bb.ball_id = bs.ball_id and bb.innings_no = bs.innings_no -- inner join bb and bs
    and match.match_winner is not null and match.win_id not in (3,4) and match.outcome_id not in (2,3) -- filter matches s.t there is clear loser in match
    and match.match_id = bb.match_id -- inner join match and bb
    and team_batting <> match_winner -- striker's team is loser in this match
group by bb.match_id, striker
) temp, player
where runs>50 and player.player_id = striker
order by player_name
;

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
;

--7--
select team_name from
(
select match_winner, count(*) wins from
season, match 
where season_year = 2009
    and season.season_id = match.season_id
    and match_winner is not null
group by match_winner
) temp, team
where team.team_id = match_winner
order by wins desc, team_name
;

--8--
select team_name, player_name, runs from
(
select team_id, player_name, sum(runs_scored) as runs, row_number() over (partition by team_id order by sum(runs_scored) desc, player_name) as rank from
season, match, ball_by_ball bb, batsman_scored bs, player_match, player
where season.season_year = 2010
    and season.season_id = match.season_id
    and bb.innings_no not in (3,4) and bs.innings_no not in (3,4)
    and bb.match_id = match.match_id
    and bb.match_id = bs.match_id and bb.over_id = bs.over_id and bb.ball_id = bs.ball_id and bb.innings_no = bs.innings_no
    and bb.striker = player_match.player_id and bb.match_id = player_match.match_id
    and player.player_id = striker
group by team_id, player_name
) temp, team
where rank = 1
    and team.team_id = temp.team_id
order by team_name
;

--9--
select t1.team_name, t2.team_name as opponent_team_name, number_of_sixes from
(
select team_batting, team_bowling, count(*) as number_of_sixes
from season, match, ball_by_ball bb, batsman_scored bs
where season_year = 2008
    and season.season_id = match.season_id --combine season and match (one-many)
    and match.match_id = bb.match_id -- combine match and bb (one-many)
    and bb.innings_no not in (3,4) --remove superovers, etc.
    and bb.match_id = bs.match_id and bb.over_id = bs.over_id and bb.ball_id = bs.ball_id and bb.innings_no = bs.innings_no -- inner join bb and bs
    and bs.runs_scored = 6 -- only sixes
group by bb.match_id, bb.innings_no, team_batting, team_bowling
) temp, team t1, team t2
where t1.team_id = team_batting
    and t2.team_id = team_bowling
order by number_of_sixes desc, t1.team_name, t2.team_name
limit 3
;

--10--

--11--
select season_year, player_name, season_wickets as num_wickets, season_runs as runs from
-- left handed batsman with num_matches played in a season
(select player.player_id, match.season_id, count(*) matches_played
from player, player_match, match, batting_style
where player.player_id = player_match.player_id
    and match.match_id = player_match.match_id
    and batting_style.batting_id = player.batting_hand
    and batting_style.batting_hand = 'Left-hand bat'
group by player.player_id, match.season_id) matches,

-- total runs per season for each player
(select striker, season_id, sum(runs_scored) as season_runs
from match, ball_by_ball bb, batsman_scored bs
where bb.innings_no not in (3,4) -- no superovers etc.
    and bb.match_id = bs.match_id and bb.innings_no = bs.innings_no and bb.over_id = bs.over_id and bb.ball_id = bs.ball_id -- join bs and bb
    and match.match_id = bb.match_id -- join match and bb - for season_id
group by season_id, striker) runs,

-- total wickets taken per season for each bowler (need to consider only bowler)
(select bowler, season_id, count(*) as season_wickets
from match, ball_by_ball bb, wicket_taken bs
where bb.innings_no not in (3,4) -- no superovers etc.
    and bb.match_id = bs.match_id and bb.innings_no = bs.innings_no and bb.over_id = bs.over_id and bb.ball_id = bs.ball_id -- join bs and bb
    and bs.kind_out in (1,2,4,6,7,8) -- consider only wickets taken by bowlers
    and match.match_id = bb.match_id -- join match and bb - for season_id
group by season_id, bowler) wickets,
player, season

-- now do inner join of the three tables
where matches.player_id = runs.striker and runs.striker = wickets.bowler and wickets.bowler = player.player_id
    and matches.season_id = runs.season_id and runs.season_id = wickets.season_id and wickets.season_id = season.season_id -- join all three tables + player, season for meta information
    and season_runs >= 150
    and season_wickets >= 5
    and matches_played >= 10
order by num_wickets desc, runs desc, player_name
;

--12--
select temp.match_id, player_name, team_name, wickets as num_wickets, season_year from
(
select bb.match_id, bowler, team_bowling, count(*) wickets
from ball_by_ball bb, wicket_taken wt
where bb.innings_no not in (3,4) -- no superovers etc.
    and wt.kind_out in (1,2,4,6,7,8) -- only bowler wickets
    and bb.match_id = wt.match_id and bb.over_id = wt.over_id and bb.ball_id = wt.ball_id and bb.innings_no = wt.innings_no -- join bb and wt
group by bb.match_id, bowler, team_bowling
) temp, player, team, match, season
where bowler = player.player_id
    and team_bowling = team.team_id
    and temp.match_id = match.match_id
    and match.season_id = season.season_id
order by num_wickets desc, player_name, match_id
limit 1;

--13--
select player_name from
(
select player_id from
(
select distinct player_id, season_id
from player_match, match
where player_match.match_id = match.match_id
-- group by player_id
order by player_id, season_id
) temp -- in each season, which players played
group by player_id
having count(*) = (select count(*) from season) -- gives me 9 = total no. of seasons
) temp2, player
where temp2.player_id = player.player_id
order by player_name
;

--15--
select season_year, runs_per_season.player_name as top_batsman, runs as max_runs, wickets_per_season.player_name as top_bowler, wickets as max_wickets from
(select * from
(
select season_id, player_name, runs, row_number() over (partition by season_id order by runs desc, player_name) as run_rank from
(
select season_id, striker, sum(runs_scored) runs
from batsman_scored bs, ball_by_ball bb, match
where bb.innings_no not in (3,4) -- no superovers etc.
    and bb.match_id = bs.match_id and bb.over_id = bs.over_id and bb.ball_id = bs.ball_id and bb.innings_no = bs.innings_no
    and match.match_id = bb.match_id
group by season_id, striker
) temp, player
where player.player_id = striker
) temp2
where run_rank = 2
) runs_per_season,

(select * from
(
select season_id, player_name, wickets, row_number() over (partition by season_id order by wickets desc, player_name) as wt_rank from
(
select season_id, bowler, count(*) wickets
from wicket_taken wt, ball_by_ball bb, match
where bb.innings_no not in (3,4) -- no superovers etc.
    and wt.kind_out in (1,2,4,6,7,8) -- only bowler wickets
    and bb.match_id = wt.match_id and bb.over_id = wt.over_id and bb.ball_id = wt.ball_id and bb.innings_no = wt.innings_no
    and match.match_id = bb.match_id
group by season_id, bowler
) temp, player
where player.player_id = bowler
) temp2
where wt_rank = 2
) wickets_per_season, season

where runs_per_season.season_id = wickets_per_season.season_id and wickets_per_season.season_id = season.season_id
order by season_year
;

--16--
select win_team.team_name
from season, match, team t1, team t2, team win_team
where season_year = 2008
    and match.match_winner is not null and match.win_id not in (3,4) and match.outcome_id not in (2,3) -- filter matches s.t there is clear loser in match
    and season.season_id = match.season_id
    and match.team_1 = t1.team_id and match.team_2 = t2.team_id and match.match_winner = win_team.team_id
    and (t1.team_name = 'Royal Challengers Bangalore' or t2.team_name = 'Royal Challengers Bangalore')
    and win_team.team_name <> 'Royal Challengers Bangalore'
group by win_team.team_name
order by count(*) desc, win_team.team_name
;