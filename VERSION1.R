install.packages("tidyr")
install.packages("data.table")
library("httr")
library("jsonlite")
library("dplyr")
library("ggplot2")
library("data.table")
library("tidyr")
source("apikey.R")



this.address <- "Bellevue, WA"
base.uri <- "https://www.googleapis.com/civicinfo/v2/representatives"
query.params = list(address = this.address, key = google.key)
response <- GET(base.uri, query = query.params)
representatives <- fromJSON(content(response, "text"))
all.officals <- representatives$officials
data.officals <- data.frame(all.officals, stringsAsFactors = FALSE)
after.officals <- flatten(data.officals)
View(after.officals)

rep <- select(after.officals, name, party, emails, phones, urls, photoUrl)
rep <- mutate(rep, index = c(1:26))

office <- data.frame(representatives$offices, stringsAsFactors = FALSE)
office <- flatten(office) %>% select(name, officialIndices)
office <- mutate(office, newindex = c(1:25))

setnames(office, old = "name", new = "position")
info <- full_join(rep, office, c("index" = "newindex"))

summary <- info %>% mutate(Name = paste0("[", name,"]","(", urls, ")"),
                              Position = position,
                              Party = party,
                              Email = emails,
                              Phone = phones,
                              Photo = paste0("![]","(",photoUrl, ")","{width=250px}")
                              )

summary$Email[summary$Email == "NULL"] <- "-"
summary$Photo[summary$Photo == "![](NA){width=250px}"] <- ""
summary <- select(summary, Name, Position, Party,Email, Phone, Photo)
View(summary)


base.uri <- "https://api.propublica.org/congress/v1/members/house/WA/current.json"
response <- GET(base.uri, add_headers('X-API-Key' = propublic.key))
members <- fromJSON(content(response, "text"))

member.data <- flatten(data.frame(members$results))
member.data$gender[member.data$gender == "F"] <- "Female"
member.data$gender[member.data$gender == "M"] <- "Male"
member.data$party[member.data$party == "R"] <- "Republican"
member.data$party[member.data$party == "D"] <- "Democratic"
ggplot(data = member.data)+
  geom_bar(mapping = aes(x = gender), position = position_stack(reverse = TRUE)) +
  coord_flip() +
  labs(y = "# of Representatives") 

ggplot(data = member.data)+
geom_bar(mapping = aes(x = party), position = position_stack(reverse = TRUE), fill = c("blue","red")) +
  coord_flip() +
  labs(y = "# of Representatives") 

Republican <- length(member.party == "R")
Demoratic <- length(member.party == "D")

ggplot(member.party) + 
  geom_bar(mapping=aes(x = Republican))

base.uri <- "https://api.propublica.org/congress/v1/members/D000617.json"
response <- GET(base.uri, add_headers('X-API-Key' = propublic.key))
Susan.body <- fromJSON(content(response, "text"))
birth <- flatten(data.frame(Susan.body$results))
Susan.birth <- birth$date_of_birth


base.uri <- "https://api.propublica.org/congress/v1/members/D000617/votes.json"
response <- GET(base.uri, add_headers('X-API-Key' = propublic.key))
Susan <- fromJSON(content(response, "text"))
Susan.vote <- flatten(data.frame(Susan$results$votes))
total.yes <- Susan.vote$total.yes[1]
past.votes <- length(Susan.vote$total.no)
persons <- Susan.vote$total.no[1] + Susan.vote$total.yes[1] +Susan.vote$total.not_voting[1]
percent <- paste0(round(total.yes*100/persons, 0),"%" )



member.data$first_name[1]
member.data$last_name[1]
member.data$gender[1]
member.data$party[1]
member.data$twitter_id[1]







