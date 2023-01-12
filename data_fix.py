import re
import os
import pandas as pd
# ''' Extraction for AS'''
cwd = os.getcwd()
df = pd.DataFrame(data=[],columns=["Start","Trail"])

directory= 'C:\\Users\\amisa\\Documents\\Python\\Thesis\\Mess'
os.chdir(directory)
directory_list = os.listdir(directory)
txt_list = [x for x in directory_list if x[0:2] == "AS"]
counter = 0
# j = "AS_8400.txt"
for j in txt_list:
    with open(f"{j}") as f:
        text = f.read()
        text = re.split("!!!!!!!!!!!!!!!!!!!! Please start with ", text)
    for i in text:
        start = i[0:5]
        find_trail = re.findall("For heads press: \"k\" for tails press \"s\": [s|k]\n\w+\nCurrent number of entries is",i)
        for u in find_trail:
            trail = u.split("\n")[1]
            df.loc[len(df)] = [start,trail]

df["Coin"] = "Peso"
df = df.drop_duplicates().reset_index()[["Start","Coin","Trail"]]
df.to_csv("AS_Data_check.csv",index= False)


#''' Extraction for Madlen '''
# directory= 'C:\\Users\\amisa\\Documents\\Python\\Thesis\\Mess'
# os.chdir(directory)
# directory_list = os.listdir(directory)
# txt_list = [x for x in directory_list if x[0:5] == "saved"]
# counter = 0
# print(txt_list)
# for j in txt_list:
#     # print(j)
#     with open(f"{j}") as f:
#         text = f.read()
#         text = re.split("!!!!!!!!!!!!!!!!!!!! Please start with ", text)
#     for i in text:
#         # print(i)
#         start = i[0:5]
#         find_trail = re.findall("For heads press: \"x\" for tails press \"m\": >\? [x|m]\n\w+\nCurrent number of entries is",i)
#         for u in find_trail:
#             trail = u.split("\n")[1]
#             df.loc[len(df)] = [start,trail]

# df["Coin"] = "50 cents (Euro)"
# df = df.drop_duplicates().reset_index()[["Start","Coin","Trail"]]
# df.to_csv("Mad_data.csv",index=False)




            