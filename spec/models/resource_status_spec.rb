require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe ResourceStatus do
  describe "#name" do
    it "should combine type and title" do
      resource_status = ResourceStatus.create!(:resource_type => "File", :title => "/tmp/foo", :report_id => 142857)
      resource_status.name.should == "File[/tmp/foo]"
    end
  end

  describe "when searching for file resources" do
    before do
      @matching_report = Report.create!(:host => "foo", :time => 1.week.ago.to_date, :status => "unchanged", :kind => "inspect")
      @matching_report.resource_statuses.create!(:resource_type => "File", :title => "/etc/hosts", :events_attributes => [{:property => "content", :previous_value => "{md5}ab07acbb1e496801937adfa772424bf7"}])
      @unmatching_report = Report.create!(:host => "foo", :time => 2.weeks.ago.to_date, :status => "unchanged", :kind => "inspect")
      @unmatching_report.resource_statuses.create!(:resource_type => "File", :title => "/etc/sudoers", :events_attributes => [{:property => "content", :previous_value => "{md5}aa876288711c4198cfcda790b58d7e95"}])
    end

    describe ".by_file_title" do
      it "should find only the resource_statuses containing the given file" do
        ResourceStatus.by_file_title("/etc/hosts").should == @matching_report.resource_statuses
      end
    end

    describe ".by_file_content" do
      it "should find only the resource_statuses containing the given file content" do
        ResourceStatus.by_file_content("ab07acbb1e496801937adfa772424bf7").should == @matching_report.resource_statuses
      end
    end

    describe ".by_file_title.by_file_content" do
      it "should find only the reports containing a file with the given title and content" do
        ResourceStatus.by_file_title("/etc/hosts").by_file_content("ab07acbb1e496801937adfa772424bf7").should == @matching_report.resource_statuses
      end

      it "should ignore reports that have matching title and matching content in different files" do
        @other_unmatching_report = Report.create!(:host => "foo", :time => 3.weeks.ago.to_date, :status => "unchanged", :kind => "inspect")
        @other_unmatching_report.resource_statuses.create!(:resource_type => "File", :title => "/etc/hosts", :events_attributes => [{:property => "content", :previous_value => "{md5}aa876288711c4198cfcda790b58d7e95"}])
        @other_unmatching_report.resource_statuses.create!(:resource_type => "File", :title => "/etc/sudoers", :events_attributes => [{:property => "content", :previous_value => "{md5}ab07acbb1e496801937adfa772424bf7"}])
        ResourceStatus.by_file_title("/etc/hosts").should == @matching_report.resource_statuses + [@other_unmatching_report.resource_statuses.first]
        ResourceStatus.by_file_content("ab07acbb1e496801937adfa772424bf7").should == @matching_report.resource_statuses + [@other_unmatching_report.resource_statuses.last]
        ResourceStatus.by_file_title("/etc/hosts").by_file_content("ab07acbb1e496801937adfa772424bf7").should == @matching_report.resource_statuses
      end
    end

    describe ".latest_inspections" do
      it "should only return statuses from reports that are the latest inspect report for their node" do
        ResourceStatus.latest_inspections.should =~ @matching_report.resource_statuses
      end
    end
  end
end

