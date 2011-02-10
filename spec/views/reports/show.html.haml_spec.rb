require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe "/reports/show.html.haml" do
  include ReportsHelper

  it "should render successfully" do
    report_yaml = File.read(File.join(Rails.root, "spec/fixtures/reports/puppet26/report_ok_service_started_ok.yaml"))
    assigns[:report] = @report = Report.create_from_yaml(report_yaml)
    render

    rendered.should have_selector('.status img') do |img|
      img.first[:src].should =~ /changed\.png/
    end

    rendered.should have_selector("a[href=\"#{node_path(@report.node)}\"]")
  end
end
