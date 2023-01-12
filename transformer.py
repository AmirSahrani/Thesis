import pandas as pd
from numpy import mean

f = pd.read_csv('C:\\Users\\amisa\\Downloads\\merged-marathon-2.csv', header = 0)
df = pd.DataFrame(f)

df["start"] = df["start"].str[0]
df["start"] = df["start"].str.lower()
df["trail_appended"] = df['start'] + df['sequence']
df["No_mistakes"] = df["trail_appended"].str.replace("x", "")
df["ratio"] = df["trail_appended"].str.count("h") / df["No_mistakes"].str.len()
print(df["ratio"].mean())

last = ""
all_decoded = []
all_coin = []
mistakes = 0
for _,j in df.iterrows():
    decoded = []
    for i in j['trail_appended']:
        if i == "x":
            mistakes += 1
        elif i == last:
            decoded.append(1)
            last = i
        else:
            decoded.append(0)
            last = i
    coin = j['coin']
    all_decoded = all_decoded + decoded[1:]

print(len(all_decoded), mistakes)
print(mean(all_decoded))
