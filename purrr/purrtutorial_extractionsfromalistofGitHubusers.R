#script title: Purrr Tutorial: Simplifying data from a list of GitHub users
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
library(listviewer)
library(jsonlite)
library(repurrrsive)
library(here)
library(magrittr)
theme_set(theme_bw(base_size=15))

#-----------------------------------
####Get Several GitHub users####
#-----------------------------------

str(gh_users, max.level = 1)
str(gh_users[[1]], list.len = 6)


#excercises####

#1) Read the documentation on str(). What does max.level control? Do 
#str(gh_users, max.level = i) for i in 0,1, and 2.

?str() 

#max level controls at what level the nested list is in.

i = 0
str(gh_users, max.level = i)

i = 1
str(gh_users, max.level = i)

i = 2
str(gh_users, max.level = i)

#2) What does the list.len argument of str() control? What is it’s default value?
#Call str() on gh_users and then on a single component of gh_users with list.len 
#set to a value much smaller than the default

# the number of list elements to display within a level

str(gh_users)
str(gh_users[[1]], list.len = 6)

#3) Call str() on gh_users, specifying both max.level and list.len.

str(gh_users, max.level = 2, list.len = 3)

#4) Recall the list and vector indexing techniques. Inspect elements 1, 2, 6, 18,
#21, and 24 of the list component for the 5th GitHub user. One of these should be
#the URL for the user’s profile on GitHub.com. Go there and compare info you see
#there with the info you just extracted from gh_users.

gh_users[[5]][1]
gh_users[[5]][2]
gh_users[[5]][6] #
gh_users[[5]][18]
gh_users[[5]][21]
gh_users[[5]][24]

#5) Consider the interactive view of gh_users here. Or, optionally, install the 
#listviewer package via install.packages("listviewer") and call jsonedit(gh_users) 
#to run this widget locally. Can you find the same info you extracted in the 
#previous exercise? The same info you see in user’s GitHub.com profile?

gh_users <- gh_users


#----------------------
####Name and position shortcuts
#------------------------

#purrr:map() general documentation is map(.x, .f, ...)

map(gh_users, "login")
map(gh_users, 18)

#pipe way
gh_users |> 
  map("login")

gh_users |> 
  map(18)

####Exercises ####

#1) Use names() to inspect the names of the list elements associated with a 
#single user. What is the index or position of the created_at element? Use the 
#character and position shortcuts to extract the created_at elements for 
#all 6 users.

names(gh_users[[2]])

#2) What happens if you use the character shortcut with a string that does 
#not appear in the lists’ names?

#get nulls 

#3) What happens if you use the position shortcut with a number greater than 
#the length of the lists?

#get nulls

#4) What if these shortcuts did not exist? Write a function that takes a list 
#and a string as input and returns the list element that bears the name in the
#string. Apply this to gh_users via map(). Do you get the same result as with 
#the shortcut? Reflect on code length and readability.

#i've already done it in the extracting list document. 

#5) Write another function that takes a list and an integer as input and returns
#the list element at that position. Apply this to gh_users via map(). How does 
#this result and process compare with the shortcut?

#done in the extracting list script


#--------------------
#### Type-specific map####
#--------------------

map_chr(gh_users, "login")
map_chr(gh_users, 18)

##review from purrr_tutorial extactin list with map so I won't do the excercises

#---------------------
####extract multiple values####
#---------------------

gh_users[[3]][c("name", "login", "id", "location")]

x <- map(gh_users, `[`, c("login", "name", "id", "location"))
str(x)

x <- map(gh_users, magrittr::extract, c("login", "name", "id", "location"))
str(x)

##review from purrr_tutorial extactin list with map so I won't do the excercises

#----------------------
#### Data frame output
#----------------------

map_dfr(gh_users, `[`, c("login", "name", "id", "location"))

tibble(
    login = map_chr(gh_users, "login"),
    name = map_chr(gh_users, "name"),
    id = map_int(gh_users, "id"),
    location = map_chr(gh_users, "location")
  )

##review from purrr_tutorial extactin list with map so I won't do the excercises

#--------------------------
####Repositories for each user####
#--------------------------

str(gh_repos, max.level = 1)

####Exercises####

#1) How many elements does gh_repos have? How many elements does each of those 
#elements have?

str(gh_repos, max.level = 0)
str(gh_repos, max.level = 1)
str(gh_repos, max.level = 2, list.len = 3)
str(gh_repos, max.level = 3, list.len = 3)

#6 elements, all but the 4th have 30 and the 4th only has 26

#2) Extract a list with all the info for one repo for one user. Use str() on it.
#Maybe print the whole thing to screen. How many elements does this list have 
#and what are their names? Do the same for at least one other repo from a different
#user and get an rough sense for whether these repo-specific lists tend to 
#look similar.

str(gh_repos[[1]], list.len = 6)
str(gh_repos[[3]], list.len = 68)

#3) What are three pieces of repo information that strike you as the most useful?
#I.e. if you were going to make a data frame of repositories, what might the 
#variables be?

# the names maybe the logical information the id and the owner, some of the interger
#data towards the end like size, forks, and watchers?

#----------------------------
#### Vector input to extraction shortcuts####
#----------------------------

#instead of using a single name or position in a list like this we use a vector
# the j'th element addresses the j'th level of the heirachy.
#e.g., 

#the following code doesn't give the elements 1 and 3, it will extract the first
#repro for each user and within that the 3rd peice of infomation
gh_repos |> map_chr(c(1,3)) 


##Exercises###

#1) Each repository carries information about its owner in a list. Use map_chr()
#and the position indexing shortcut with vector input to get an atomic character
#vector of the 6 GitHub usernames for our 6 users: “gaborcsardi”, “jennybc”, etc.
#You will need to use your list inspection skills to figure out where this
#info lives.
str(gh_repos[[1]], list.len = 6)
str(gh_repos[[2]], list.len = 6)

#i see that it is in the 4th element which is a list and within that element
#it is the first part
gh_repos |> map_chr(c(1,4,1)) 

#-----------------------------------
###lists inside a dataframe####
#-----------------------------------

#mission, get a data frame with one row per repository, with variables identifying
#which GitHub user owns it, the repository name, etc.

unames <- map_chr(gh_repos, c(1, 4, 1)) #get the usernames from the last excercise

#create a tibble with the usernames and the vector of lists as the other
udf <- gh_repos %>%
  set_names(unames) %>% 
  enframe("username", "gh_repos")

# now create some variables using map inside mutate

udf %>% 
  mutate(n_repos = map_int(gh_repos, length))


#now lets look at a single user to look at how far inside the nest of list
#we need to get to access the data we want 

one_user <- udf$gh_repos[[1]]
one_repo <- one_user[[1]]
str(one_repo, max.level = 1, list.len = 5)
map_df(one_user, `[`, c("name", "fork", "open_issues"))

#now scale it up to all of the users

udf %>% 
  mutate(repo_info = gh_repos %>%
           map(. %>% map_df(`[`, c("name", "fork", "open_issues"))))

#now that we have a the data frame we'd like, remove the list column and 
#unnest the rest

rdf <- udf %>% 
  mutate(
    repo_info = gh_repos %>%
      map(. %>% map_df(`[`, c("name", "fork", "open_issues")))
  ) %>% 
  select(-gh_repos) %>% 
  tidyr::unnest(repo_info)


#just some data wrangling to get the more interesting repos

rdf %>% 
  filter(!fork) %>% 
  select(-fork) %>% 
  group_by(username) %>%
  arrange(username, desc(open_issues)) %>%
  slice(1:3)
