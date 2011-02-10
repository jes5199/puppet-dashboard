require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe "/node_groups/index.html.haml" do
  include NodeGroupsHelper

  describe "successful render" do
    before :each do
      template.stubs(:action_name => 'index')
      @node_groups = [ NodeGroup.generate!, NodeGroup.generate! ].paginate
      render
    end

    it "has node class items" do
      rendered.should have_selector('.node_group', :count => @node_groups.size)
      rendered.should have_selector("#node_group_#{@node_groups.last.id}")
    end

    it { rendered.should have_selector('form.search') }
  end
end
