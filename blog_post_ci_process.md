# Run processes with CI tools

## CI to rule them all

With R, I often design and build dashboard, with `{flexdashboard}` or HTML outputs using `{Rmarkdown}`. I also try to sometimes get data from Twitter with `{rtweet}`. Or to build tutorials or documentation with `{bookdown}` and `{pkgdown}`. I also create packages that need some checks. And I send mails to my clients with the content of their analysis (with `blastula` or `{gmailr}`).

All of that is really powerful and to me, it's modern data science. As you can see, I prefer static and lightweight HTML outputs rather than `{shiny}` apps. I found them better when you deal with "small" subjects and just need to show some insights with a regular update.

Here comes the problems : how to update my dashboard ? How to get my analysis updated without to re-run the code ? I don't have my own server (maybe in the future) and don't want it now. And to make one just to update a few dashboard and some analysis seems overkill to me.

So here comes also the solution : Continuous Integration, a.k.a CI. This tool allows you to build and check things when you push it to your versioning system. As an example, it's really useful to auto check your R packages. You can also use them to build your `{bookdown}` every time you push a change to Github (and not having to knit it by hand). Here you can use Github Actions (a.k.a GHA), which comes with Github and is really powerful. Other tools exists (Travis CI, Jenkins, Gitlab CI-CD) and could fit the same needs. 
This part of using Github Actions to build and check packages or documentation is kind of "classical". It has been really well integrated by Jim Hester and others in the `{usethis}` package with the `use_github_actions()` instruction. You can learn more about it [here](https://www.jimhester.com/talk/2020-rsc-github-actions/).

## CI to update your analysis

I also use CI for its ability to update my analysis. Because CI can use scheduled CRON processes, we can use it to re-run analysis and update them. How does this work ?

GENERAL THING : REPRODUCE ENVIRONNEMENT (ROCKER)

### Update a dashboard

DIAGRAMME CI -> REDO TEST_AUTO

NEED TO UPDATE THE DATA BEHIND (GOOGLE SHEETS / DATABASE / SCRAPING)

COULD ALSO BE ON PUSH

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
