require 'rails_helper'

describe "Lead paragraph", type: :view do
  def component_name
    "lead_paragraph"
  end

  def assert_lead_paragraph_matches(text, expected_text)
    render_component(text: text)
    assert_select ".gem-c-lead-paragraph", text: expected_text
  end

  it "renders nothing without a description" do
    assert_empty render_component({}).strip
  end

  it "renders a lead paragraph" do
    render_component(text: 'UK Visas and Immigration is making changes to the Immigration Rules affecting various categories.')
    assert_select ".gem-c-lead-paragraph", text: "UK Visas and Immigration is making changes to the Immigration Rules affecting various categories."
  end
end