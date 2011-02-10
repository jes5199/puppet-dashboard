require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe "/node_groups/edit.html.haml" do
  include NodeGroupsHelper

  describe "when successfully rendered" do
    before :each do
      @node_group = NodeGroup.generate!
      params[:controller] = "node_groups"
    end

    it { render; rendered.should have_selector('form[method=post]', :action => node_group_path(@node_group)) }

    describe "in editing interface" do
      describe "for classes" do
        before :each do
          @classes = Array.new(6) { NodeClass.generate! }
          @node_group.node_classes << @classes[0..2]

          params[:controller] = 'node_groups'
          render
        end

        it 'should provide a means to edit the associated classes' do
          response.should have_selector('input#node_class_ids')
        end

        it 'should show the associated classes' do
          response.should have_selector('#tokenizer') do
            struct = get_json_struct_for_token_list('#node_class_ids')
            struct.should have(3).items

            (0..2).each do |idx|
              struct.should include({"id" => @classes[idx].id, "name" => @classes[idx].name})
            end
          end
        end
      end

      describe "for groups" do
        before :each do
          @groups = Array.new(6) { NodeGroup.generate! }
          @node_group.node_groups << @groups[0..3]

          params[:controller] = "groups"
          render
        end

        it 'should provide a means to edit the associated groups' do
          rendered.should have_selector('input[id=node_group_ids]')
        end

        it 'should show the associated groups' do
          rendered.should have_selector('#tokenizer') do
            struct = get_json_struct_for_token_list('#node_group_ids')
            struct.should have(4).items

            (0..3).each do |idx|
              struct.should include({"id" => @groups[idx].id, "name" => @groups[idx].name})
            end
          end
        end
      end

      def get_json_struct_for_token_list(selector)
        json = rendered[/'#{selector}'.+?prePopulate: (\[.*?\])/m, 1]
        ActiveSupport::JSON.decode(json)
      end
    end
  end
end
