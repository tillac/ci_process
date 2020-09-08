# Run processes with CI tools

## CI to rule them all

With R, I often design and build dashboard, with `{flexdashboard}` or HTML outputs using `{rmarkdown}`. I also try to sometimes get data from Twitter with `{rtweet}`. Or to build tutorials or documentation with `{bookdown}` and `{pkgdown}`. I also create packages that need some checks. And I send mails to my clients with the content of their analysis (with `blastula` or `{gmailr}`).

All of that is really powerful and to me, it's modern data science. As you can see, I prefer static and lightweight HTML outputs rather than `{shiny}` apps. I found them better when you deal with "small" subjects and just need to show some insights with a regular update.

Here comes the problems : how to update my dashboard ? How to get my analysis updated without to re-run the code ? I don't have my own server (maybe in the future) and don't want it now. And to make one just to update a few dashboard and some analysis seems overkill to me.

So here comes also the solution : Continuous Integration, a.k.a CI. This tool allows you to build and check things when you push it to your versioning system. As an example, it's really useful to auto check your R packages. You can also use them to build your `{bookdown}` every time you push a change to Github (and not having to knit it by hand). Here you can use Github Actions (a.k.a GHA), which comes with Github and is really powerful. Other tools exists (Travis CI, Jenkins, Gitlab CI-CD) and could fit the same needs. 
This part of using Github Actions to build and check packages or documentation is kind of "classical". It has been really well integrated by Jim Hester and others in the `{usethis}` package with the `use_github_actions()` instruction. You can learn more about it [here](https://www.jimhester.com/talk/2020-rsc-github-actions/).

## CI to update your analysis

I also use CI for its ability to update my analysis. Because CI can use scheduled CRON processes, we can use it to re-run analysis and update them. How does this work ?

GENERAL THING : REPRODUCE ENVIRONNEMENT (ROCKER)

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

+ And I push it to a new branch, called "gh-pages". I have to configure Github Pages on it after to get the HTML file as [here](). This git workflow is inspired by `pkgdown::deploy_to_branch`.

```

```


### Automatic Twitter table

MORPHEA

## To go further

MAKE A SERVER
MAKE YOUR OWN DOCKER IMAGES
DASHBORD ENCRYPTION

OTHER POSSIBLE NEEDS :

+ email
+ auto tweeting/robots
+ database validation using `{pointblank}`

## To conclude

Pros :

+
+

Cons :

+
+
