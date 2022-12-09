# pip install playsound==1.2.2      You need this specific version of the package for it to work, I don't think this works with anaconda install
from random import choice
from datetime import datetime
from playsound import playsound



counter = 0
string = ""

f = open("HeadsandTails.txt", "a")
x = open("HeadsandTails.txt")
Ncoins = len(list(x))
x.close()
print(f"Current number of entries is: {Ncoins*100}")
# f.write(f"Date: {now}\n")
coin = input("Which coin are you using?")
inputheads  = input("Select the key you want to press for heads: ")
inputtails  = input("Select the key you want to press for tails: ")
failedheads = input("Select the key you want to press for a failed attempt: ")
undo        = input("Select the key you want to use for undoing you previous input: ")
change_coin = input("Select the key you want to use to change the coin: ")


dict = {inputheads: "h", inputtails: "t", failedheads : "x"}

while True:
    inputs = []
    start = choice(["Heads","Tails"])
    print(f"!!!!!!!!!!!!!!!!!!!! Please start with {start} facing up !!!!!!!!!!!!!!!!")
    playsound("bell.wav")
    while True:
        while True:
            x = input(f"Last outcome for heads press: \"{inputheads}\" for tails press \"{inputtails}\": ")
            if x == change_coin:
                coin = input("Which coin are you using?")
                break
            if x in [inputheads,inputtails]:
                inputs.append(dict[x])
                counter += 1
                print(string.join(inputs))
            elif x in [failedheads]:
                inputs.append(dict[x])
                print(string.join(inputs))
                continue
            elif x == undo and inputs != []:
                inputs.pop()
                counter = counter -1
                print(string.join(inputs))
                continue
            break
        if counter % 100 == 0:
            break
    if inputs != []:
        now = datetime.now()
        now = now.strftime("%Y-%m-%d %H:%M:%S")
        f.write(f"{now},{coin},{start},{string.join(inputs)}\n")
        Ncoins += 1
        print(f"Current number of entries is: {Ncoins*100}")
            

## You can always press ctrl + c in the terminal to terminate the process, doing so in the middle of a block will discard that specific block, 
# if you want to save it you can manually copy it from the terminal and paste it in the .txt file