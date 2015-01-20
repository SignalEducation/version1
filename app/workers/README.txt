The app/workers folder is used as part of our Sidekiq / Redis background processing setup.

We can tell Sidekiq to process Rails tasks later, after the current request has been processed. This is very useful for a few related reasons;
1. Users don't have to wait for long-running tasks to be completed before getting a response.
2. Our server can take less time to complete a user's request.
3. Things that are not immediately required can be deferred to when the system is quieter.

Here's how it works:

1. We (developers) create special classes called workers (that are stored in this workers directory).  These workers are methods that perform the task that has been deferred.
2. We modify our existing methods to call these workers.
3. A background process called Sidekiq runs in the background and actively looks for things to do.
4. Sidekiq looks inside a redis database for any new jobs.  If it finds any, it plucks the jobs out, and executes them.

Example: A task that is often sent to background processing is the sending of a post-registration email.

   Normally, the users_controller#create calls UserMailer.user_welcome_email(@user).deliver.
   This can take five seconds to complete.  This is an unacceptable wait ime, so instead we can do this.

   1. Create a worker called new_user_mail_worker.rb in the workers folder
   2. Create a method in that file called perform(the_user_id) that looks up the user, and then
      sends the email.
   3. We update the users_controller#create method replacing the UserMailer call with the following:
      NewUserMailWorker.perform_async(@user.id)
   4. That's it.

We could have also called

  NewUserMailWorker.perform_in(3.hours, @user.id)

and the task would be forced to wait 3 hours before being executed by Sidekiq.


Day-to-Day
==========

Before you do Rails S, you need to do the following:

### start Redis as a background job.
$ redis-server /usr/local/etc/redis.conf
CTRL+Z
$ bg

### then, start sidekiq as a background job.
$ bundle exec sidekiq
CTRL+Z
$ bg

### Finally, ready to run the rails server
$ rails s

See sidekiq.io for more.
