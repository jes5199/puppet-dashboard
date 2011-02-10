require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe "/node_groups/new.html.haml" do
  include NodeGroupsHelper

  describe "successful render" do
    before :each do
      @node_group = NodeGroup.spawn
      params[:controller] = "group"
      render :template => 'node_groups/new.html.haml'
    end

    it { rendered.should have_selector('form', :method => 'post', :action => node_groups_path) }
  end
end
