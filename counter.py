from random import choice

inputheads = input("Select the key you want to press for heads: ")
inputtails = input("Select the key you want to press for tails: ")
counter = 1
inputs = []
string = ""
while True:
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