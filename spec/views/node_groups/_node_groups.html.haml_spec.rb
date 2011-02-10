require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe "/node_groups/_node_groups.html.haml" do
  include NodeGroupsHelper

  describe "successful render" do
    before :each do
      @node_groups = assigns[:node_groups] = [NodeGroup.generate!]
      render :locals => {:node_groups => @node_groups}, :template => 'node_groups/_node_groups.html.haml'
    end

    it { rendered.should have_selector('.node_group', :count => @node_groups.size) }
    it { rendered.should have_selector("#node_group_#{@node_groups.first.id}") }
  end
end
