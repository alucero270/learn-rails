# pressfrwrd.com


## Getting started

### run tests

    $ cp config/database.yml.example config/database.yml
    $ bundle install
    $ bundle exec rake db:migrate
    $ bundle exec rake db:test:prepare
    $ bundle exec rake spec
    $ bundle exec rake cucmber


## Deployment on heroku:

### master/production branch:

Normally we develop on feature branch, we ask pull request to merge to master.
We deploy from master to staging, once good we merge from staging to production branch and we deploy from production branch to production.

Then we push to staging to staging repo's master with:
    $ git remote add staging git@heroku.com:pressfrwrd-staging.git
    $ git push staging master:master
    
Once staging is ok, we use github to merge staging to production then. We push to production with:
    $ git remote add production git@heroku.com:pressfrwrd.git
    $ git push production production:master

#### Create staging and prod instances

    $ heroku create pressfwrd-staging --remote staging
    $ heroku create pressfwrd --remote production
    $ git push staging master
    $ git push production master

#### Set environments:

#### Run migrations:
    $ heroku rake db:migrate --app pressfwrd-staging
    

