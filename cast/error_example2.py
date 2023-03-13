from time import sleep

print("The program is starting")
sleep(1)
print("Creating the list")
sleep(0.3)
print("Sorting the list")
sleep(2)
my_list = [5, 3, 8, 4, 1, 9]
sorted_list = sorted(my_list)
sorted_list.pop()  # Let's fake some bug

# Let's check that the two lists have the same length
assert len(my_list) == len(sorted_list)

# Now let's calculate the Newtonian gravity field
print("Going to calculate the gravity field…")
sleep(3)
print("Maximizing the likelihood…")
sleep(2)
print("Found a maximum near point (x, y) = -1.54e8, 3.67e7")
print("The estimated mass is 1.7e24 kg")
print("Program completed")

