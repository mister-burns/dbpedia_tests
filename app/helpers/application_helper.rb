module ApplicationHelper

  def get_liveshows

    query = "
    SELECT *
    WHERE {
       ?subject rdf:type <http://dbpedia.org/ontology/TelevisionShow>.
       ?subject rdfs:label ?label.
       ?subject dbpprop:language ?language.
       OPTIONAL { ?subject dbpedia-owl:wikiPageID ?wikiPageID. }
       OPTIONAL { ?subject dbpedia-owl:wikiPageRevisionID ?wikiPageRevisionID. }
       OPTIONAL { ?subject dbpedia-owl:releaseDate ?releaseDate. }
       OPTIONAL { ?subject dbpprop:country ?country. }
       OPTIONAL { ?subject dbpprop:genre ?genre. }
       OPTIONAL { ?subject dbpprop:numEpisodes ?numEpisodes. }
       OPTIONAL { ?subject dbpprop:numSeasons ?numSeasons. }
       OPTIONAL { ?subject dbpprop:firstAired ?firstAired. }
       OPTIONAL { ?subject dbpedia-owl:numberOfSeasons ?numberOfSeasons. }
       OPTIONAL { ?subject dbpedia-owl:numberOfEpisodes ?numberOfEpisodes. }
       FILTER (lang(?label) = 'en' && lang(?label) = 'en')
       FILTER regex(?language, 'English')
        }
       LIMIT 10"

    $dbpediaURI = "http://live.dbpedia.org/sparql?query=#{CGI::escape(query)}&format=json"
    response = Net::HTTP.get_response(URI.parse($dbpediaURI))
    data = response.body
    @hash = JSON.parse(data)
    #hash2 = hash["results"]["bindings"]

    #hash2.each do |h|
    #  live = Live.new
    #  live.wiki_page_id = h["wikiPageID"]["value"].to_i
    #  live.label = h["label"]["value"]
    #  live.number_of_episodes_owl = h["numberOfEpisodes"]["value"]
    #  live.number_of_seasons_owl = h["numberOfSeasons"]["value"]
    #  live.number_of_episodes_prop = h["numEpisodes"]["value"]
    #  live.number_of_seasons_prop = h["numSeasons"]["value"]
    #  live.release_date = h["releaseDate"]["value"].to_datetime
    #  live.first_aired = h["firstAired"]["value"].to_datetime
    #  live.genre = h["genre"]["value"]
    #  live.wiki_page_revision_id = h["wikiPageRevisionID"]["value"]
    #  live.language = h["language"]["value"]
    #  live.country = h["country"]["value"].class
    #  live.save
    #end
  end

end
