Programming is not as difficult as you might think. Basically, almost every programme consists of three steps.
## 1. value assignment
```
x <- 1
#or 
x = 1
```
## 2. if ... then ... else
```
if (x>0) {
print("x is positiv")
}
```
whith else we can build more "complex" cases...
```
if (x>0) {
  print("x is positiv")
}else{
  print("x is zero or negativ")
}
```
## 3. the loop
```
my_list <- c(-2,5,-3,9,1)
count <- 0
for (my_number in my_list) {
  if(my_number > 0){
    count = count+1
  }
}
print(count)
```

Even the most complicated AI is based on these steps. Fortunately, there are software packages that create useful functions and analyses for us.
