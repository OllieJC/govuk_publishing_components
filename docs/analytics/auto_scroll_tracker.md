# Scroll tracking

The analytics code includes the ability to add scroll tracking to specified pages for users who have consented to cookies.

There are currently two scroll tracking scripts in the gem. You should use AutoScrollTracker. The previous one, ScrollTracker, has been deprecated by the introduction of AutoScrollTracker and should now be considered legacy.

AutoScrollTracker has been written to address problems with ScrollTracker, but the scroll tracking handled by ScrollTracker has yet to be transferred to AutoScrollTracker.

## AutoScrollTracker

AutoScrollTracker is a GOVUK.Module and can be initialised by adding the relevant code to a template. Since scroll tracking is only required once on a page, it should be initialised using a meta tag in the HEAD element, like this.

```html
<% content_for :extra_head_content do %>
  <meta name="govuk:scroll-tracker" content="" data-module="auto-scroll-tracker"/>
<% end %>
```

### Options

By default, AutoScrollTracker tracks by percentage scrolled. Specifically, it will fire a GA event when the user scrolls to 20%, 40%, 60%, 80% and 100% of the page height.

It can track headings instead of percentages, using the `data-track-type` option.

```html
<% content_for :extra_head_content do %>
  <meta name="govuk:scroll-tracker" content="" data-module="auto-scroll-tracker" data-track-type="headings"/>
<% end %>
```

As a single template may render multiple pages, options are available to include or exclude only specific URLs, as well as further configuration specifics. This can be achieved by adding JSON to the `data-track-details` attribute.

For example, in the template that renders travel advice pages, the `include` option can be used to only apply scroll tracking to specific pages.

```html
<% content_for :extra_head_content do %>
  <%
    track_details = "{
      'include': [
        {
          'path': '/foreign-travel-advice/benin'
        },
        {
          'path': '/foreign-travel-advice/france'
        },
      ]
    }".squish
  %>
  <meta name="govuk:scroll-tracker" content="" data-module="auto-scroll-tracker" data-track-details="<%= track_details %>"/>
<% end %>
```

Similarly, the `exclude` option can be used to apply scroll tracking to all pages rendered by this template, apart from those specified.

```html
<% content_for :extra_head_content do %>
  <%
    track_details = "{
      'exclude': [
        {
          'path': '/foreign-travel-advice/iceland'
        }
      ]
    }".squish
  %>
  <meta name="govuk:scroll-tracker" content="" data-module="auto-scroll-tracker" data-track-details="<%= track_details %>"/>
<% end %>
```

Tracking of specific headings or percentages can also be applied using the `include` option. Note that tracking specific headings is dependent on the text of those headings remaining constant. If the wording of a tracked heading is changed, tracking will stop working for that heading.

```html
<% content_for :extra_head_content do %>
  <%
    track_details = "{
      'include': [
        {
          'path': '/foreign-travel-advice/france',
          'headings': ['Check separate travel advice pages for overseas territories of France.', 'Explore the topic']
        },
        {
          'path': '/foreign-travel-advice/benin',
          'percentages': [25, 50, 75, 100]
        },
      ]
    }".squish
  %>
  <meta name="govuk:scroll-tracker" content="" data-module="auto-scroll-tracker" data-track-details="<%= track_details %>"/>
<% end %>
```


### Behaviour

AutoScrollTracker finds the position of things (percentages and headings, including the text of headings) on page load to minimise calculations when the user scrolls. This finding is repeated if any of the following occur:

- the user resizes the page
- the height of the page changes (for example if the cookie banner is dismissed, or an accordion item is expanded). This also detects user font size or zoom level changes

Operation:

- Tracking events are only fired once i.e. if a user scrolls up and down a page, duplicate events are not tracked.
- Tracking events are fired on page load for things that are immediately visible.
- If the user has followed a jump link, e.g. `https://www.gov.uk/foreign-travel-advice/spain/coronavirus#finance` the script detects this and doesn't fire tracking events until after the browser jumps to the relevant section. It also checks that the hash matches a valid element on the page, and continues as normal if it doesn't.
- Headings are tracked only when the whole of the heading is visible in the viewport.
- Headings are only tracked if they are inside the 'main' element, in order to avoid tracking headings in e.g. the cookie banner, the footer (this has been written to be extendable in future if other elements/classes are required)
- Hidden headings are not tracked, unless they become visible (e.g. if inside an accordion that is opened).

## ScrollTracker (deprecated, legacy approach)

ScrollTracker should not be used for new scroll tracking requirements as it has several limitations.

- To track a URL, it must be added to the ScrollTracker script itself (in the config section). This adds page weight for every page on GOV.UK.
- To track headings, the text of headings must be added to the config as well. This adds further page weight and is inherently brittle - no mechanism exists for maintaining this config if the text of headings is changed.

ScrollTracker is still being used for some scroll tracking, although eventually all scroll tracking should be migrated to AutoScrollTracker if possible.
