require "rails_helper"

describe "Intervention", type: :view do
  def component_name
    "intervention"
  end

  it "renders the component" do
    render_component(
      suggestion_text: "You might be interested in",
      suggestion_link_text: "Travel abroad",
      suggestion_link_url: "/travel-abroad",
      dismiss_text: "Hide this suggestion",
    )

    assert_select ".gem-c-intervention", text: /You might be interested in/
    assert_select ".gem-c-intervention__suggestion-link", text: "Travel abroad"
    assert_select ".gem-c-intervention__dismiss", text: /Hide this suggestion/
  end

  it "renders the component without dismiss button" do
    render_component(
      suggestion_text: "You might be interested in",
      suggestion_link_text: "Travel abroad",
      suggestion_link_url: "/travel-abroad",
    )

    assert_select ".gem-c-intervention", text: /You might be interested in/
    assert_select ".gem-c-intervention__suggestion-link", text: "Travel abroad"
    assert_select ".gem-c-intervention__dismiss", false
  end

  it "renders the component without suggestion link" do
    render_component(
      suggestion_text: "You might be interested in",
      dismiss_text: "Hide this suggestion",
    )

    assert_select ".gem-c-intervention", text: /You might be interested in/
    assert_select ".gem-c-intervention__suggestion-link", false
    assert_select ".gem-c-intervention__dismiss", text: /Hide this suggestion/
  end

  it "renders the right query string when none exists" do
    render_component(
      suggestion_text: "You might be interested in",
      dismiss_text: "Hide this suggestion",
    )

    assert_select "a[href='?hide-intervention=true']"
  end

  it "renders the right query string when one exists already" do
    render_component(
      suggestion_text: "You might be interested in",
      dismiss_text: "Hide this suggestion",
      query_string: "?a=b&c=d",
    )

    assert_select "a[href='?a=b&c=d&hide-intervention=true']"
  end

  it "doesn't render anything if no parameter is passed" do
    assert_empty render_component({})
  end
end
