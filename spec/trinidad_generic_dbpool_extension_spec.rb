require File.expand_path(File.dirname(__FILE__) + '/spec_helper')
require 'trinidad_generic_dbpool_extension'

describe Trinidad::Extensions::GenericDbpoolWebAppExtension do
  include DbpoolExampleHelperMethods

  before(:each) do
    @defaults = { :jndi => 'jdbc/TestDB', :url => '' }
    @tomcat = mock_tomcat
    @context = build_context
  end

  it "sets the generic driver name as a resource property" do
    extension = build_extension @defaults
    resources = extension.configure(@tomcat, @context)
    resources.should be_only_and_have_property('driverClassName', nil)
  end

  it "adds the protocol if the url doesn't include it" do
    url = 'localhost:3306/without_protocol'
    options = @defaults.merge :url => url
    extension = build_extension options
    resources = extension.configure(@tomcat, @context)
    resources.should be_only_and_have_property('url', "jdbc:#{url}")
  end

  it "attempts to resolve driver name from jar path if specified" do
    extension = build_extension @defaults.merge :driverPath => File.join(File.dirname(__FILE__), 'dummy-driver')
    resources = extension.configure(@tomcat, @context)
    resources.should be_only_and_have_property('driverClassName', 'org.trinidad.jdbc.DummyDriver')
  end

  it "specified path to driver jar classes are loadable" do
    extension = build_extension @defaults.merge :driverPath => File.join(File.dirname(__FILE__), 'dummy-driver.jar')
    resources = extension.configure(@tomcat, @context)
    lambda { org.trinidad.jdbc.DummyDriver }.should_not raise_error
  end
  
  def build_extension options
    Trinidad::Extensions::GenericDbpoolWebAppExtension.new options
  end
end
