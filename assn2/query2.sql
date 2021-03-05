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


--12--
select a3.authorid, coalesce(length,-1) length from
(
select authorid2, min(array_length(author_path,1)-1) length
from simple_author_paths p
where p.authorid1 = 1235
group by authorid2
) temp
right join authordetails a3 on authorid2 = a3.authorid
where a3.authorid <> 1235
;

--14--
select coalesce((
select count(author_path) count
from simple_author_paths
where authorid1 = 704 and authorid2 = 102
    and exists(
        select * from
        (
            select distinct ap.authorid
            from paper_citations pp, authorpaperlist ap
            where ap.paperid = pp.paperid1
                and pp.paperid2 = 126 -- gives me all the authors who directly or indirectly cited this paper
        ) temp
        where temp.authorid = ANY(author_path[2:array_length(author_path,1)-1]) -- omit A and B
    )
having count(*) <> 0
), -1) count
;

--15--
select coalesce((
select count(author_path) from
(
(
with recursive path(authorid1, authorid2, author_path) as (
    select authorid1, authorid2, array[authorid1, authorid2] -- path grows to the right 
    from author_edges

    union

    select path.authorid1, ae.authorid2, author_path || ae.authorid2
    from path, author_edges ae, citations_per_author cpa1, citations_per_author cpa2
    where path.authorid2 = ae.authorid1 -- recursion link
        and (not ae.authorid2 = ANY(author_path)) -- simple path
        and cpa1.authorid = ae.authorid1 and cpa2.authorid = ae.authorid2
        and ((cpa1.total_citations < cpa2.total_citations) or (ae.authorid2 = 456))
)
select * 
from path
where authorid1 = 1745 and authorid2 = 456
)
union
(
with recursive path(authorid1, authorid2, author_path) as (
    select authorid1, authorid2, array[authorid1, authorid2] -- path grows to the right 
    from author_edges

    union

    select path.authorid1, ae.authorid2, author_path || ae.authorid2
    from path, author_edges ae, citations_per_author cpa1, citations_per_author cpa2
    where path.authorid2 = ae.authorid1 -- recursion link
        and (not ae.authorid2 = ANY(author_path)) -- simple path
        and cpa1.authorid = ae.authorid1 and cpa2.authorid = ae.authorid2
        and ((cpa1.total_citations > cpa2.total_citations) or (ae.authorid2 = 456))
)
select * 
from path
where authorid1 = 1745 and authorid2 = 456
)
) temp
having count(author_path) <> 0
), -1) as count
;

--16--
select author1 as authorid from
(
(select distinct a1.authorid author1, a2.authorid author2
from authorpaperlist a1, paper_citations, authorpaperlist a2
where a1.paperid = paperid1 and paperid2 = a2.paperid
    and a1.authorid <> a2.authorid
) -- author1 cited author2 
except
(select * from author_edges) -- author1 coauthored a paper with author2
) temp
group by author1
order by count(author2) desc, author1
;

--17--
select authora as authorid from -- number of third degree citations
(
(select distinct a.authorid authora, b.authorid authorb -- authora cited authorb
from authorpaperlist a, paper_citations pc, authorpaperlist b
where a.paperid = pc.paperid1 --author's paperid1 cited paperid2
    and pc.paperid2 = b.paperid
    and a.authorid <> b.authorid)
INTERSECT
(select authorid1, authorid2 -- authorid2 is 3-degree connection of authorid1
from simple_author_paths ap
group by authorid1, authorid2
having min(array_length(author_path,1)-1) = 3
order by authorid1, authorid2)
) temp
group by authora
order by count(authorb) desc, authora -- count number of third degree citations
limit 10
;

--18--
select coalesce((
select count(author_path)
from simple_author_paths
where 
    authorid1 = 3552 and authorid2 = 321
    and exists(
        select authorid 
        from authordetails
        where 
            authorid in (1436, 562, 921)
            and authorid = ANY(author_path)
    )
having count(author_path) <> 0
), -1) count
;

--19--
with recursive path(authorid1, authorid2, author_path, city_list, paper_list, cite_list) as (

        select distinct authorid1, authorid2, 
            array[authorid1, authorid2] author_path, 
            array[a1.city, a2.city] city_list,
            (select array(select distinct a from unnest( -- to remove duplicates
                array(select paperid from authorpaperlist ap where ap.authorid = authorid1) 
                    || array(select paperid from authorpaperlist ap where ap.authorid = authorid2)
            ) as a)) as paper_list,
            (select array(select distinct a from unnest( -- to remove duplicates
                array(select paperid2 from authorpaperlist ap, citationlist cl where authorid1 = ap.authorid and ap.paperid = cl.paperid1) 
                    || array(select paperid from authorpaperlist ap, citationlist cl where authorid2 = ap.authorid and ap.paperid = cl.paperid1)
            ) as a)) as cite_list

        from author_edges, authordetails a1, authordetails a2
            where authorid1 = a1.authorid and authorid2 = a2.authorid
        
        union

        select path.authorid1, ae.authorid2, 
            author_path || ae.authorid2,
            city_list || ad.city,
            (select array(select distinct a from unnest( -- to remove duplicates
                paper_list || array(select paperid from authorpaperlist ap where ap.authorid = ae.authorid2)
            ) as a)),
            (select array(select distinct a from unnest( -- to remove duplicates
                cite_list || array(select paperid2 from authorpaperlist ap, citationlist cl where ae.authorid2 = ap.authorid and ap.paperid = cl.paperid1)
            ) as a))

        from path, author_edges ae, authordetails ad
        where path.authorid2 = ae.authorid1 -- recursion link
            and (not ae.authorid2 = ANY(author_path)) -- simple path
            and ae.authorid2 = ad.authorid
            and 
            ((ae.authorid2 = 321) or -- exclude first and last guy
            (
                (not ad.city = ANY(city_list)) -- this author is not in the same city as any previous author
                and not exists(
                    select ap.paperid from authorpaperlist ap 
                    where ap.authorid = ae.authorid2
                        and (not ap.paperid = ANY(cite_list)) -- this author's papers haven't been cited by previous authors on the path
                )
                and not exists(
                    select cl.paperid2 from authorpaperlist ap, citationlist cl 
                    where ae.authorid2 = ap.authorid and ap.paperid = cl.paperid1
                        and (not cl.paperid2 = ANY(paper_list)) -- this author hasn't cited any previous author's papers
                )
            )
            )
)
select coalesce((
select count(author_path)
from path
where authorid1 = 3552 and authorid2 = 321
having count(author_path) <> 0
), -1) count
;

--CLEANUP--
drop view if exists authorpaper_edges cascade;
drop view if exists author_edges cascade;
-- drop view if exists simple_author_paths;
drop view if exists paper_citations cascade;
-- drop view if exists citations_per_author;