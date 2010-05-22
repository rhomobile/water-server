require File.join(File.dirname(__FILE__),'..','spec_helper')

describe "Site" do
  it_should_behave_like "SpecHelper"
  
  before(:each) do
    setup_test_for Site,'testuser'
  end
  
  it "should process Site query" do
    test_query.size.should > 0
  end
  
  it "should process Site create" do
    pending
  end
  
  it "should process Site update" do
    pending
  end
  
  it "should process Site delete" do
    pending
  end
end