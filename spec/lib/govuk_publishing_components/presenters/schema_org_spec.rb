require "spec_helper"

RSpec.describe GovukPublishingComponents::Presenters::SchemaOrg do
  describe "#structured_data" do
    it "generates schema.org Articles" do
      content_item = GovukSchemas::RandomExample.for_schema(frontend_schema: "answer") do |random_item|
        random_item.merge(
          "base_path" => "/foo",
          "details" => {
            "body" => "Foo"
          }
        )
      end

      structured_data = generate_structured_data(
        content_item: content_item,
        schema: :article,
      ).structured_data

      expect(structured_data['@type']).to eql("Article")
      expect(structured_data['mainEntityOfPage']['@id']).to eql("http://www.dev.gov.uk/foo")
      expect(structured_data['articleBody']).to eql("Foo")
    end

    it "generates schema.org NewsArticles" do
      content_item = GovukSchemas::RandomExample.for_schema(frontend_schema: "answer")

      structured_data = generate_structured_data(
        content_item: content_item,
        schema: :news_article,
      ).structured_data

      expect(structured_data['@type']).to eql("NewsArticle")
    end

    it "generates schema.org Person" do
      content_item = GovukSchemas::RandomExample.for_schema(frontend_schema: "person")

      structured_data = generate_structured_data(
        content_item: content_item,
        schema: :person,
      ).structured_data

      expect(structured_data['@type']).to eql("Person")
    end

    it "generates schema.org GovernmentOrganization" do
      content_item = generate_org(
        "base_path" => "/ministry-of-magic",
        "title" => "Ministry of Magic",
        "description" => "The magical ministry."
      )

      structured_data = generate_structured_data(
        content_item: content_item,
        schema: :organisation
      ).structured_data

      expect(structured_data["@type"]).to eq("GovernmentOrganization")
      expect(structured_data["name"]).to eq("Ministry of Magic")
      expect(structured_data["description"]).to eq("The magical ministry.")
      expect(structured_data["mainEntityOfPage"]["@id"]).to eq("http://www.dev.gov.uk/ministry-of-magic")
    end

    it "generates organisation structure" do
      parent_content_item = generate_org(
        "base_path" => "/ministry-of-magic",
        "title" => "Ministry of Magic"
      )

      child_content_item = generate_org(
        "base_path" => "/dodgy-wands-commission",
        "title" => "Dodgy Wands Commission"
      )

      content_item = generate_org(
        "base_path" => "/magical-artefacts-agency",
        "title" => "Magical Artefacts Agency",
        "links" => {
          "ordered_parent_organisations" => [parent_content_item],
          "ordered_child_organisations" => [child_content_item]
        }
      )

      structured_data = generate_structured_data(
        content_item: content_item,
        schema: :organisation
      ).structured_data

      expect(structured_data["@type"]).to eq("GovernmentOrganization")
      expect(structured_data["name"]).to eq("Magical Artefacts Agency")
      expect(structured_data["parentOrganization"][0]["sameAs"]).to eq("http://www.dev.gov.uk/ministry-of-magic")
      expect(structured_data["subOrganization"][0]["sameAs"]).to eq("http://www.dev.gov.uk/dodgy-wands-commission")
    end

    it "allows override of the URL" do
      content_item = GovukSchemas::RandomExample.for_schema(frontend_schema: "answer") do |random_item|
        random_item.merge(
          "base_path" => "/foo"
        )
      end

      structured_data = generate_structured_data(
        content_item: content_item,
        schema: :article,
        canonical_url: "https://www.gov.uk/foo/bar"
      ).structured_data

      expect(structured_data['mainEntityOfPage']['@id']).to eql("https://www.gov.uk/foo/bar")
    end

    it "allows override of the body" do
      content_item = GovukSchemas::RandomExample.for_schema(frontend_schema: "answer") do |random_item|
        random_item.merge(
          "base_path" => "/foo",
          "details" => {
            "body" => "Foo"
          }
        )
      end

      structured_data = generate_structured_data(
        content_item: content_item,
        schema: :article,
        body: "Bar"
      ).structured_data

      expect(structured_data['articleBody']).to eql("Bar")
    end

    it "adds the primary publishing org as the author" do
      content_item = GovukSchemas::RandomExample.for_schema(frontend_schema: "answer") do |random_item|
        random_item.merge(
          "links" => {
            "primary_publishing_organisation" => [
              {
                "content_id" => "d944229b-a5ad-453d-8e16-cb5dcfcdb866",
                "title" => "Foo org",
                "locale" => "en",
                "base_path" => "/orgs/foo",
              }
            ]
          }
        )
      end

      structured_data = generate_structured_data(
        content_item: content_item,
        schema: :article,
      ).structured_data

      expect(structured_data['author']['name']).to eql("Foo org")
    end

    it "links to step by steps that it belongs to" do
      content_item = GovukSchemas::RandomExample.for_schema(frontend_schema: "answer") do |random_item|
        random_item.merge(
          "first_published_at" => "2017-09-04T13:50:49.000+00:00",
          "links" => {
            "part_of_step_navs" => [
              {
                "api_path" => "/api/content/employ-someone",
                "base_path" => "/employ-someone",
                "content_id" => "47bcdf4c-9df9-48ff-b1ad-2381ca819464",
                "description" => "Employ someone: agree a contract, right to work checks, DBS checks, workplace pensions, set up PAYE, tell HMRC",
                "details" => {},
                "document_type" => "step_by_step_nav",
                "locale" => "en",
                "public_updated_at" => "2018-06-22T12:12:38Z",
                "schema_name" => "step_by_step_nav",
                "title" => "Employ someone: step by step",
                "api_url" => "https://www.gov.uk/api/content/employ-someone",
                "web_url" => "https://www.gov.uk/employ-someone"
              }
            ],
            "primary_publishing_organisation" => [
              {
                "content_id" => "d944229b-a5ad-453d-8e16-cb5dcfcdb866",
                "title" => "Foo org",
                "locale" => "en",
                "base_path" => "/orgs/foo",
              }
            ]
          }
        )
      end

      structured_data = generate_structured_data(
        content_item: content_item,
        schema: :article
      ).structured_data

      expect(structured_data['isPartOf'][0]['@type']).to eq('HowTo')
      expect(structured_data['isPartOf'][0]['sameAs']).to eq('http://www.dev.gov.uk/employ-someone')
    end

    it "adds an image if it's available" do
      content_item = GovukSchemas::RandomExample.for_schema(frontend_schema: "news_article") do |random_item|
        random_item["details"]["image"] = { "url" => "/foo" }
        random_item
      end

      structured_data = generate_structured_data(
        content_item: content_item,
        schema: :article,
      ).structured_data

      expect(structured_data['image']).to eql(["/foo"])
    end

    it "adds placeholders if there's no image" do
      content_item = GovukSchemas::RandomExample.for_schema(frontend_schema: "news_article") do |random_item|
        random_item["details"].delete("image")
        random_item
      end

      structured_data = generate_structured_data(
        content_item: content_item,
        schema: :article,
        image_placeholders: [1, 2]
      ).structured_data

      expect(structured_data['image']).to eql([1, 2])
    end

    it "adds about schema if there are live taxons" do
      content_item = GovukSchemas::RandomExample.for_schema(frontend_schema: "answer") do |random_item|
        random_item.merge(live_taxons_links)
      end

      structured_data = generate_structured_data(
        content_item: content_item,
        schema: :article
      ).structured_data

      expect(structured_data['about']).to eql([
                                                 {
                                                     "@context" => "http://schema.org",
                                                     "@type" => "Thing",
                                                     "sameAs" => "https://www.gov.uk/education/becoming-an-apprentice"
                                                 },
                                                 {
                                                     "@context" => "http://schema.org",
                                                     "@type" => "Thing",
                                                     "sameAs" => "https://www.gov.uk/employment/finding-job"
                                                 }
                                             ])
    end

    it "adds about schema but not not include non live taxon" do
      one_live_one_alpha_taxon = live_taxons_links
      one_live_one_alpha_taxon["links"]["taxons"][1]["phase"] = "alpha"
      content_item = GovukSchemas::RandomExample.for_schema(frontend_schema: "answer") do |random_item|
        random_item.merge(one_live_one_alpha_taxon)
      end

      structured_data = generate_structured_data(
        content_item: content_item,
        schema: :article
      ).structured_data

      expect(structured_data['about']).to eql([
                                                  {
                                                      "@context" => "http://schema.org",
                                                      "@type" => "Thing",
                                                      "sameAs" => "https://www.gov.uk/education/becoming-an-apprentice"
                                                  }
                                              ])
    end

    it "does not include about if no live taxons" do
      no_live_taxons = live_taxons_links
      no_live_taxons["links"]["taxons"][0]["phase"] = "alpha"
      no_live_taxons["links"]["taxons"][1]["phase"] = "draft"
      content_item = GovukSchemas::RandomExample.for_schema(frontend_schema: "answer") do |random_item|
        random_item.merge(no_live_taxons)
      end

      structured_data = generate_structured_data(
        content_item: content_item,
        schema: :article
      ).structured_data

      expect(structured_data['about']).to eql(nil)
    end

    it "links to items that belongs to the content" do
      content_item = GovukSchemas::RandomExample.for_schema(frontend_schema: "document_collection") do |random_item|
        random_item.merge(
          "first_published_at" => "2017-09-04T13:50:49.000+00:00",
          "links" => {
              "documents" => [
                  {
                      "api_path" => "/api/content/acetic-acid-properties-uses-and-incident-management",
                      "base_path" => "/acetic-acid-properties-uses-and-incident-management",
                      "content_id" => "47bcdf4c-9df9-48ff-b1ad-2381ca819464",
                      "description" => "Guidance on acetic acid (also known as ethanoic acid) for use in responding to chemical incidents",
                      "details" => {},
                      "document_type" => "guidance",
                      "locale" => "en",
                      "public_updated_at" => "2018-06-22T12:12:38Z",
                      "schema_name" => "publication",
                      "title" => "Acetic acid: health effects and incident management",
                      "api_url" => "/api/content/acetic-acid-properties-uses-and-incident-management",
                      "web_url" => "https://www.gov.uk/acetic-acid-properties-uses-and-incident-management"
                  }
              ],
              "primary_publishing_organisation" => [
                  {
                      "content_id" => "d944229b-a5ad-453d-8e16-cb5dcfcdb866",
                      "title" => "Foo org",
                      "locale" => "en",
                      "base_path" => "/orgs/foo",
                  }
              ]
          }
        )
      end

      structured_data = generate_structured_data(
        content_item: content_item,
        schema: :article
      ).structured_data

      expect(structured_data['hasPart'][0]['@type']).to eq('CreativeWork')
      expect(structured_data['hasPart'][0]['sameAs']).to eq('https://www.gov.uk/acetic-acid-properties-uses-and-incident-management')
    end

    it "links to document collection items that is part of the content" do
      content_item = GovukSchemas::RandomExample.for_schema(frontend_schema: "publication") do |random_item|
        random_item.merge(
          "first_published_at" => "2017-09-04T13:50:49.000+00:00",
          "links" => {
              "document_collections" => [
                  {
                    "api_path" => "/api/content/government/collections/chemical-hazards-compendium",
                    "base_path" => "/government/collections/chemical-hazards-compendium",
                    "content_id" => "4c01e09f-1657-4730-abd3-5015413ea196",
                    "description" => "Resource for the public and those professionals responding to chemical incidents, including emergency services and public health professionals.",
                    "document_type" => "document_collection",
                    "locale" => "en",
                    "public_updated_at" => "2017-11-23T13:45:30Z",
                    "schema_name" => "document_collection",
                    "title" => "Chemical hazards compendium",
                    "withdrawn" => false,
                    "links" => {},
                    "api_url" => "https://www.gov.uk/api/content/government/collections/chemical-hazards-compendium",
                    "web_url" => "https://www.gov.uk/government/collections/chemical-hazards-compendium"
                  }
              ],
              "primary_publishing_organisation" => [
                  {
                      "content_id" => "1343f283-19e9-4fbb-86b1-58c7549d874b",
                      "title" => "Public Health England",
                      "locale" => "en",
                      "base_path" => "/government/organisations/public-health-england",
                  }
              ]
          }
        )
      end

      structured_data = generate_structured_data(
        content_item: content_item,
        schema: :article
      ).structured_data

      expect(structured_data['isPartOf'][0]['@type']).to eq('CreativeWork')
      expect(structured_data['isPartOf'][0]['sameAs']).to eq('https://www.gov.uk/government/collections/chemical-hazards-compendium')
    end

    def live_taxons_links
      {
        "links" => {
          "taxons" => [
            {
              "api_path" => "/api/content/education/becoming-an-apprentice",
              "base_path" => "/education/becoming-an-apprentice",
              "content_id" => "ff0e8e1f-4dea-42ff-b1d5-f1ae37807af2",
              "document_type" => "taxon",
              "locale" => "en",
              "schema_name" => "taxon",
              "title" => "Becoming an apprentice",
              "withdrawn" => false,
              "phase" => "live",
              "api_url" => "https://www.gov.uk/api/content/education/becoming-an-apprentice",
              "web_url" => "https://www.gov.uk/education/becoming-an-apprentice"
            },
            {
              "api_path" => "/api/content/employment/finding-job",
              "base_path" => "/employment/finding-job",
              "content_id" => "21bfd8f6-3360-43f9-be42-b00002982d70",
              "document_type" => "taxon",
              "locale" => "en",
              "schema_name" => "taxon",
              "title" => "Finding a job",
              "withdrawn" => false,
              "phase" => "live",
              "api_url" => "https://www.gov.uk/api/content/employment/finding-job",
              "web_url" => "https://www.gov.uk/employment/finding-job"
            }
          ]
        }
      }
    end

    def generate_structured_data(args)
      GovukPublishingComponents::Presenters::SchemaOrg.new(GovukPublishingComponents::Presenters::Page.new(args))
    end

    def generate_org(details)
      # We're skipping validation of the example schema for now because content
      # schemas expect a lot of linked items to have base paths.  This is not the
      # case.  It appears that the full fix is not trivial, partly because lots
      # of tests in other apps rely on generated examples having base paths in
      # linked items.
      # We're making this change to unblock development, but it should be addressed
      # soon, particularly as we can no longer rely on the below example reflecting
      # a real content item
      GovukSchemas::RandomExample.for_schema(frontend_schema: "organisation").tap do |org|
        org.merge!(details)
      end
    end
  end
end