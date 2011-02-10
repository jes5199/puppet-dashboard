require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe "/reports/_report_status_td.html.haml" do
  include ReportsHelper

  describe "successful render" do
    before :each do
      @report = Report.generate!(:status => "changed")
      render :locals => {:report => @report}, :template => 'reports/_report_status_td.html.haml'
    end

    it { rendered.should have_selector('td.status.changed img'){|img| img.first[:src].should =~ /changed/ } }
  end
end
