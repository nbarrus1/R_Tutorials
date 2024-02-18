#script title: Purrr Tutorial: Introduction to map(): extract elements
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

#old.packages()

#update.packages()

#----------------------------
####load packages####
#----------------------------

library(tidyverse)
library(purrr)
library(repurrrsive)
library(here)
library(magrittr)
theme_set(theme_bw(base_size=15))

#----------------------
###vectorized and "list-ized" opertations
#--------------------

#many operations have already been vectorized e.g.)

(3:5) ^ 2
sqrt(c(9, 16, 25))


#purrr:map is a function for applying functions to each elments of a list
#square root example

map(c(9, 16, 25), sqrt)


#basic map() template is : map(your_list, your_fxn)

#-----------------------------
###Name and position shortcuts
#-----------------------------

#a purrr feature is that it can create a shortcut to a function to extract elements
#e.g.)

map(got_chars, "name")

#can be done with positions
#e.g.0

map(got_chars,3)

#can be done through pipes
#formate:: mylist |> map(my_fxn)
#e.g.)

got_chars |> map("name")
got_chars |> map(3)


#excercises

#1) Use names() to inspect the names of the list elements associated with a 
#single character. What is the index or position of the playedBy element? Use the
#character and position shortcuts to extract the playedBy elements for all 
#characters.

names(got_chars[[1]]) #this will give the names within the first index of sublist

#the index or position of the "playedBy" element is 18

got_chars |> map("playedBy")
got_chars |> map(18)

#2)What happens if you use the character shortcut with a string that does not 
#appear in the lists’ names?

got_chars |> map("not_in_list")

#gives NULLS for every index of sublists

#3)What happens if you use the position shortcut with a number greater than the
#length of the lists?

got_chars |> map(19)

#gives NULLS for every index of sublists

#4)What if these shortcuts did not exist? Write a function that takes a list and
#a string as input and returns the list element that bears the name in the string.
#Apply this to got_chars via map(). Do you get the same result as with the 
#shortcut? Reflect on code length and readability


ext.characters <- function(my.list, my.string = "name") {
  for (i in 1:length(my.list)) {
    temp <- my.list[[i]][my.string]
    print(temp)
  }
}

got_chars |> map("name")
ext.characters(got_chars, my.string = "name")

#5) write another function that takes a list and an integer as input and returns 
#the list element at that position. Apply this to got_chars via map(). How does 
#this result and process compare with the shortcut?

ext.int <- function(my.list, my.int = 3) {
  for (i in 1:length(my.list)) {
    temp <- my.list[[i]][my.int]
    print(temp)
  }
}

ext.int(got_chars,my.int = 3)
got_chars |> map(3)


##--------------------------------------
###Type specific map()
##--------------------------------------

#map will always return a list so there are specific maps for each type of
#atomic vector e.g., character strings, intergers, numbers, etc.

map_chr(got_chars, "name")
map_chr(got_chars, 3)

####exercises####

#1) For each character, the second element is named “id”. This is the character’s 
#id in the API Of Ice And Fire. Use a type-specific form of map() and an extraction 
#shortcut to extract these ids into an integer vector.

str(got_chars, list.len = 3)

map_int(got_chars,"id")

#2) Use your list inspection strategies to find the list element that is logical.
#There is one! Use a type-specific form of map() and an extraction shortcut to 
#extract these values for all characters into a logical vector.

str(got_chars[1])

map_lgl(got_chars,"alive")

#---------------------------------------
###extract multiple values####
#---------------------------------------

#single version

got_chars[[3]][c("name", "culture", "gender", "born")]

###recall map usage is map(.x, .f, ...)
#you can use "[" as a function

x <- map(got_chars, `[`, c("name", "culture", "gender", "born"))
x

#or use magrittr::extract

x <- map(got_chars, extract, c("name", "culture", "gender", "born"))
x

#exercise####

#1) Use your list inspection skills to determine the position of the elements named 
#“name”, “gender”, “culture”, “born”, and “died”. Map [ or magrittr::extract() 
#over users, requesting these elements by position instead of name

names(got_chars[[1]])

x

x<-map(got_chars,extract,c(3:5,8))

x

#----------------------------
####extracting to data frame####
#----------------------------

#rather than getting a new list, since everything has 1 value it would be awesone
#to put everything into a data frame

map_dfr(got_chars, extract, c("name", "culture", "gender", "id", "born", "alive"))

#looks good but it is safer to specify each to make sure the variable sturcture are correct

tibble(
    name = map_chr(got_chars, "name"),
    culture = map_chr(got_chars, "culture"),
    gender = map_chr(got_chars, "gender"),       
    id = map_int(got_chars, "id"),
    born = map_chr(got_chars, "born"),
    alive = map_lgl(got_chars, "alive")
  )

#####exercises#####

#1) Use map_dfr() to create the same data frame as above, but indexing with a 
#vector of positive integers instead of names.

map_dfr(got_chars, extract, c(2:6,8))

tibble(
  name = map_chr(got_chars, 3),
  culture = map_chr(got_chars, 4),
  gender = map_chr(got_chars, 5),       
  id = map_int(got_chars, 2),
  born = map_chr(got_chars, 6),
  alive = map_lgl(got_chars, 8)
)
        