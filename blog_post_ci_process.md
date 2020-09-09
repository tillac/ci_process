# Run processes with CI tools

## CI to rule them all

With R, I often design and build dashboard, with `{flexdashboard}` or HTML outputs using `{rmarkdown}`. I also try to sometimes get data from Twitter with `{rtweet}`. Or to build tutorials or documentation with `{bookdown}` and `{pkgdown}`. I also create packages that need some checks. And I send mails to my clients with the content of their analysis (with `blastula` or `{gmailr}`).

All of that is really powerful and to me, it's modern data science. As you can see, I prefer static and lightweight HTML outputs rather than `{shiny}` apps. I found them better when you deal with "small" subjects and just need to show some insights with a regular update.

Here comes the problems : how to update my dashboard ? How to get my analysis updated without to re-run the code ? I don't have my own server (maybe in the future) and don't want it now. And to make one just to update a few dashboard and some analysis seems overkill to me.

So here comes also the solution : Continuous Integration, a.k.a CI. This tool allows you to build and check things when you push it to your versioning system. As an example, it's really useful to auto check your R packages. You can also use them to build your `{bookdown}` every time you push a change to Github (and not having to knit it by hand). Here you can use Github Actions (a.k.a GHA), which comes with Github and is really powerful. Other tools exists (Travis CI, Jenkins, Gitlab CI-CD) and could fit the same needs. 
This part of using Github Actions to build and check packages or documentation is kind of "classical". It has been really well integrated by Jim Hester and others in the `{usethis}` package with the `use_github_actions()` instruction. You can learn more about it [here](https://www.jimhester.com/talk/2020-rsc-github-actions/).

## CI to update your analysis

I also use CI for its ability to update my analysis. Because CI can use scheduled CRON processes, we can use it to re-run analysis and update them. How does this work ?

Since we don't want to check the results on multiples systems but just ensure it to run, I use Docker images to build the results. The R-specific [Rocker](https://www.rocker-project.org/) images are really useful here.

### Update a dashboard

As an example, I wrote a little dashboard who use the `{quantmod}` package to extract some CAC40 data, the French stock market, and display them. You can check the code of the dashboard [here](https://github.com/tillac/ci_process/blob/master/dashboard/cac40_dashboard.Rmd).

What is interesting with this dashboard is that it's built on top of moving data, since they need to be updated regularly (each day of each week) to make sense. Here the update comes from a package which pull the data from Yahoo. But it could also be linked to a database, a Google Sheets or from scraping a web page.

Let's analyse my [workflow](https://github.com/tillac/ci_process/blob/master/.github/workflows/render-dashboard.yaml) !

+ As you can notice, the workflow runs on push and on CRON (once every day). If needed for CRON, use [crontab guru](https://crontab.guru/). The push runs is useful when you want to update it by hand or push changes.

+ I initialize it by calling a Rocker container, `verse`. This one is really useful when you want to knit things with `{rmarkdown}` since everything needed is already installed. 

```
on:
  push:
    branches: master
  schedule:
    - cron: '0 12 * * *'

name: Render dashboard

jobs:
  dashboard:
    runs-on: ubuntu-latest
    container: rocker/verse
    env:
      GITHUB_PAT: ${{ secrets.GITHUB_TOKEN }}
      
    steps:
      - uses: actions/checkout@v2

```

+ Since I didn't make it in a package, I had to do some changes to install dependecies (I list them by hand). If your dashboard is in a package (and it should be), just rely on `remotes::dev_package_deps(dependencies = TRUE)`.

```
      - name: Install dependencies
        run: |
          install.packages("flexdashboard")
          install.packages("lubridate")
          install.packages("sparkline")
          install.packages("reactable")
          install.packages("quantmod")
        shell: Rscript {0}
```

+ I just render the dashboard after

```
      - name: Render Dashboard
        run: |
          rmarkdown::render(input = "dashboard/cac40_dashboard.Rmd")        
        shell: Rscript {0}
```

+ And I push it to a new branch, called "gh-pages". I have to configure Github Pages on it after to get the HTML file as [here](https://tillac.github.io/ci_process/dashboard/cac40_dashboard.html). This git workflow is inspired by `pkgdown::deploy_to_branch`.

```
      - name: Deploy results to branch
        run: |
          git config --local user.email "actions@github.com"
          git config --local user.name "GitHub Actions"
          git checkout --orphan gh-pages
          git rm -rf --quiet .
          git commit --allow-empty -m "Initializing branch"
          git push origin HEAD:gh-pages --force
```

### Scheduled your tweets

You can also use Github Actions to post scheduled tweets. This helps you to prepare them all in once and just forget about them after. An example of it is David Keyes' [R for the Rest of Us repo](https://github.com/rfortherestofus/rrutweets).

+ First you need a developper account and a to create an app. Follow `{rtweet}` [tutorial](https://docs.ropensci.org/rtweet/articles/auth.html) for this step.

+ Keep in mind that you need to allow your app to have write access rights. **You need to set the rights first and to generate the token after**. [Add the secrets to Github](). **AJOUTER LE LIEN**

```
token <-
  create_token(
    app = "auto_tweet263",
    consumer_key = Sys.getenv("TW_API_KEY"),
    consumer_secret = Sys.getenv("TW_SECRET_KEY"),
    access_token = Sys.getenv("TW_ACCESS_TOKEN"),
    access_secret = Sys.getenv("TW_SECRET_TOKEN"),
    set_renv = FALSE
  )
```

+ You will also need a list of tweet you plan to post. Either as a plain file like csv or in a Google Sheets. Be sure you have a date and a text columns, to know when and what to post. You can also add some media if needed.

+ I wrote a little R script to take a tweet from this list, based on the current day as a filter. And I use `rtweet::post_tweet` to post it. I also added a security to check if tweet hasn't been post before on the same day.

**MAJ APRES FINAL**

```
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

# Tweet them --------------------------------------------------------------
# check if the media NA doesn't throw an error and write if/else in this case
# this part could be a purrr::map if you have multiples tweets to send
post_tweet(status = tw_to_tweet$tw_text,
           media = tw_to_tweet$tw_media,
           token = token)
```

+ And a Github Actions workflow to run it each day. If you have no tweet to post, it just runs. Otherwise, it posts your tweet to Twitter. What you have to check here is the hour. Github Actions runs on GMT-0, so adjust the time of the CRON command to your needs. After you check everything is fine, just remove the push on master lines.

```
on:
  push:
    branches: master
  schedule:
    - cron: '0 12 * * *'

jobs:
  collect:
    name: Post tweets
    runs-on: ubuntu-18.04
    container: rocker/verse:3.6.3
```

+ I add the secrets to the global env so R can call them.

```
    env:
      TW_API_KEY: ${{ secrets.TW_API_KEY }}
      TW_SECRET_KEY: ${{ secrets.TW_SECRET_KEY }}
      TW_ACCESS_TOKEN: ${{ secrets.TW_ACCESS_TOKEN }}
      TW_SECRET_TOKEN: ${{ secrets.TW_SECRET_TOKEN }}
      SHEET_PATH: ${{ secrets.SHEET_PATH }}
      
    steps:
      - uses: actions/checkout@v2
        
      - name: Install dependencies
        run: |
          remotes::install_cran(c("rtweet"))
          remotes::install_github("tidyverse/googlesheets4")
        shell: Rscript {0}

      - name: Run script
        run: |-
          Rscript tweets/scheduled_tweets.R
```

## To go further

Some other possibles needs that could be covered :

+ emails with updated custom reports ;
+ data validation using `{pointblank}` ;
+ Twitter robots (see [that](https://github.com/zhiiiyang/zhiiiyang/blob/master/.github/workflows/main.yml)) ;
+ get a table of your own tweets. You can see my [Morphea](https://www.tillac-data.com/2020-search-your-tweets-with-an-automatic-pipeline/) project about this subject. My workflow there is more detailed.

I you want to want more, here are some options :

+ make your own Docker images to avoid downloading dependencies.
+ add a [password](https://github.com/dirkschumacher/encryptedRmd) to your dashboard with `{encryptedRmd}`.
+ if you want really more, it's better to set up your own server, using a VPS as an example. This solution is not really more difficult than using CI and the investment is worth it.

## To conclude

Pros :

+ Light automation tool.
+ Avoid setting up big server infrastructures.
+ Fast to setup.

Cons :

+ Minutes limits if it's a private repo.
+ Better to set up a server if you can.
+ Errors are hard to debug.
