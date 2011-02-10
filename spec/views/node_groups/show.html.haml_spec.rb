require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe "/node_groups/show.html.haml" do
  include NodeGroupsHelper

  describe "successful render" do
    before :each do
      @node_group = NodeGroup.generate!
      render
    end

    it { rendered.should have_selector('h2'){|h2| h2 =~ /Group:\s+#{@node_group.name}/ } }
  end
end
