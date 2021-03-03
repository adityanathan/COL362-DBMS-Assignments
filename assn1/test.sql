--2--
-- select country_name, player_name, num_wickets, runs_conceded from
-- (
-- select bowler, count(*) num_wickets
-- from ball_by_ball bb, wicket_taken ws, out_type
-- where bb.innings_no not in (3,4) -- no superovers etc.
--     and bb.match_id = ws.match_id and bb.over_id = ws.over_id and bb.ball_id = ws.ball_id and bb.innings_no = ws.innings_no
--     and out_name not in ('run out', 'retired hurt', 'obstructing the field') and out_type.out_id = ws.kind_out -- bowler took wicket
-- group by bowler
-- ) wickets_scored,

-- (
-- select bowler, sum(runs_scored) runs_conceded
-- from ball_by_ball bb, batsman_scored bs
-- where bb.innings_no not in (3,4) -- no superovers etc.
--     and bb.match_id = bs.match_id and bb.over_id = bs.over_id and bb.ball_id = bs.ball_id and bb.innings_no = bs.innings_no
-- group by bowler
-- ) runs, player, country

-- where player.player_id = runs.bowler and runs.bowler = wickets_scored.bowler
--     and country.country_id = player.country_id

-- order by num_wickets desc, runs_conceded, player_name
-- limit 1;

--4--
-- select season_year, runs_per_season.player_name as top_batsman, runs as max_runs, wickets_per_season.player_name as top_bowler, wickets as max_wickets from
-- (select * from
-- (
-- select season_id, player_name, runs, row_number() over (partition by season_id order by runs desc, player_name) as run_rank from
-- (
-- select season_id, striker, sum(runs_scored) runs
-- from batsman_scored bs, ball_by_ball bb, match
-- where bb.innings_no not in (3,4) -- no superovers etc.
--     and bb.match_id = bs.match_id and bb.over_id = bs.over_id and bb.ball_id = bs.ball_id and bb.innings_no = bs.innings_no
--     and match.match_id = bb.match_id
-- group by season_id, striker
-- ) temp, player, country, batting_style
-- where player.player_id = striker
--     and country.country_id = player.country_id
--     and player.batting_hand = batting_style.batting_id
--     and batting_style.batting_hand = 'Right-hand bat'
--     and country.country_name <> 'India'
-- ) temp2
-- where run_rank = 3
-- ) runs_per_season,

-- (
-- select * from
-- (
-- select season_id, player_name, wickets, row_number() over (partition by season_id order by wickets desc, player_name) as wt_rank from
-- (
-- select season_id, bowler, count(*) wickets
-- from wicket_taken wt, ball_by_ball bb, match, out_type
-- where bb.innings_no not in (3,4) -- no superovers etc.
--     and out_name not in ('run out', 'retired hurt', 'obstructing the field') and out_type.out_id = wt.kind_out -- bowler took wicket
--     and bb.match_id = wt.match_id and bb.over_id = wt.over_id and bb.ball_id = wt.ball_id and bb.innings_no = wt.innings_no
--     and match.match_id = bb.match_id
-- group by season_id, bowler
-- ) temp, player, country
-- where player.player_id = bowler
--     and country.country_id = player.country_id
--     and country.country_name <> 'India'
-- ) temp2
-- where wt_rank = 2
-- ) wickets_per_season, season

-- where runs_per_season.season_id = wickets_per_season.season_id and wickets_per_season.season_id = season.season_id
-- order by season_year
-- ;


--5--
-- select season_year, player_name from
-- (
-- select season_id, player_name, sixes, row_number() over (partition by season_id order by sixes desc, player_name) rank from
-- (
-- select season_id, striker, count(*) sixes
-- from ball_by_ball bb, batsman_scored bs, match
-- where bb.innings_no not in (3,4)
--     and bb.match_id = bs.match_id and bb.over_id = bs.over_id and bb.ball_id = bs.ball_id and bb.innings_no = bs.innings_no
--     and bb.match_id = match.match_id
--     and bs.runs_scored = 6
-- group by season_id, striker
-- ) temp, player
-- where player.player_id = temp.striker
-- ) temp2, season
-- where rank <= 3
--     and season.season_id = temp2.season_id
-- order by season_year;

--3--
-- select player_name, num_wickets, runs.runs_t from
-- (
-- select bowler, count(*) num_wickets
-- from ball_by_ball bb, wicket_taken ws, out_type
-- where bb.innings_no not in (3,4) -- no superovers etc.
--     and bb.match_id = ws.match_id and bb.over_id = ws.over_id and bb.ball_id = ws.ball_id and bb.innings_no = ws.innings_no
--     and out_name not in ('run out', 'retired hurt', 'obstructing the field') and out_type.out_id = ws.kind_out -- bowler took wicket
-- group by bowler
-- ) wick,

-- (
-- select ROUND(AVG(num_wickets), 2) avg from
-- (
-- select bowler, count(*) num_wickets
-- from ball_by_ball bb, wicket_taken ws, out_type
-- where bb.innings_no not in (3,4) -- no superovers etc.
--     and bb.match_id = ws.match_id and bb.over_id = ws.over_id and bb.ball_id = ws.ball_id and bb.innings_no = ws.innings_no
--     and out_name not in ('run out', 'retired hurt', 'obstructing the field') and out_type.out_id = ws.kind_out -- bowler took wicket
-- group by bowler
-- ) temp
-- ) avg_wick,

-- (
-- select striker, sum(runs_scored) runs_t
-- from ball_by_ball bb, batsman_scored bs
-- where bb.innings_no not in (3,4) -- no superovers etc.
--     and bb.match_id = bs.match_id and bb.over_id = bs.over_id and bb.ball_id = bs.ball_id and bb.innings_no = bs.innings_no
-- group by striker
-- ) runs,

-- (
-- select ROUND(AVG(runs), 2) avg from
-- (
-- select striker, sum(runs_scored) runs
-- from ball_by_ball bb, batsman_scored bs
-- where bb.innings_no not in (3,4) -- no superovers etc.
--     and bb.match_id = bs.match_id and bb.over_id = bs.over_id and bb.ball_id = bs.ball_id and bb.innings_no = bs.innings_no
-- group by striker
-- ) temp
-- ) avg_runs, player

-- where wick.bowler = runs.striker
--     and ((wick.num_wickets > avg_wick.avg) or (runs.runs_t > avg_runs.avg))
--     and player.player_id = wick.bowler;

--New--































