require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe "/reports/_report_status_icon.html.haml" do
  include ReportsHelper

  it "should render successfully" do
    assigns[:report] = @report = Report.generate!(:status => "changed")
    template.stubs(:resource => @report)
    render :locals => {:report => @report}, :template => "reports/_report_status_icon.html.haml"

    rendered.should have_selector('span') do |span|
      span.should have_selector('img') do |img|
        img.first[:src].should =~ /changed\.png/
      end
    end
  end
end
