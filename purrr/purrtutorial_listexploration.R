##script title: Purrr Tutorial: Explore the example lists: Wes Anderson, Game of Thounes,
#Github
#First created: 2/18/2024
#purpose: the prupose of this scripts is to work through the purrr tutorials
# inorder to get have purrr functional coding as a tool for iteration.  functional
# coding is quicker than for loops and I've seen its use when coding a large list
#of models using the same structure.


#----------------------------
##general start to scripting##
#----------------------------

rm(list = ls())

######github#####
#note, only needed after 90 days from 1/16/2024

#  usethis::create_github_token()  
#  gitcreds::gitcreds_set()

#####check for r updates#####
#note, updateing may take some time so plan accordingly

#require(installr)

#check.for.updates.R()

#updateR() #only if needed

#######check for package updates#####
#note, updateing may take some time so plan accordingly

old.packages()

update.packages()

#----------------------------
####load packages####
#----------------------------

library(tidyverse)
library(purrr)
library(repurrrsive)
library(here)
theme_set(theme_bw(base_size=15))

###--------------------
###List inspections####
###--------------------


####indexing review####

#there are three ways to pull elements out of a list:

#way one) the "$" opperator

x <- list(a = "a", b = c(2,1))

x$a
x$b

#way 2) double squqre brackets "[[]]" extracts a single element by name or position
#name must be quoted if acharacter is provided directly

x[[1]]  #position 1
x[[2]]  #position 2

x[["a"]] #name directly

nm <- "a"

x[[nm]]

i <- 2

x[[i]]

#way 3) single brackets "[]", like regular indexing, but a list is always returned

x["a"]
x[c("a","b")]
x[c(FALSE,TRUE)]


####str()####

#str() can help with basic list inspection though it can be frustrating in that it
#will show every level of every element in a list, max.level and list.len arguments
#can limit the amount of information and make it a little easier to processs things in 
# a list

got_chars <- got_chars
gh_users <- gh_users

str(got_chars,list.len = 3)
str(gh_users, max.level = 1)


####---------------------------------------
###Exercises ####
##-----------------------------------------

#Exercise 1) Read the documentation on str(). What does max.level control? Apply
#str() to wesanderson and/or got_chars and experiment with max.level = 0, 
#max.level = 1, and max.level = 2. Which will you use in practice with deeply 
#nested lists?

?str()

#max level controls the levels of a nested structure that you can see,
#e.g. a list containing sublists

str(got_chars, max.level = 0)
str(got_chars, max.level = 1)
str(got_chars, max.level = 2)

#max.level 0 would show nothing, the max.level = 1 would show the broadest nest of 
#list, max.level = 2 will show you the second level of the list nest. I think I'd use
#1 or 2, but I think 2 would need to be limited by list.len

#Exercise 2) What does the list.len argument of str() control? What is its default
#value? Call str() on got_chars and then on a single component of got_chars with 
#list.len set to a value much smaller than the default. What range of values do 
#you think you’ll use in real life?

?str() #i see that you can pick a specific level with nest.level

#list.len sets the maximum number of list element to display within a level it,
#e.g., if set to 3 it will give 3 of the group of lists and three of the elements within
#the list

str(got_chars, list.len = 3)
str(got_chars[2], list.len = 3)

# the range of vlaues i'd likely use would be 3-6

#Exercise 3, Call str() on got_chars, specifying both max.level and list.len.

str(got_chars, max.level = 2, list.len = 3)
str(got_chars, max.level = 1, list.len = 6)

#Exercise 4, Call str() on the first element of got_chars, i.e. the first Game 
#of Thrones character. Use what you’ve learned to pick an appropriate combination
#of max.level and list.len.

str(got_chars, max.level = 2, list.len = 5) 

