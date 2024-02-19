#script title: Purrr Tutorial: Specifying the function in map()+parallel mapping
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
theme_set(theme_bw(base_size=15))


#---------------------
####map() overview####
#---------------------

#r3call the genral usage
#map(.x, .f, ...)
#map(VECTOR_OR_LIST_INPUT, FUNCTION_TO_APPLY, OPTIONAL_OTHER_STUFF)

#------------------
###map() function specification
#-----------------

#three ways to specify a general .f
##1) an existing function
##2) an anonymous function, defined on-the-fly, as usual
##3) a formula: this is unique to purr and provides a very concise way to define
##             an anonymous function


#extract a set of carachters from the GOT_chars list for the demo

aliases <- set_names(map(got_chars, "aliases"), map_chr(got_chars, "name"))
aliases <- aliases[c("Theon Greyjoy", "Asha Greyjoy", "Brienne of Tarth")]


#---------------------------
####using and existing function####
#---------------------------

my_fun <- function(x) paste(x, collapse = " | ")
map(aliases, my_fun)

#---------------------------
####Anonymous function, conventional####
#---------------------------

map(aliases, function(x) paste(x, collapse = " | ")) 


#or you can specify the function directly and use ... to provide the collapse 
#argument for the paste f(x)n

map(aliases, paste, collapse = " | ")


#------------------
###work flow advice####
#------------------

#hard to write it perfect all the time to begin with, so pull out a single
#element then get the logic down on that element, finally scale back up by using
#those formats

a <- map(got_chars, "aliases")[[19]]  #problem not what we want
a
a <- map(got_chars, "aliases")[[16]] #good
a
paste(a, sep = " | ")  #not what we want

paste(a, collapse = " | ")  #good

got_chars[15:17] %>%                   
  map("aliases") %>% 
  map_chr(paste, collapse = " | ")#awesome just what we wanted!


#----------------------
###list to data frame####
#----------------------

##enframe will create a tibble to save the aleases under the specified names

aliases <- set_names(map(got_chars, "aliases"), map_chr(got_chars, "name"))
map_chr(aliases[c(3, 10, 20, 24)], ~ paste(.x, collapse = " | ")) %>% 
  tibble::enframe(value = "aliases")

##alternative way without enframe

tibble::tibble(
  name = map_chr(got_chars, "name"),
  aliases = got_chars %>% 
    map("aliases") %>% 
    map_chr(~ paste(.x, collapse = " | "))
) %>% 
  dplyr::slice(c(3, 10, 20, 24))

#---------------------
###Recap####
#---------------------

#three different ways to specify the .f in the map

map(aliases, function(x) paste(x, collapse = "|")) 
map(aliases, paste, collapse = "|")
map(aliases, ~ paste(.x, collapse = " | "))

#exercises

#1) Create a list allegiances that holds the characters’ house affiliations.

str(got_chars[[1]])
allegiance <- map(got_chars, "allegiances")

#2) Create a character vector nms that holds the characters’ names.

nms <- map_chr(got_chars, "name")

#3) Apply the names in nms to the allegiances list via set_names.

allegiance <- set_names(allegiance,nms)


#4) Re-use the code from above to collapse each character’s vector of 
#llegiances down to a string.
map(allegiance,paste, collapse = "|")

#5) We said that any elements passed via ... would be used “as is”. Specifically
#they are not used in a vectorized fashion. What happens if you pass 
#collapse = c(" | ", " * ")? Why is that?

map(allegiance,paste, collapse = c(" | ", " * "))
#probably because the its itterating and won't beacle to do the two collapse at one itteration


##--------------
####parrallel map###
##-------------

#map2 general format
###map2(.x, .y, .f, ...)
###map2(INPUT_ONE, INPUT_TWO, FUNCTION_TO_APPLY, OPTIONAL_OTHER_STUFF)

##names and births for demo

nms <- got_chars %>% 
  map_chr("name")
birth <- got_chars %>% 
  map_chr("born")

#set up function to combine the names and biths

my_fun <- function(x, y) paste(x, "was born", y)

#itterate it out using map2
map2_chr(nms, birth, my_fun) %>% head()

#to do it within the map
map2_chr(nms[16:18], birth[16:18], ~ paste(.x, "was born", .y)) %>% tail()

####---------------
###pmap
####---------------


##general syntax

#pmap(.l, .f, ...)
#map(LIST_OF_INPUT_LISTS, FUNCTION_TO_APPLY, OPTIONAL_OTHER_STUFF)


#demo of pmap()

df <- got_chars %>% {
  tibble::tibble(
    name = map_chr(., "name"),
    aliases = map(., "aliases"),
    allegiances = map(., "allegiances")
  )
}

my_fun <- function(name, aliases, allegiances) {
  paste(name, "has", length(aliases), "aliases and",
        length(allegiances), "allegiances")}
  

df %>% 
  pmap_chr(my_fun) %>% 
  tail()
