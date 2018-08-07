# frozen_string_literal: true

require 'simple_serializer'
require 'benchmark'

Publisher = Struct.new(:id, :name, :website_url)
Author = Struct.new(:id, :name, :publisher, :books)
Book = Struct.new(:id, :title, :date)

NewInstancesSimpleSerialzier = Class.new(SimpleSerializer) do
  define_method(:serializable_hash) do |_ = nil|
    return nil if @object.nil?
    return serialize_single_object_to_hash unless collection?

    @object.map do |object|
      self.class.new(object, @options).serializable_hash
    end
  end
end

class BookSerializer < SimpleSerializer
  attributes :id, :title, :date
end

class BookNewInstanceSerializer < NewInstancesSimpleSerialzier
  attributes :id, :title, :date
end

books = Array.new(10_000) do |n|
  Book.new(n.to_s, "Book #{n}", Date.new(2014, 8, 5))
end

Benchmark.bmbm do |x|
  x.report("existing serializer:") do
    BookSerializer.new(books).serializable_hash
  end
  x.report("new instance serializer:") do
    BookNewInstanceSerializer.new(books).serializable_hash
  end
end
