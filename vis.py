import pandas as pd
import matplotlib.pyplot as plt

f = pd.read_csv('HeadsandTails.txt', names = ["date","coin", "start", "trail"])
df = pd.DataFrame(f)
length = []
newdf = pd.DataFrame()
for i in df.iterrows():
    print(i[-1]["trail"])
    length.append(len(i[-1]["trail"]))

df["length"] = length
print(newdf)
print(length)
plt.bar(df["date"],length)
plt.ylim(80,140)
plt.show()