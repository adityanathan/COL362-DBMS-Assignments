--1--
select temp.match_id, player_name, team_name, num_wickets from 
(
select w.match_id, bowler, count(*) AS num_wickets
from (select * from wicket_taken where kind_out in (1,2,4,6,7,8)) w
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
(
select * from match
where match_winner is not null and win_id <> 4
) filtered_matches -- matches with clear loser

inner join player_match on man_of_the_match = player_match.player_id and player_match.match_id = filtered_matches.match_id -- get me team_id of man of the match
where team_id <> match_winner -- his team has to be losing
group by man_of_the_match
) temp -- only remaining thing is to get player name
inner join player on man_of_the_match = player.player_id -- get me man_of_the_match's name
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
select season_year, team_name, num, rank from 
(
select season_id, team_name, count(*) as num, row_number() over ( partition by season_id order by count(*) desc, team_name) as rank from
(
select distinct team_id, season.season_id, player_match.player_id
from season, match, player_match, player, batting_style
where season.season_id = match.season_id
    and match.match_id = player_match.match_id
    and player.player_id = player_match.player_id
    and batting_style.batting_id = player.batting_hand
    and batting_style.batting_hand = 'Left-hand bat'
) temp, team
where temp.team_id = team.team_id
group by team_name, season_id
) temp2, season
where temp2.season_id = season.season_id
    and rank <= 5
order by season_year
;

--6--
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