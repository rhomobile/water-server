require 'rubygems'

# Set environment to test
ENV['RHO_ENV'] = 'test'
ROOT_PATH = ENV['ROOT_PATH']

# Try to load vendor-ed rhosync, otherwise load the gem
begin
  require 'vendor/rhosync/lib/rhosync'
rescue LoadError
  require 'rhosync'
end

# Load our rhosync application
require 'application'
include Rhosync

require 'rhosync/test_methods'

describe "SpecHelper", :shared => true do
  include Rhosync::TestMethods
  
  before(:each) do
    Store.db.flushdb
    Application.initializer(ROOT_PATH)
  end
end