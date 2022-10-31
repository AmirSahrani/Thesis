from os import write
from random import choice
from datetime import datetime
f = open("HeadsandTails.txt", "a")
now = datetime.now()
f.write(f"Date: {now}\n")
inputheads = input("Select the key you want to press for heads: ")
inputtails = input("Select the key you want to press for tails: ")
f.write(f"keys for heads is :{inputheads}, key for tails: {inputtails}\n")

counter = 0
string = ""
while True:
    inputs = []
    start = choice(["Heads","Tails"])
    print(f"!!!!!!!!!!!!!!!!!!!! Please start with {start} facing up !!!!!!!!!!!!!!!!")
    while True:
        while True:
            x = input(f"Last outcome for heads press: \"{inputheads}\" for tails press \"{inputtails}\": ")
            if x in [inputheads,inputtails]:
                inputs.append(x)
                counter += 1
                print(string.join(inputs))
                break
        if counter % 10 == 0:
            break
    f.write(f"{string.join(inputs)}\n")
    