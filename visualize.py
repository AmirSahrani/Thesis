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

def expected_data(data, number_of_tosses):
    n = 100
    p = mean(data)/n
    theoretical = [stats.binom.pmf(r, n, p) for r in range(0,100)]
    theoretical = [x*number_of_tosses for x in theoretical]
    return theoretical
def succes_decoder(sequence, start):
    succes = []
    for index,letter in enumerate(sequence):
        if index == 0:
            if letter == start:
                succes.append(1)
            else:
                succes.append(0)
        else:
            if letter == last:
                succes.append(1)
            else:
                succes.append(0)
        last = letter
    return succes
    
def plotting(persons,df):
    persons = df["person"].unique()
    plt.figure(figsize=(12,18))
    for j,i in enumerate(persons, start = 1):
        plot_counts = df.loc[df["person"] == i]["counts"].loc[df["counts"] > 1]
        number_of_tosses = len(plot_counts)
        theoretical = expected_data(plot_counts,number_of_tosses)
        # plt.subplot(7,2,j)
        plt.bar(range(0,100), theoretical, color="black", alpha=0.2, label = "Expected")
        plt.suptitle("Distribution of expected and oberserved Successes for each Tosser")
        # plt.tight_layout()
        plt.title(f"Tosser: {j}")
        plt.xlim((0,100))
        plt.ylim((0,len(plot_counts)/4))
        plt.hist(plot_counts, bins = 100, color="black", alpha=0.9, label = "Observed")
        plt.xlabel("Number of Successes")
        # if j == 2:
        plt.legend()        
    plt.show()

def main(file):
    f = pd.read_csv(file, header=0)
    # f2 = pd.read_csv(file2, header=0)
    # df = pd.concat([f,f2]).reset_index()
    df = pd.DataFrame(f)
    df["counts"] = [sum(succes_decoder(x['sequence'], x['start'])) for _,x in df.iterrows()]
    print(df['counts'].mean())
    plotting(df["person"].unique(),df)

# main('bachelor_data.csv', 'marathon_data.csv')
main("C:\\Users\\amisa\\Downloads\\TP.csv")