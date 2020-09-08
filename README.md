# Run processes with CI tools

The idea of this repo is to show some ways and options about using a continuous integration (CI) tool, like Github Actions, and R to run some recurrent processes.
This capability is built on the CRON functionality in Github Actions.

Main things doable :

+ update an html dahsboard with `flexdashboard` : "lighweight automation"
+ interact with Twitter with `rtweet`. Morphea is an example of this : https://github.com/tillac/morphea
+ compile and push `pkgdown`/`bookdown`/README : already in use in `usethis`
+ link to Google Sheets


Tips :

+ My advice here is to use Docker (and especially Rocker) images.
+ Some things about setting secrets
+ Push to Netlify to keep the repo private
+ encrypt your dashboard 
+ Minuts limits
