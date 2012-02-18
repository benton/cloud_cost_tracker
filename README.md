Cloud Cost Tracker
================
Records expenses for cloud computing resources in an ActiveRecord database.

  *BETA VERSION - supports EC2 servers, EBS volumes, S3 buckets, and RDS servers*


----------------
What is it?
----------------
The Cloud Cost Tracker periodically polls one or more cloud computing accounts and determines the state of their associated cloud computing "resources": compute instances, disk volumes, stored objects, and so on. Each time an account is polled, a set of ActiveRecord objects ({CloudCostTracker::BillingRecord}s) is created or updated for each resource, containing the cost for that resource over the period of the BillingRecord.

The software can also attach "billing codes" to any resource, and to its corresponding billing records. These are arbitrary pairs of Strings which can be used to track resources for internal billing. By default, any AWS tags associated with a resource are translated into billing codes, but a framework is also provided for easily writing custom resource coding policies.

----------------
Why is it?
----------------
The Cloud Cost Tracker was created in response to the fact that Amazon Web Services does not provide per-resource billing information, which makes *internal* billing very difficult for organizations that make extensive use of AWS. Amazon's proposed solution -- creating, deleting, and cross-authorizing different AWS accounts for each internal billing entity -- is often not workable for organizations that need to perform these operations frequently. As a solution, this gem watches all resources across many accounts, and provides a way to define custom policies for assigning internal billing codes to all recorded expenses.

The Cloud Cost Tracker is intended to be a foundation library, on top of which more complex cloud billing / accounting applications can be built. Custom billing policies for cloud services and resources that are not yet implemented are simple to create, and are discovered automatically.

Also, an executable `cloud_cost_tracker` command-line program is included, which writes BillingRecords using the currently-included default policies:

  * EC2 server instance runtime costs:
    {CloudCostTracker::Billing::Compute::AWS::ServerBillingPolicy}
  * EBS volume storage costs:
    {CloudCostTracker::Billing::Compute::AWS::VolumeBillingPolicy}
  * S3 bucket storage costs:
    {CloudCostTracker::Billing::Storage::AWS::DirectoryBillingPolicy}
  * RDS server runtime costs:
    {CloudCostTracker::Billing::AWS::RDS::ServerBillingPolicy}
  * RDS server storage costs:
    {CloudCostTracker::Billing::AWS::RDS::ServerStorageBillingPolicy}


----------------
Installation
----------------
Install the Cloud Cost Tracker gem, and and your database adaptor of choice.

    gem install cloud_cost_tracker mysql2


----------------
Usage [from within Ruby]
----------------
1) Add the BillingRecords table into your database.
  Just put `require 'CloudCostTracker/tasks'` in your Rakefile, then run

    rake db:migrate:tracker

2) In your Ruby app, `require` the gem, and set up an ActiveRecord connection. In Rails, the connection is set up for you automatically on startup, but here's an example for a non-Rails app:

    require 'cloud_cost_tracker'
    ActiveRecord::Base.establish_connection({
      :adapter => 'mysql2', :database => 'cloud_cost_tracker',
      :pool => 6    # reserve at least one connection per tracked account
    })

3) Track all accounts loaded from a YAML file (or the Hash equivalent):

    tracker = CloudCostTracker::Tracker.new(YAML::load(File.read 'accounts.yml'))
    tracker.start

  (For the accounts file format, see the example below
    or the included file `config/accounts.yml.example`.)

  The tracker will run asynchronously, with one thread per account.

You can now query the database at any time, from any application.
The data model is very simple: one table for BillingRecords, and one for
BillingCodes, related many-to-many.


----------------
Usage [from the command line]
----------------
1) First, generate an ActiveRecord-style database configuration file.
   Here are the contents of a sample `database.yml`:

     adapter:   mysql2
     database:  cloud_cost_tracker
     username:  root
     pool:      10  # reserve at least one connection per tracked account

  If necessary, create the database to contain the data. The necessary tables will be created / updated by an ActiveRecord Migration.

2) Generate a YAML file containing your Fog accounts and their credentials:
   Here are the contents of a sample `accounts.yml`:

     AWS EC2 production account:   # The account name - can be anything
       :provider: AWS      # This is the Fog provider Module
       :service: Compute   # Fog service Module. So, EC2 = Fog::Compute::AWS
       :credentials:
         :aws_access_key_id: XXXXXXXXXXXXXXXXXXXX
         :aws_secret_access_key: XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
       :delay: 120 # Wait time between successive pollings (in seconds)
       :exclude_resources:
       - :account  # No need to poll for accounts - those are listed here
       - :flavors  # You may or may not want EC2 server types
       - :images   # Takes a while to list all AMIs (works though)
     AWS S3 development account:
       :provider: AWS     # S3 = Fog::Storage::AWS
       :service: Storage
       :credentials:
         :aws_access_key_id: XXXXXXXXXXXXXXXXXXXX
         :aws_secret_access_key: XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
       :delay: 150
       :exclude_resources:  # Pricing by Bucket is supported, but not by Object
       - :files # This is required for S3 - objects can't be polled directly

3) Run the tracker, and point it at the both the database config file and the accounts file.

    cloud_cost_tracker database.yml accounts.yml --migrate

  The `--migrate` argument updates the database to the latest version of the schema, and is only necessary for new databases, or when upgrading to a new version of the gem.


----------------
Development
----------------
This project is still in its early stages, but most of the framework is in place.
More resource costs need to be modeled as BillingPolicies,
but the patterns for doing so are now laid out.
For the details, see {file:writing-billing-policies.md},
{file:writing-coding-policies.md}, and the API documentation.

Helping hands are appreciated!

----------------
*Getting started with development*

1) Install project dependencies.

    gem install rake bundler

2) Fetch the project code and bundle up...

    git clone https://github.com/benton/cloud_cost_tracker.git
    cd cloud_cost_tracker
    bundle

3) Create a SQLite database for development

    rake db:migrate:tracker

4) Run the tests:

    rake
