# ------------------ #
# Scheduled tweeting #
# ------------------ #

library(tidyverse)
library(rtweet)

# Token -------------------------------------------------------------------
token <-
  create_token(
    app = "auto_tweet263",
    consumer_key = Sys.getenv("TW_API_KEY"),
    consumer_secret = Sys.getenv("TW_SECRET_KEY"),
    access_token = Sys.getenv("TW_ACCESS_TOKEN"),
    access_secret = Sys.getenv("TW_SECRET_TOKEN"),
    set_renv = FALSE
  )

# List of tweets ----------------------------------------------------------
# could also be an external file or a google sheets
# -> use a secret and googlesheets4::gs_deauth()
list_tweets <-
  tibble(
    tw_date = c(
      "2020-09-09",
      "2020-09-10",
      "2020-09-11",
      "2020-09-14",
      "2020-09-15"
    ),
    tw_text =  c("My tweet 1", "My tweet 2", "My tweet 3", "My tweet 4", "My tweet 5"),
    tw_media = c(NA, "media_link2", NA, NA, "media_link5")
  ) %>%
  mutate(tw_date = lubridate::as_date(tw_date))

# Filter the right tweet --------------------------------------------------
tw_to_tweet <- list_tweets %>%
  filter(tw_date == lubridate::today())

# Security part -----------------------------------------------------------
df_my_timeline <- get_my_timeline(token = token)

# compare to tw_to_tweet

# Tweet them --------------------------------------------------------------
# check if the media NA doesn't throw an error and write if/else in this case
# this part could be a purrr::map if you have multiples tweets to send
# Add a condition if you have no tweet to post !!
post_tweet(status = tw_to_tweet$tw_text,
           media = tw_to_tweet$tw_media,
           token = token)
