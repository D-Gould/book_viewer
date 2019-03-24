require "sinatra"
require "sinatra/reloader" if development?

before do
  @contents = File.readlines("data/toc.txt")
end

get "/" do
  @title = "The Adventures of Sherlock Holmes"

  erb :home
end

get "/chapters/:number" do
  number = params[:number].to_i

  @chapter_name = @contents[number - 1]
  @title = "Chapter #{number}: #{@chapter_name}"

  redirect "/" unless (1..@contents.size).cover?(number)

  @chapter = File.read("data/chp#{number}.txt")
  erb :chapter
end

get "/search" do
  @result = find_text(params[:query])
  erb :search
end

not_found do
  redirect "/"
end

helpers do
  def in_paragraphs(text)
    text.split("\n\n").each_with_index.map { |str, index| "<p id=#{index}>#{str}</p>" }.join
  end

  def highlight(text, term)
    text.gsub(term, %(<strong>#{term}</strong>))
  end
end

def each_chapter
  @contents.each_with_index do |chapter_name, idx|
    name = chapter_name
    number = idx + 1
    text = File.read("data/chp#{number}.txt")
    yield name, number, text
  end
end

def find_text(str)
  response = []
  return response if !str || str.empty?

  each_chapter do |name, number, text|
    matches = {}
    text.split("\n\n").each_with_index do |paragraph, idx|
      matches[idx] = paragraph if paragraph.include?(str)
    end
    response << {name: name, number: number, paragraphs: matches} if matches.any?
  end
  response
end
# display a link to each chapter that is TRUE
