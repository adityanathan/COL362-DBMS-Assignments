--PREAMBLE--
--multiple (a1,a2) but with different papers
create view authorpaper_edges as
    select distinct a.authorid authorid1, b.authorid authorid2, a.paperid paperid
    from authorpaperlist a, authorpaperlist b
    where a.paperid = b.paperid
        and a.authorid <> b.authorid -- avoid self loops
;

create view author_edges as
    select distinct a.authorid authorid1, b.authorid authorid2
    from authorpaperlist a, authorpaperlist b
    where a.paperid = b.paperid
        and a.authorid <> b.authorid -- avoid self loops
;

create view simple_author_paths as
    with recursive path(authorid1, authorid2, author_path) as (
        select authorid1, authorid2, array[authorid1, authorid2] -- path grows to the right 
        from author_edges

        union

        select path.authorid1, ae.authorid2, author_path || ae.authorid2
        from author_edges ae, path
        where path.authorid2 = ae.authorid1 -- recursion link
            and (not ae.authorid2 = ANY(author_path)) -- simple path
    )
    select * from path
;

create view paper_citations as
    with recursive paper_citations(paperid1, paperid2) as (
        select * from citationlist
        union
        select paper_citations.paperid1, cl.paperid2
        from paper_citations, citationlist cl
        where paper_citations.paperid2 = cl.paperid1
            and paper_citations.paperid1 <> cl.paperid2 -- a paper should not indirectly cite itself
    )
    select * from paper_citations
;

create view citations_per_author as
    select ap.authorid as authorid, sum(num) as total_citations from
    (
    select paperid2 as paperid, count(paperid1) num
    from paper_citations
    group by paperid2 -- number of citations for each paper
    ) citations_per_paper, authorpaperlist ap
    where ap.paperid = citations_per_paper.paperid
    group by ap.authorid
;

create view authorconf_edges as
    select distinct a.authorid authorid1, b.authorid authorid2, paperdetails.conferencename
    from authorpaperlist a, authorpaperlist b, paperdetails
    where a.paperid = b.paperid
        and a.authorid <> b.authorid -- avoid self loops
        and a.paperid = paperdetails.paperid
;

create view conference_connected_components as -- fields = (conferencename, component)
    with recursive path(authorid1, authorid2, conferencename) as (
        select authorid1, authorid2, conferencename
        from authorconf_edges

        union

        select path.authorid1, ace.authorid2, path.conferencename
        from path, authorconf_edges ace
        where path.authorid2 = ace.authorid1 -- recursion link
            and path.authorid1 <> ace.authorid2 -- self loops not allowed
            and path.conferencename = ace.conferencename
    ) -- edges of conference connected graph

    select distinct temp2.conferencename, coalesce(temp1.component, temp2.component) component from 
        (select authorid1, conferencename, 
            (select array(select distinct a from unnest(authorid1 || array_agg(authorid2)) as a order by a)) component
        from path
        group by authorid1, conferencename) temp1 -- connected components of size > 1

    right join -- gives me connected components of size 1

        (select a.authorid, pd.conferencename, array[a.authorid] component
        from authorpaperlist a, paperdetails pd
        where a.paperid = pd.paperid) temp2

    on temp1.authorid1 = temp2.authorid and temp1.conferencename = temp2.conferencename
;

-- select authorid1, authorid2, author_path, array_length(author_path,1)-1 length
-- from simple_author_paths p;


--12--
-- select a3.authorid, coalesce(length,-1) length from
-- (
-- select authorid2, min(array_length(author_path,1)-1) length
-- from simple_author_paths p
-- where p.authorid1 = 1235
-- group by authorid2
-- ) temp
-- right join authordetails a3 on authorid2 = a3.authorid
-- where a3.authorid <> 1235
-- ;

--14--
-- select least((select -1 where not exists (select * from simple_author_paths where authorid1 = 704 and authorid2 = 102)),
-- (select count(author_path) count
-- from simple_author_paths
-- where authorid1 = 704 and authorid2 = 102
--     and exists(
--         select * from
--         (
--             select distinct ap.authorid
--             from paper_citations pp, authorpaperlist ap
--             where ap.paperid = pp.paperid1
--                 and pp.paperid2 = 126 -- gives me all the authors who directly or indirectly cited this paper
--         ) temp
--         where temp.authorid = ANY(author_path[2:array_length(author_path,1)-1]) -- omit A and B
--     )
-- )) count
-- ;

--15--
-- select least((select -1 where not exists (select * from simple_author_paths where authorid1 = 1745 and authorid2 = 456)),
-- (select count(author_path) from
-- (
-- (
-- with recursive path(authorid1, authorid2, author_path) as (
--     select authorid1, authorid2, array[authorid1, authorid2] -- path grows to the right 
--     from author_edges

--     union

--     select path.authorid1, ae.authorid2, author_path || ae.authorid2
--     from path, author_edges ae, citations_per_author cpa1, citations_per_author cpa2
--     where path.authorid2 = ae.authorid1 -- recursion link
--         and (not ae.authorid2 = ANY(author_path)) -- simple path
--         and cpa1.authorid = ae.authorid1 and cpa2.authorid = ae.authorid2
--         and ((cpa1.total_citations < cpa2.total_citations) or (ae.authorid2 = 456))
-- )
-- select * 
-- from path
-- where authorid1 = 1745 and authorid2 = 456
-- )
-- union
-- (
-- with recursive path(authorid1, authorid2, author_path) as (
--     select authorid1, authorid2, array[authorid1, authorid2] -- path grows to the right 
--     from author_edges

--     union

--     select path.authorid1, ae.authorid2, author_path || ae.authorid2
--     from path, author_edges ae, citations_per_author cpa1, citations_per_author cpa2
--     where path.authorid2 = ae.authorid1 -- recursion link
--         and (not ae.authorid2 = ANY(author_path)) -- simple path
--         and cpa1.authorid = ae.authorid1 and cpa2.authorid = ae.authorid2
--         and ((cpa1.total_citations > cpa2.total_citations) or (ae.authorid2 = 456))
-- )
-- select * 
-- from path
-- where authorid1 = 1745 and authorid2 = 456
-- )
-- ) temp
-- )) count
-- ;

--16--
-- select author1 as authorid from
-- (
-- (select distinct a1.authorid author1, a2.authorid author2
-- from authorpaperlist a1, paper_citations, authorpaperlist a2
-- where a1.paperid = paperid1 and paperid2 = a2.paperid
--     and a1.authorid <> a2.authorid
-- ) -- author1 cited author2 
-- except
-- (select * from author_edges) -- author1 coauthored a paper with author2
-- ) temp
-- group by author1
-- order by count(author2) desc, author1
-- limit 10
-- ;

--17--
-- select third_degree.authorid1 authorid from
-- (
-- select a.authorid, count(paperid1) num
-- from authorpaperlist a, paper_citations pc
-- where a.paperid = pc.paperid2
-- group by a.authorid
-- ) author_citations, -- num of citations each author has received
-- (
-- select authorid1, authorid2
-- from simple_author_paths ap
-- group by authorid1, authorid2
-- having min(array_length(author_path,1)-1) = 3
-- ) third_degree -- third degree connections

-- where third_degree.authorid2 = author_citations.authorid
-- group by authorid1
-- order by sum(num) desc, authorid1
-- limit 10
-- ;

--18--
-- select least((select -1 where not exists (select * from simple_author_paths where authorid1 = 3552 and authorid2 = 321)),
-- (select count(author_path) count
-- from simple_author_paths
-- where 
--     authorid1 = 3552 and authorid2 = 321
--     and exists(
--         select authorid 
--         from authordetails
--         where 
--             authorid in (1436, 562, 921)
--             and authorid = ANY(author_path)
--     )
-- )) count
;

--19--
-- with recursive path(authorid1, authorid2, author_path, city_list, paper_list, cite_list) as (

--         select distinct authorid1, authorid2, 
--             array[authorid1, authorid2] author_path, 
--             array[a2.city] city_list,
--             array(select paperid from authorpaperlist ap where ap.authorid = authorid2) as paper_list, -- don't consider first guy
--             array(select paperid from authorpaperlist ap, citationlist cl where authorid2 = ap.authorid and ap.paperid = cl.paperid1) as cite_list -- don't consider first guy

--         from author_edges, authordetails a1, authordetails a2
--             where authorid1 = a1.authorid and authorid2 = a2.authorid
        
--         union

--         select path.authorid1, ae.authorid2, 
--             author_path || ae.authorid2,
--             city_list || ad.city,
--             (select array(select distinct a from unnest( -- to remove duplicates
--                 paper_list || array(select paperid from authorpaperlist ap where ap.authorid = ae.authorid2)
--             ) as a)),
--             (select array(select distinct a from unnest( -- to remove duplicates
--                 cite_list || array(select paperid2 from authorpaperlist ap, citationlist cl where ae.authorid2 = ap.authorid and ap.paperid = cl.paperid1)
--             ) as a))

--         from path, author_edges ae, authordetails ad
--         where path.authorid2 = ae.authorid1 -- recursion link
--             and (not ae.authorid2 = ANY(author_path)) -- simple path
--             and ae.authorid2 = ad.authorid
--             and 
--             ((ae.authorid2 = 321) or -- exclude first and last guy
--             (
--                 (not ad.city = ANY(city_list)) -- this author is not in the same city as any previous author
--                 and not exists(
--                     select ap.paperid from authorpaperlist ap 
--                     where ap.authorid = ae.authorid2
--                         and (not ap.paperid = ANY(cite_list)) -- this author's papers haven't been cited by previous authors on the path
--                 )
--                 and not exists(
--                     select cl.paperid2 from authorpaperlist ap, citationlist cl 
--                     where ae.authorid2 = ap.authorid and ap.paperid = cl.paperid1
--                         and (not cl.paperid2 = ANY(paper_list)) -- this author hasn't cited any previous author's papers
--                 )
--             )
--             )
-- )
-- select least((select -1 where not exists (select * from simple_author_paths where authorid1 = 3552 and authorid2 = 321)),
-- (select count(author_path)
-- from path
-- where authorid1 = 3552 and authorid2 = 321
-- )) count
-- ;

--20--
-- with recursive path(authorid1, authorid2, author_path, paper_list, cite_list) as (

--         select distinct authorid1, authorid2, 
--             array[authorid1, authorid2] author_path, 
--             array(select paperid from authorpaperlist ap where ap.authorid = authorid2) as paper_list,
--             array(select paperid from authorpaperlist ap, paper_citations cl where authorid2 = ap.authorid and ap.paperid = cl.paperid1) as cite_list

--         from author_edges, authordetails a1, authordetails a2
--             where authorid1 = a1.authorid and authorid2 = a2.authorid
        
--         union

--         select path.authorid1, ae.authorid2, 
--             author_path || ae.authorid2,
--             (select array(select distinct a from unnest( -- to remove duplicates
--                 paper_list || array(select paperid from authorpaperlist ap where ap.authorid = ae.authorid2)
--             ) as a)),
--             (select array(select distinct a from unnest( -- to remove duplicates
--                 cite_list || array(select paperid2 from authorpaperlist ap, paper_citations cl where ae.authorid2 = ap.authorid and ap.paperid = cl.paperid1)
--             ) as a))

--         from path, author_edges ae, authordetails ad
--         where path.authorid2 = ae.authorid1 -- recursion link
--             and (not ae.authorid2 = ANY(author_path)) -- simple path
--             and ae.authorid2 = ad.authorid
--             and 
--             ((ae.authorid2 = 321) or -- exclude first and last guy
--             (
--                 not exists(
--                     select ap.paperid from authorpaperlist ap 
--                     where ap.authorid = ae.authorid2
--                         and (not ap.paperid = ANY(cite_list)) -- this author's papers haven't been cited by previous authors on the path
--                 )
--                 and not exists(
--                     select cl.paperid2 from authorpaperlist ap, paper_citations cl 
--                     where ae.authorid2 = ap.authorid and ap.paperid = cl.paperid1
--                         and (not cl.paperid2 = ANY(paper_list)) -- this author hasn't cited any previous author's papers
--                 )
--             )
--             )
-- )
-- select least((select -1 where not exists (select * from simple_author_paths where authorid1 = 3552 and authorid2 = 321)),
-- (select count(author_path)
-- from path
-- where authorid1 = 3552 and authorid2 = 321
-- )) count
-- ;

--21--
-- select conferencename, count(component) count
-- from conference_connected_components
-- group by conferencename
-- order by count desc, conferencename
-- ;

--22--
-- select conferencename, array_length(component,1) count
-- from conference_connected_components
-- order by count, conferencename
-- ;

--CLEANUP--
drop view if exists authorpaper_edges cascade;
drop view if exists author_edges cascade;
drop view if exists paper_citations cascade;
drop view if exists authorconf_edges cascade;