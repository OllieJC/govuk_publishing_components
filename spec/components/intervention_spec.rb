require "rails_helper"

describe "Intervention", type: :view do
  def component_name
    "intervention"
  end

  def request(segment: "B", is_start_a_business_page: "true")
    double("request", headers: {
      "HTTP_GOVUK_ABTEST_STARTABUSINESSSEGMENT" => segment,
      "HTTP_GOVUK_ABTEST_ISSTARTABUSINESSPAGE" => is_start_a_business_page,
    })
  end

  it "renders the component" do
    render_component({ request: request })
    assert_select ".gem-c-intervention__title", text: "Check the next steps for your limited company"
    assert_select ".gem-c-intervention__description", text: "You might be interested in this because you’ve been browsing guidance relevant to starting a limited company."
  end

  it "renders nothing when no params provided" do
    assert_empty render_component({})
  end

  it "renders an intervention if the headers are correct" do
    render_component(request: request)
    assert_select ".gem-c-intervention"
  end

  it "does not render an intervention if the segment is A" do
    assert_empty render_component(request: request(segment: "A"))
  end

  it "does not render an intervention if the segment is C" do
    assert_empty render_component(request: request(segment: "C"))
  end

  it "does not render an intervention if it is not a start a business page" do
    assert_empty render_component(request: request(is_start_a_business_page: "false"))
  end

  it "does not render an intervention if the headers are missing" do
    assert_empty render_component(request: double("request", headers: {}))
  end
end
