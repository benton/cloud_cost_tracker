require 'active_record'
require 'logger'

# Load generic Policy classes
require 'cloud_cost_tracker/billing/resource_billing_policy'
require 'cloud_cost_tracker/coding/resource_coding_policy'
require 'cloud_cost_tracker/billing/account_billing_policy'
require 'cloud_cost_tracker/coding/account_coding_policy'
# Load all ruby files from 'cloud_cost_tracker' directory - except the tasks
libs = Dir[File.join(File.dirname(__FILE__), "cloud_cost_tracker/**/*.rb")]
libs.delete File.join(File.dirname(__FILE__), "cloud_cost_tracker/tasks.rb")
libs.each {|f| require f}

# Top-level module namespace - defines some static methods for mapping providers,
# services and resources to their various Billing and Coding Policies
module CloudCostTracker
  # Returns the current RACK_ENV or RAILS_ENV, or 'development' if not set.
  # @return [String] ENV[RACK_ENV] || ENV[RAILS_ENV] || development
  def self.env
    (ENV['RACK_ENV'] || ENV['RAILS_ENV'] || 'development').downcase
  end

  # Connects to the database defined in db_file.
  # Uses the YAML section indexed by {CloudCostTracker#env}.
  # @param db_file the path to a Rails-style YAML DB config file.
  # @return [Hash] the current envinronment's database configuration.
  def self.connect_to_database(db_file = ENV['DB_CONFIG_FILE'])
    db_file ||= "./config/database.yml"
    all_dbs = YAML::load(File.read db_file)
    if not ::ActiveRecord::Base.connected?
      ::ActiveRecord::Base.establish_connection(all_dbs[CloudCostTracker.env])
    end
    all_dbs[CloudCostTracker.env]
  end

  # Loads account information defined in account_file.
  # @param account_file the path to a YAML file (see accounts.yml.example).
  # @return [Hash] the cleaned, validated Hash of account info.
  def self.read_accounts(account_file = ENV['ACCOUNT_FILE'])
    FogTracker.read_accounts(account_file)
  end

  # Creates and returns an Array of ResourceBillingPolicy (subclass) instances
  # for billing the given +resource+, or an empty Array of none are found
  # @param [Class] resource_class the Class object for the billed resource
  # @param [Hash] options optional additional parameters:
  #  - :logger - a Ruby Logger-compatible object
  # @return [Array <ResourceBillingPolicy>] billing policy objects for resource
  def self.create_billing_agents(resource_class, options = {})
    agents = Array.new
    # Safely descend through the Billing module Heirarchy
    if matches = resource_class.name.match(%r{^Fog::(\w+)::(\w+)::(\w+)})
      fog_svc, provider, model_name = matches[1], matches[2], matches[3]
      if CloudCostTracker::Billing.const_defined? fog_svc
        service_module = CloudCostTracker::Billing::const_get fog_svc
        if service_module.const_defined? provider
          provider_module = service_module.const_get provider
          # Search through the classes in the module for all matches
          classes = provider_module.classes.each do |policy_class|
            if policy_class.name =~ /#{model_name}.*BillingPolicy/
              agents << policy_class.new(:logger => options[:logger])
            end
          end
        end
      end
    end
    agents.sort {|a,b| a.class.name <=> b.class.name} # sort by class name
  end

  # Creates and returns an Array of ResourceCodingPolicy (subclass) instances
  # for coding the given +resource+, or an empty Array of none are found
  # @param [Class] resource_class the Class object for the billed resource
  # @param [Hash] options optional additional parameters:
  #  - :logger - a Ruby Logger-compatible object
  # @return [Array <ResourceCodingPolicy>] coding policy objects for resource
  def self.create_coding_agents(resource_class, options = {})
    agents = Array.new
    # Safely descend through the Coding module Heirarchy
    if matches = resource_class.name.match(%r{^Fog::(\w+)::(\w+)::(\w+)})
      fog_svc, provider, model_name = matches[1], matches[2], matches[3]
      if CloudCostTracker::Coding.const_defined? fog_svc
        service_module = CloudCostTracker::Coding::const_get fog_svc
        if service_module.const_defined? provider
          provider_module = service_module.const_get provider
          # Search through the classes in the module for all matches
          classes = provider_module.classes.each do |policy_class|
            if policy_class.name =~ /#{model_name}.*CodingPolicy/
              agents << policy_class.new(:logger => options[:logger])
            end
          end
        end
      end
    end
    agents.sort {|a,b| a.class.name <=> b.class.name} # sort by class name
  end

  # Returns a Class object, of the appropriate subclass of
  # AccountCodingPolicy, given a Fog service and provider name.
  # If none exists, returns CloudCostTracker::Coding::AccountCodingPolicy.
  def self.account_coding_class(fog_service, provider)
    agent_class = CloudCostTracker::Coding::AccountCodingPolicy
    if CloudCostTracker::Coding.const_defined? fog_service
      service_module = CloudCostTracker::Coding::const_get fog_service
      if service_module.const_defined? provider
        provider_module = service_module.const_get provider
        if provider_module.const_defined? 'AccountCodingPolicy'
          agent_class = provider_module.const_get 'AccountCodingPolicy'
        end
      end
    end
    agent_class
  end


end
