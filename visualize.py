import pandas as pd
import matplotlib.pyplot as plt
from scipy import stats
from numpy import mean
def count(x):
    count = 0
    for i in x:
        if i == "t":
            count += 1
    return count

def create_data(data):
    theoretical = [sum(stats.bernoulli.rvs(mean(data)/100, size = 100)) for x in range(0,1500)]
    return theoretical

def plotting(persons,df):
    persons = df["person"].unique()
    plt.figure(figsize=(20,10))
    for j,i in enumerate(persons, start = 1):
        plot_counts = df.loc[df["person"] == i]["counts"].loc[df["counts"] > 0]
        theoretical = create_data(plot_counts)
        plt.subplot(3,2,j)
        plt.hist(theoretical, bins = 100, color="red", alpha=0.5, label = "theoretical")
        plt.title(i)
        plt.xlim((0,100))
        # plt.xlabel("Number of Heads")
        plt.hist(plot_counts, bins = 100, color="blue", alpha=0.5, label = "Experimental")
    plt.show()

def main(file):
    f = pd.read_csv(file, header=0)
    df = pd.DataFrame(f)
    df["counts"] = [count(x) if len(x) > 1 else 0 for x in df["sequence"]]
    plotting(df["person"].unique(),df)
    
main("C:\\Users\\amisa\\Downloads\\merged-bachelor-2.csv")