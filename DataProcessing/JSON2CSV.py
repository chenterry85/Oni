import json
import csv

with open('US-all-data.json') as json_file:
    data = json.load(json_file)

filtered_data = []

for record in data:
    if record["type"] == "EQS" or record["type"] == "ETF" or record["type"] == "DR" or record["type"] == "SP" or record["type"] == "STP" or record["type"] == "TRT" or record["type"] == "UNT":
       filtered_data.append(record)

with open('US-all-data.csv', 'w') as csv_file:
    csv_write = csv.writer(csv_file)
    count = 0

    for item in filtered_data:
        if count == 0:
            header = item.keys()
            csv_write.writerow(header)
            count += 1

        csv_write.writerow(item.values())
