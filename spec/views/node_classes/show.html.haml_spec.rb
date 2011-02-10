require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe "/node_classes/show.html.haml" do
  include NodeClassesHelper

  describe "successful render" do
    before :each do
      assigns[:node_class] = @node_class = NodeClass.generate!
      render
    end

    it { rendered.should have_selector('h2'){|h2| h2.first.text.should =~ /Class:\s+#{@node_class.name}/ } }
  end
end
