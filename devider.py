from random import randint
import pandas as pd
def main(file):
    f = pd.read_csv(file, header=0)
    df = pd.DataFrame(f)

    seq = []
    for j in df["person"].unique():
        index = randint(0,len(df.loc[df["person"] == j]))
        if j == "davidV": #davidV's data was differently formatted
            index = randint(0,150)
        print(f"{j} {index}")


print("bachelor")
main("C:\\Users\\amisa\\Downloads\\merged-bachelor-3(1).csv")
print("marathon")
main("C:\\Users\\amisa\\Downloads\\merged-marathon-2.csv")