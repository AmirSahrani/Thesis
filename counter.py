from random import choice
from datetime import datetime
from playsound import playsound

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
    playsound('C:\\Users\\amisa\\Documents\\Python\\Thesis\\bell.wav')
    while True:
        while True:
            x = input(f"Last outcome for heads press: \"{inputheads}\" for tails press \"{inputtails}\": ")
            if x in [inputheads,inputtails]:
                inputs.append(x)
                counter += 1
                print(string.join(inputs))
                break
        if counter % 5 == 0:
            break
    f.write(f"{string.join(inputs)}\n")
    