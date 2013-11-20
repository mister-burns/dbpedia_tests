class LiveshowController < ApplicationController

  require 'rubygems'
  require 'json'
  require 'net/http'
  require 'chronic'
  require 'date'

  def index
     @shows = Wikicategoryapi.all
  end

  def shows
    @shows = Show.all
  end

  def test_page
    parse_infobox_string
  end

  def label_view
    @label = Label.all
  end

  def dbpedialive_view
    @shows = Liveshow.all
  end

  def wikiapi_view
   @infobox = Infobox.all
  end

  def json_view
     @json = Livejson.all
  end

  private
  def get_liveshows

    query = "
    SELECT *
    WHERE {
       ?subject rdf:type <http://dbpedia.org/ontology/TelevisionShow>.
       ?subject rdfs:label ?label.
       ?subject dbpprop:language ?language.
       OPTIONAL { ?subject dbpprop:country ?country. }
       OPTIONAL { ?subject dbpprop:numEpisodes ?numEpisodes. }
       OPTIONAL { ?subject dbpprop:numSeasons ?numSeasons. }
       OPTIONAL { ?subject dbpprop:firstAired ?firstAired. }
       FILTER (lang(?label) = 'en' && lang(?label) = 'en')
       FILTER regex(?language, 'English')
       FILTER (regex(?country, 'United', 'i') || (regex(?country, 'Canada', 'i')))
        }
       LIMIT 3000"

    $dbpediaURI = "http://live.dbpedia.org/sparql?query=#{CGI::escape(query)}&format=json"
    response = Net::HTTP.get_response(URI.parse($dbpediaURI))
    data = response.body
    hash = JSON.parse(data)
    hash2 = hash["results"]["bindings"]

    hash2.each do |h|
      liveshow = Liveshow.new
      liveshow.label = h["label"]["value"]

      if h["numEpisodes"].nil?
      else
        liveshow.number_of_episodes_prop = h["numEpisodes"]["value"]
      end

      if h["numSeasons"].nil?
      else
        liveshow.number_of_seasons_prop = h["numSeasons"]["value"]
      end

      if h["firstAired"].nil?
      else
        if h["firstAired"]["value"].is_a?(DateTime)
           liveshow.first_aired = h["firstAired"]["value"].to_datetime
        end
      end

      if h["language"].nil?
      else
        liveshow.language = h["language"]["value"]
      end

      if h["country"].nil?
        liveshow.save
      else
        liveshow.country = h["country"]["value"]
        liveshow.save
      end
    end
  end

  private
  def get_showlabels
    query = "
    SELECT *
    WHERE {
       ?subject rdf:type <http://dbpedia.org/ontology/TelevisionShow>.
       ?subject rdfs:label ?label.
       ?subject dbpprop:language ?language.
       OPTIONAL { ?subject dbpprop:country ?country. }
       FILTER (lang(?label) = 'en' && lang(?label) = 'en')
       FILTER regex(?language, 'English')
       FILTER (regex(?country, 'United', 'i') || (regex(?country, 'Canada', 'i')))
        }
       LIMIT 1000"

    $dbpediaURI = "http://live.dbpedia.org/sparql?query=#{CGI::escape(query)}&format=json"
    response = Net::HTTP.get_response(URI.parse($dbpediaURI))
    data = response.body
    hash = JSON.parse(data)
    hash2 = hash["results"]["bindings"]

    hash2.each do |h|
      label = Label.new
      label.label = h["label"]["value"]
      label.save
    end

  end

  private
  def wiki_api
    wiki = Label.all
    wiki.limit(5000).each do |wiki|
      if wiki.label.nil?
      else
      query = wiki.label
      #this is the titles version...to switch back to page id use "pageids" as the query param
      #need to remove CGI:escape part if you switch back to number query
      $wikiAPI = "http://en.wikipedia.org/w/api.php?format=json&action=query&titles=#{CGI::escape(query)}&prop=revisions&rvprop=content&rvsection=0"
      response = Net::HTTP.get_response(URI.parse($wikiAPI))
      data = response.body
      #hash = JSON.parse(data).to_s
      #test if JSON date is nil:
        if data.nil?
        else
          #create a new variable from the infobox model, save inbox and label data:
          box = Infobox.new
          box.infobox = data
          box.label = wiki.label
          box.save
        end
      end
    end
  end

  private
  def get_livejson
    live = Label.all
    live.limit(100).each do |live|
      if live.label.nil?
      else
        query = live.label.gsub(" ","_")
        #need to remove CGI:escape part if you switch back to number query
        $liveAPI = "http://live.dbpedia.org/data/#{query}.json"
        response = Net::HTTP.get_response(URI.parse($liveAPI))
        data = response.body
        #test if data is nil:
        if data.nil?
        else
          #create a new variable from the infobox model, save inbox and label data:
          box = Livejson.new
          box.jsondata = data
          box.label = live.label
          box.save
        end
      end
    end
  end

  private
  def wikiapi_call_from_category_list
    wiki = Wikicategoryapi.all
    wiki.each do |wiki|
      if wiki.page_id.nil?
      else
        query = wiki.page_id
        #this is the wiki article numbers version
        #need to remove CGI:escape part if you switch back to number query
        $wikiAPI = "http://en.wikipedia.org/w/api.php?format=json&action=query&pageids=#{query}&prop=revisions&rvprop=content&rvsection=0"
        response = Net::HTTP.get_response(URI.parse($wikiAPI))
        data = response.body
        #hash = JSON.parse(data).to_s
        #test if JSON date is nil:
        if data.nil?
        else
          #create a new variable from the infobox model, save inbox and label data:
          box = Infobox.new
          box.infobox = data
          box.label = wiki.page_title
          box.page_id = wiki.page_id
          box.save
        end
      end
    end
  end

  private
  def parse_infobox_string
    infobox = Infobox.all
    infobox.each do |infobox|
      page = infobox.page_id
      string = JSON.parse(infobox.infobox)["query"]["pages"]["#{page}"]["revisions"].first["*"]
      season_match = /(num_seasons\s*=\s*+)([0-9]+)/.match(string)
      episode_match = /(num_episodes\s*=\s*+)([0-9]+)/.match(string)
      @first_aired_match = /(first_aired\s*=\s*+).+?(?=\d+\|)((\d+)\|?(\d+)\|?(\d+))/.match(string)
      if season_match.nil?
         @season_value = nil
         else
         @season_value = season_match[2]
      end
      if episode_match.nil?
         @season_value = nil
         else
         @episode_value = episode_match[2]
      end
      show = Show.where(:wikipage_id => infobox.page_id).first
      show.number_of_seasons = @season_value
      show.number_of_episodes = @episode_value
      show.save
    end
  end


  private
  def save_show_names_to_show_model
    infobox = Infobox.all
    infobox.each do |infobox|
      show = Show.where(:wikipage_id => infobox.page_id).first
      show.show_name = infobox.label
      show.save
    end
  end

  private
  def wikiapi_category_list
    @query = "English-language_television_programming"
    #this is the version to query a list of wikipedia entries by category. Deliver JSON with 500 item limit.
    #Need to combine key from results to continuation to get full list.
    $wikicategoryAPI = "https://en.wikipedia.org/w/api.php?action=query&list=categorymembers&format=json&cmtitle=Category:#{@query}&cmlimit=500"
    response = Net::HTTP.get_response(URI.parse($wikicategoryAPI))
    data = response.body
    hash = JSON.parse(data)
    hash2 = hash["query"]["categorymembers"]
    cmcontinue = hash["query-continue"]["categorymembers"]["cmcontinue"].to_s

    save_wikicategory_list(hash2)

    #Found a stack overflow page that said I needed to add the URI.encode line due to special characters, I assume the |
    $cmcontinueAPI = URI.encode("https://en.wikipedia.org/w/api.php?action=query&list=categorymembers&format=json&cmtitle=Category:#{@query}&cmlimit=500&cmcontinue=#{cmcontinue}")
    response = Net::HTTP.get_response(URI.parse($cmcontinueAPI))
    data = response.body
    hash = JSON.parse(data)
    hash2 = hash["query"]["categorymembers"]
    cmcontinue = hash["query-continue"]["categorymembers"]["cmcontinue"]

    save_wikicategory_list(hash2)

    $cmcontinueAPI = URI.encode("https://en.wikipedia.org/w/api.php?action=query&list=categorymembers&format=json&cmtitle=Category:#{@query}&cmlimit=500&cmcontinue=#{cmcontinue}")
    response = Net::HTTP.get_response(URI.parse($cmcontinueAPI))
    data = response.body
    hash = JSON.parse(data)
    hash2 = hash["query"]["categorymembers"]
    cmcontinue = hash["query-continue"]["categorymembers"]["cmcontinue"]

    save_wikicategory_list(hash2)

    $cmcontinueAPI = URI.encode("https://en.wikipedia.org/w/api.php?action=query&list=categorymembers&format=json&cmtitle=Category:#{@query}&cmlimit=500&cmcontinue=#{cmcontinue}")
    response = Net::HTTP.get_response(URI.parse($cmcontinueAPI))
    data = response.body
    hash = JSON.parse(data)
    hash2 = hash["query"]["categorymembers"]
    cmcontinue = hash["query-continue"]["categorymembers"]["cmcontinue"]

    save_wikicategory_list(hash2)

    $cmcontinueAPI = URI.encode("https://en.wikipedia.org/w/api.php?action=query&list=categorymembers&format=json&cmtitle=Category:#{@query}&cmlimit=500&cmcontinue=#{cmcontinue}")
    response = Net::HTTP.get_response(URI.parse($cmcontinueAPI))
    data = response.body
    hash = JSON.parse(data)
    hash2 = hash["query"]["categorymembers"]
    cmcontinue = hash["query-continue"]["categorymembers"]["cmcontinue"]

    save_wikicategory_list(hash2)

    $cmcontinueAPI = URI.encode("https://en.wikipedia.org/w/api.php?action=query&list=categorymembers&format=json&cmtitle=Category:#{@query}&cmlimit=500&cmcontinue=#{cmcontinue}")
    response = Net::HTTP.get_response(URI.parse($cmcontinueAPI))
    data = response.body
    hash = JSON.parse(data)
    hash2 = hash["query"]["categorymembers"]
    cmcontinue = hash["query-continue"]["categorymembers"]["cmcontinue"]

    save_wikicategory_list(hash2)

    $cmcontinueAPI = URI.encode("https://en.wikipedia.org/w/api.php?action=query&list=categorymembers&format=json&cmtitle=Category:#{@query}&cmlimit=500&cmcontinue=#{cmcontinue}")
    response = Net::HTTP.get_response(URI.parse($cmcontinueAPI))
    data = response.body
    hash = JSON.parse(data)
    hash2 = hash["query"]["categorymembers"]
    cmcontinue = hash["query-continue"]["categorymembers"]["cmcontinue"]

    save_wikicategory_list(hash2)

    $cmcontinueAPI = URI.encode("https://en.wikipedia.org/w/api.php?action=query&list=categorymembers&format=json&cmtitle=Category:#{@query}&cmlimit=500&cmcontinue=#{cmcontinue}")
    response = Net::HTTP.get_response(URI.parse($cmcontinueAPI))
    data = response.body
    hash = JSON.parse(data)
    hash2 = hash["query"]["categorymembers"]
    cmcontinue = hash["query-continue"]["categorymembers"]["cmcontinue"]

    save_wikicategory_list(hash2)

    $cmcontinueAPI = URI.encode("https://en.wikipedia.org/w/api.php?action=query&list=categorymembers&format=json&cmtitle=Category:#{@query}&cmlimit=500&cmcontinue=#{cmcontinue}")
    response = Net::HTTP.get_response(URI.parse($cmcontinueAPI))
    data = response.body
    hash = JSON.parse(data)
    hash2 = hash["query"]["categorymembers"]
    cmcontinue = hash["query-continue"]["categorymembers"]["cmcontinue"]

    save_wikicategory_list(hash2)

    $cmcontinueAPI = URI.encode("https://en.wikipedia.org/w/api.php?action=query&list=categorymembers&format=json&cmtitle=Category:#{@query}&cmlimit=500&cmcontinue=#{cmcontinue}")
    response = Net::HTTP.get_response(URI.parse($cmcontinueAPI))
    data = response.body
    hash = JSON.parse(data)
    hash2 = hash["query"]["categorymembers"]
    cmcontinue = hash["query-continue"]["categorymembers"]["cmcontinue"]

    save_wikicategory_list(hash2)

    $cmcontinueAPI = URI.encode("https://en.wikipedia.org/w/api.php?action=query&list=categorymembers&format=json&cmtitle=Category:#{@query}&cmlimit=500&cmcontinue=#{cmcontinue}")
    response = Net::HTTP.get_response(URI.parse($cmcontinueAPI))
    data = response.body
    hash = JSON.parse(data)
    hash2 = hash["query"]["categorymembers"]
    cmcontinue = hash["query-continue"]["categorymembers"]["cmcontinue"]

    save_wikicategory_list(hash2)

    $cmcontinueAPI = URI.encode("https://en.wikipedia.org/w/api.php?action=query&list=categorymembers&format=json&cmtitle=Category:#{@query}&cmlimit=500&cmcontinue=#{cmcontinue}")
    response = Net::HTTP.get_response(URI.parse($cmcontinueAPI))
    data = response.body
    hash = JSON.parse(data)
    hash2 = hash["query"]["categorymembers"]
    cmcontinue = hash["query-continue"]["categorymembers"]["cmcontinue"]

    save_wikicategory_list(hash2)

    $cmcontinueAPI = URI.encode("https://en.wikipedia.org/w/api.php?action=query&list=categorymembers&format=json&cmtitle=Category:#{@query}&cmlimit=500&cmcontinue=#{cmcontinue}")
    response = Net::HTTP.get_response(URI.parse($cmcontinueAPI))
    data = response.body
    hash = JSON.parse(data)
    hash2 = hash["query"]["categorymembers"]
    cmcontinue = hash["query-continue"]["categorymembers"]["cmcontinue"]

    save_wikicategory_list(hash2)

    $cmcontinueAPI = URI.encode("https://en.wikipedia.org/w/api.php?action=query&list=categorymembers&format=json&cmtitle=Category:#{@query}&cmlimit=500&cmcontinue=#{cmcontinue}")
    response = Net::HTTP.get_response(URI.parse($cmcontinueAPI))
    data = response.body
    hash = JSON.parse(data)
    hash2 = hash["query"]["categorymembers"]
    #Need to come up with an if system to stop when then list is finished and the last cmcontinue
    #variable comes up as nil.
    #cmcontinue = hash["query-continue"]["categorymembers"]["cmcontinue"]

    save_wikicategory_list(hash2)


  end

  private
  def save_wikicategory_list(hash2)
    hash2.each do |hash2|
      show = Wikicategoryapi.new
      show.page_id = hash2["pageid"]
      show.page_title = hash2["title"]
      show.save
    end
  end

  private
  #This did not work...could not pass the hash2 variable and cmcontinue properly from the save_wikicategory_list method
  def category_continuation(cmcontinue)
    $cmcontinueAPI = URI.encode("https://en.wikipedia.org/w/api.php?action=query&list=categorymembers&format=json&cmtitle=Category:#{@query}&cmlimit=500&cmcontinue=#{cmcontinue}")
    response = Net::HTTP.get_response(URI.parse($cmcontinueAPI))
    data = response.body
    hash = JSON.parse(data)
    hash2 = hash["query"]["categorymembers"]
    cmcontinue = hash["query-continue"]["categorymembers"]["cmcontinue"]
  end


end
