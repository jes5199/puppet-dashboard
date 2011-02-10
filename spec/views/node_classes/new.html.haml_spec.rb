require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe "/node_classes/new.html.haml" do
  include NodeClassesHelper

  describe "successful render" do
    before :each do
      @node_class = NodeClass.generate!
      render
    end

    it { rendered.should have_selector('form', :method => 'post', :action => node_class_path(@node_class)) }
  end
end
