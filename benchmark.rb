# frozen_string_literal: true

require 'simple_serializer'
require 'benchmark'

Publisher = Struct.new(:id, :name, :website_url)
Author = Struct.new(:id, :name, :publisher, :books)
Book = Struct.new(:id, :title, :date)

NewInstancesSimpleSerialzier = Class.new(SimpleSerializer) do
  define_method(:serialize_collections) do |hash|
    self.class.collections.each do |collection_name, key, serializer, block|
      collection = get_collection(collection_name, block)

      json_array = []

      collection.each do |object|
        serializer_instance = serializer.new(object, options)
        json_array << serializer_instance.serialize
      end

      hash[key] = json_array
    end
  end
end

class PublisherSerializer < SimpleSerializer
  attributes :id, :name, :website_url
end

class BookSerializer < SimpleSerializer
  attributes :id, :title, :date
end

class AuthorSerializer < SimpleSerializer
  attributes :id, :name

  has_one :publisher
  has_many :books
end

class AuthorNewInstanceSerializer < NewInstancesSimpleSerialzier
  attributes :id, :name

  has_one :publisher
  has_many :books
end

publisher = Publisher.new('1', 'Penguin Books', 'penguin.com')

books = Array.new(10_000) do |n|
  Book.new(n.to_s, "Book #{n}", Date.new(2014, 8, 5))
end

author = Author.new('1', 'James McBride', publisher, books)

Benchmark.bmbm do |x|
  x.report("existing serializer:") do
    AuthorSerializer.new(author).serializable_hash
  end
  x.report("new instance serializer:") do
    AuthorNewInstanceSerializer.new(author).serializable_hash
  end
end
