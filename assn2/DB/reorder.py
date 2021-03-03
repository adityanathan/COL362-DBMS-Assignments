import csv

with open('flights.csv', 'r') as infile, open('flights_reordered.csv', 'w') as outfile:
    # output dict needs a list for new column ordering
    fieldnames = ['originairportid', 'destairportid', 'carrier', 'dayofmonth', 'dayofweek', 'departuredelay', 'arrivaldelay']
    writer = csv.DictWriter(outfile, fieldnames=fieldnames)
    # reorder the header first
    writer.writeheader()
    for row in csv.DictReader(infile):
        # writes the reordered rows to the new file
        writer.writerow(row)