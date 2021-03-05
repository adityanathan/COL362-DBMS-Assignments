# Flights

## Creation
- Are there any foreign keys in the database?
- integer = bigint?

## Queries
- For albuquerque, use id or join with airports and use name?

- 5,6
  - Is the length = no. of cities or no.edges = no. of cities - 1?
  - For 4, does albuquerque necessarily have to be at the start and end or can it just be in the middle? I don't see causing a change in ans though.

- When we are asked to do comething with Alb, do we use the city name or the airport id?

- union vs unionall. I'm using union because paths are anyways distinct. I'm hoping this is fine?

- Can we use the given city names as strings?

- q3 = if there are two same paths from city A to city B but to different airports in city B, should I count it twice or once?

- When can c1 = c2 be true when output is (c1,c2)? Eg. 9, 11, etc.

# Author

- self loops in author_edges or authorpaper_edges allowed?
- discard paper information when looking at edges?
  - authorpaper_edges or author_edges

- 13 = should 1235 be in the authorid column?
- 14 = could person have authored paper?

- In Q17, should the third degree authors have cited author A or author A have cited the third degree authors?

- 18 and others = If two authors are in the same component but none of the paths between them satisfy some condition and as a result there are 0 paths then should count return 0 or -1?